from lexibank_mixteca import Dataset as ds
from lingpy import *
from lingpy.compare.partial import Partial

wl = Wordlist.from_cldf(
        ds().dir.joinpath('cldf', 'cldf-metadata.json'),
        )

part = Partial(wl, segments ='tokens')
part.get_partial_scorer(runs=10000)
part.partial_cluster(method = 'lexstat', threshold=0.55, ref ='cogids', mode='global', gop='-2', cluster_method='infomap')
part.output('tsv', filename='partial_cognates', prettify=False)
