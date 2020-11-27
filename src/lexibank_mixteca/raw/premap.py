# https://github.com/lingpy/pysen
from pysen.glosses import to_concepticon
from lingpy import *
wl = Wordlist('mixt_complist_clean.tsv')
concepts = []
visited = set()
i = 1
for idx, concept, spanish in wl.iter_rows('concept', 'spanish_gloss'):
    if concept not in visited:
        visited.add(concept)
        maps = to_concepticon([{'gloss': concept}])[concept]
        maps2 = to_concepticon([{'gloss': spanish}], language='es')[spanish]
        cid_en, cgl_en, cid_es, cgl_es = '', '', '', ''
        if maps:
            cid_en, cgl_en = maps[0][0], maps[0][1]
        if maps2:
            cid_es, cgl_es = maps2[0][0], maps2[0][1]
        
        if cid_es:
            cid, cgl = cid_es, cgl_es
        else:
            cid, cgl = cid_en, cgl_en

        concepts += [[str(i), concept, spanish, cid, cgl]]
        i += 1
with open('../etc/concepts.tsv', 'w') as f:
    f.write('NUMBER\tENGLISH\tSPANISH\tCONCEPTICON_ID\tCONCEPTICON_GLOSS\n')
    for line in concepts:
        f.write('\t'.join(line)+'\n')
