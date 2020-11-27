from pathlib import Path
from pylexibank.dataset import Dataset as BaseDataset
from pylexibank import progressbar
from pylexibank.models import Language, Concept, Lexeme
from clldutils.misc import slug
import attr

import lingpy


@attr.s
class CustomLanguage(Language):
    Location = attr.ib(default=None)
    SubGroup = attr.ib(default=None)
    Number = attr.ib(default=None)


@attr.s
class CustomConcept(Concept):
    Spanish_Gloss = attr.ib(default=None)
    Number = attr.ib(default=None)


@attr.s
class CustomLexeme(Lexeme):
    Floating_Tone = attr.ib(default=None)
    Loan = attr.ib(default=None)
    Loan_Source = attr.ib(default=None)


class Dataset(BaseDataset):
    dir = Path(__file__).parent
    id = 'mixteca'
    language_class = CustomLanguage
    concept_class = CustomConcept
    lexeme_class = CustomLexeme

    def cmd_makecldf(self, args):
        wl = lingpy.Wordlist(str(self.raw_dir / 'mixt_complist_clean.tsv'))
        args.writer.add_sources()
        args.writer.add_languages(id_factory='Name')
        concepts = {}
        for concept in self.concepts:
            idx = concept['NUMBER']+'_'+slug(concept['ENGLISH'])
            args.writer.add_concept(
                    ID=idx,
                    Name=concept['ENGLISH'],
                    Number=concept['NUMBER'],
                    Concepticon_ID=concept['CONCEPTICON_ID'],
                    Concepticon_Gloss=concept['CONCEPTICON_GLOSS'],
                    Spanish_Gloss=concept['SPANISH']
                    )
            concepts[concept['ENGLISH']] = idx
        visited = set()
        for k in progressbar(wl, desc='wl-to-cldf', total=len(wl)):
            if wl[k, 'concept'] in concepts:
                if wl[k, 'form']:
                    args.writer.add_form(
                        Language_ID=wl[k, 'doculect'],
                        Parameter_ID=concepts[wl[k, 'concept']],
                        Value=wl[k, 'value'],
                        Form=wl[k, 'form'],
                        Source=wl[k, 'source'],
                    )
            else:
                if wl[k, 'concept'] not in visited:
                    args.log.warn('concept {0} missing'.format(wl[k,
                        'concept']))
                    visited.add(wl[k, 'concept'])


