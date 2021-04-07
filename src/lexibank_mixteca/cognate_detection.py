from lingpy import *
from lingpy.compare.partial import Partial

#load wordlist
part = Partial("forms.tsv", segments='Segments')

# get score
part.get_partial_scorer(runs=10000)

# partial cognate
part.partial_cluster(
            method='lexstat',
            threshold=0.55,
            ref='cogids',
            mode='global',
            gop=-2,
            cluster_method='infomap'
            )

#output
part.output('tsv', filename='mixteca_partial_new', prettify=False)