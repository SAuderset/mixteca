"""
This script is designed to output the wordlist with cognate judgements
"""

from lexibank_mixteca import Dataset
from lingpy import Wordlist
from pyconcepticon import Concepticon
from cldfcatalog import Config
from tabulate import tabulate
from segments import Profile, Tokenizer
import csv
import re


def register(parser):
    parser.add_argument(
        "--output", action="store", default=None, help="a label for output"
    )
    parser.add_argument(
        "--cognate_set",
        action="store",
        default=None,
        help="a wordlist with cognate judgements",
    )


def run(args):
    """
    main entry point
    """

    columns = (
        "parameter_id",
        "concept_name",
        "language_id",
        "language_doculect",
        "language_subgroup",
        "value",
        "form",
        "language_glottocode",
        "concept_concepticon_id",
        "language_latitude",
        "language_longitude",
        "cognacy",
        "loan",
        "source",
        "notes",
    )

    namespace = [
        ("concept_name", "concept"),
        ("language_id", "doculect"),
        ("language_subgroup", "subgroup"),
        ("language_doculect", "language_name"),
        ("language_glottocode", "glottolog"),
        ("concept_concepticon_id", "concepticon"),
        ("language_latitude", "latitude"),
        ("language_longitude", "longitude"),
        ("cognacy", "cognacy"),
        ("loan", "loan"),
        ("source", "source"),
        ("notes", "notes"),
    ]

    ds = Dataset()
    wl_raw = Wordlist.from_cldf(
        ds.dir.joinpath("cldf", "cldf-metadata.json").as_posix(),
        columns=columns,
        namespace=dict(namespace),
    )

    # If the entries are exactly duplicated, remove them from the data.
    wl_filtered = {
        0: [
            "parameter_id",
            "concept",
            "doculect",
            "language_name",
            "subgroup",
            "value",
            "form",
            "glottolog",
            "concepticon",
            "latitude",
            "longitude",
            "cognacy",
            "loan",
            "source",
            "notes",
        ]
    }
    i = 1
    checking = []
    duplicate = []
    for idx, c, doc, vl, fm in wl_raw.iter_rows("concept", "doculect", "value", "form"):
        if [c, doc, vl, fm] in checking:
            duplicate.append([c, doc, vl, fm])
            continue
        else:
            checking.append([c, doc, vl, fm])
            wl_filtered[idx] = [
                wl_raw[idx, "parameter_id"],
                wl_raw[idx, "concept"],
                wl_raw[idx, "doculect"],
                wl_raw[idx, "language_name"],
                wl_raw[idx, "subgroup"],
                wl_raw[idx, "value"],
                wl_raw[idx, "form"],
                wl_raw[idx, "glottolog"],
                wl_raw[idx, "concepticon"],
                wl_raw[idx, "latitude"],
                wl_raw[idx, "logitude"],
                wl_raw[idx, "cognacy"],
                wl_raw[idx, "loan"],
                wl_raw[idx, "source"],
                wl_raw[idx, "notes"],
            ]
            i += 1
    print("removed the following duplicated entries")
    print(tabulate(duplicate, headers=["concept", "doculect", "value", "form"]))

    wl = Wordlist(wl_filtered)
    wl.add_entries("cogid", "cognacy", lambda x: 0)
    missing_cogid_set = []
    # add cognate sets from an external version
    cgid = Wordlist(args.cognate_set)
    cgid_book = {}
    for idx, c, doc, fm, cid in cgid.iter_rows("concept", "doculect", "form", "cogid"):
        cgid_book[(c, doc, fm)] = [cid, cgid[idx, "cognacy"], cgid[idx, "notes"], cgid[idx, 'loan']]

    prf = Profile.from_file(ds.dir.joinpath("etc", "orthography_tmp.tsv"))
    tmp_tokenizer = Tokenizer(profile=prf)

    for idx, c, doc, fm, loan in wl.iter_rows("concept", "doculect", "form", "loan"):
        if doc == "KBWestPuroikLieberherr":
            doc = "KBBuluPuroik"
        if (c, doc, fm) in cgid_book.keys():
            wl[idx, "cogid"] = cgid_book[(c, doc, fm)][0]
            wl[idx, "cognacy"] = cgid_book[(c, doc, fm)][1]
            wl[idx, "notes"] = cgid_book[(c, doc, fm)][2]
            wl[idx, 'loan'] = cgid_book[(c, doc, fm)][3]
        else:
            if doc not in [
                "MishmiKaman",
                "KBEastPuroikSoja",
                "KBEastPuroikRemsangpuia",
                "KBEastPuroikSun",
            ]:
                missing_cogid_set.append([c, doc, fm])
        if "." in fm:
            if "KB" in doc:
                wl[idx, "form"] = fm.replace(".", "+")
            elif doc == "Kusunda":
                wl[idx, "form"] = fm.replace(".", "+")
            else:
                wl[idx, "form"] = fm.replace(".", "").replace("◦", "+").replace("•", "")
        if "Cuona" in doc:
            sg = tmp_tokenizer(fm, column="IPA")
            wl[idx, "form"] = sg.rstrip("+").replace(" ", "")

    for idx, fm in wl.iter_rows("form"):
        if "_" in fm:
            wl[idx, "form"] = fm.replace("_", "+")

    # final beautify on word form, laons and language:
    for idx, doc, fm, loan in wl.iter_rows("doculect","form","loan"):
        if '++' in fm:
            wl[idx, 'form'] = fm.replace("++","+")
        if loan is None:
            wl[idx, 'loan'] = 'FALSE'
        if doc == "DarangTaraon":
            wl[idx, 'doculect'] = "MishmiDarangTaraon"
        elif doc == "Yidu":
            wl[idx, 'doculect'] = "MishmiYidu"

    print("Cannot find the cognate sets for the following entries in our new data: ")
    print(tabulate(missing_cogid_set, headers=["concept", "doculect", "value", "form"]))

    print("output wordlist")
    wl.output("tsv", filename=args.output, prettify=False)
