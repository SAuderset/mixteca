"""
This script is designed to output the wordlist with partial cognate judgements from lexstat method
"""

from lexibank_mixteca import Dataset
from lingpy import Wordlist
from lingpy.compare.partial import Partial

# choose columns to output
columns = (
    "parameter_id",
    "concept_name",
    "language_id",
    "language_doculect",
    "language_subgroup",
    "value",
    "form",
    "segments",
    "language_glottocode",
    "concept_concepticon_id",
    "language_latitude",
    "language_longitude",
    "loan",
    "source",
    "comment",
)

# rename column names
namespace = [
    ("concept_name", "concept"),
    ("language_id", "doculect"),
    ("language_subgroup", "subgroup"),
    ("language_doculect", "language_name"),
    ("language_glottocode", "glottolog"),
    ("concept_concepticon_id", "concepticon"),
    ("language_latitude", "latitude"),
    ("language_longitude", "longitude"),
    ("loan", "loan"),
    ("source", "source"),
    ("comment", "comment"),
]


# change
wl = Wordlist.from_cldf(
    Dataset().dir.joinpath("cldf", "cldf-metadata.json").as_posix(),
    columns=columns,
    namespace=dict(namespace),
)

# put wordlist to a partial cognate object class
part = Partial(wl, segments="segments")

# get score
part.get_partial_scorer(runs=10000)

# generate partial cluster
part.partial_cluster(
    method="lexstat",
    threshold=0.55,
    ref="cogids",
    mode="global",
    gop=-2,
    cluster_method="infomap",
)


print("output wordlist")
part.output("tsv", filename="wordlist_mixteca", prettify=False)
