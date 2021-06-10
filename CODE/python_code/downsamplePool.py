import numpy as np
import random
def downsampling(qrel, N=100, p=None):
    if p is None:
        #p = [0.90, 0.80, 0.70, 0.60, 0.50, 0.40, 0.30, 0.25, 0.20, 0.15, 0.10, 0.05, 0.04, 0.03, 0.02, 0.01]
        p = [0.90, 0.80, 0.70, 0.60, 0.50, 0.40, 0.30, 0.20, 0.10]

    topics = list(qrel.keys())
    qrels_new = {q:{n:{t:{} for t in topics} for n in range(N)} for q in p}

    for t in topics:
        rels = {}
        nonrels = {}
        for d, r in qrel[t].items():
            if r == 0:
                nonrels[d] = 0
            else:
                rels[d] = r

        relsIds = list(rels.keys())
        nonrelsIds = list(nonrels.keys())

        for q in p:
            nrels = int(np.max([np.min([len(rels), 1]), len(rels) * q]))
            nnonrels = int(np.max([np.min([len(nonrels), 10]), len(nonrels) * q]))
            for n in range(N):
                sapledrels = random.sample(relsIds, k=nrels)
                samplednonrels = random.sample(nonrelsIds, k=nnonrels)
                for d in sapledrels:
                    qrels_new[q][n][t][d] = rels[d]
                for d in samplednonrels:
                    qrels_new[q][n][t][d] = nonrels[d]

    return qrels_new