import json
import numpy as np

with open("../data/conv_annotations.json", "r") as read_file:
    conv_annotations = json.load(read_file)




convs = {}
for c in conv_annotations:
    adjMatrix = np.array(c['links'])
    idx = str(c['number'])
    roots = [e for e, i in enumerate(adjMatrix) if np.all(i == 0)]
    children = {e: list(np.where(i == 1)[0]) for e, i in enumerate(adjMatrix.T)}
    convs[idx] = {'root': roots, 'children': children}

with open("../data/conv_roots.csv", 'w') as write_file:
    for c in convs:
        write_file.write(f"{c},{','.join([str(r) for r in convs[c]['root']])}\n")