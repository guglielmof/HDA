import importlib
import numpy as np
import pytrec_eval
import json
from python_code import conv_measures, eval_collections
import logging
import time
import pandas as pd
import scipy.stats as sts
from python_code import downsamplePool

logging.basicConfig(
    level=logging.INFO,
    # filename=logfile_path,
    filemode='w',
    format='[%(asctime)s - %(levelname)s]: %(message)s',
    datefmt='%m-%d %H:%M', )

N = 100
#p = [0.90, 0.80, 0.70, 0.60, 0.50, 0.40, 0.30, 0.20, 0.10]
p = None
eval_collections = importlib.reload(eval_collections)
conv_measures = importlib.reload(conv_measures)

logging.info('Importing CAsT')
tstart = time.time()
CAsT = eval_collections.CAsT().import_collection(conv=True)
sampled_pools = downsamplePool.downsampling(CAsT.qrels_ts, N=N)
logging.info(f'Done in {time.time() - tstart:.2f} s')

with open("../data/conv_annotations.json", "r") as read_file:
    conv_annotations = json.load(read_file)

convs = {}
for c in conv_annotations:
    adjMatrix = np.array(c['links'])
    idx = str(c['number'])
    roots = [e for e, i in enumerate(adjMatrix) if np.all(i == 0)]
    children = {e: list(np.where(i == 1)[0]) for e, i in enumerate(adjMatrix.T)}
    convs[idx] = {'root': roots, 'children': children}

logging.info('Evaluating CAsT runs')
tstart = time.time()

alphas = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
#alphas = [0, 0.2, 0.4, 0.6, 0.8, 1]

results = []

for q in sampled_pools:
    logging.info(f'Evaluating using {q*100}% of the documents')
    t2start = time.time()
    for n in sampled_pools[q]:
        topic_evaluator = {t: pytrec_eval.RelevanceEvaluator({t: sampled_pools[q][n][t]}, {'ndcg_cut'})
                           for t in sampled_pools[q][n]}

        measures_orig = {r: {} for r in CAsT.runs}
        for runID in CAsT.runs:
            measures_orig[runID] = {t: topic_evaluator[t].evaluate({t: CAsT.runs[runID][t]})[t]['ndcg_cut_5'] for t in
                                    sampled_pools[q][n]}

        measures = {}
        for runID in CAsT.runs:
            m = measures_orig[runID]
            measures[runID] = {}
            sorted_m = {}
            for t in m:
                t_id, u_id = t.split("_")
                if t_id not in sorted_m:
                    sorted_m[t_id] = []
                sorted_m[t_id].append((u_id, m[t]))
            for t_id in sorted_m:
                sorted_m[t_id] = [v for u_id, v in sorted(sorted_m[t_id], key=lambda x: x[0])]
                measures[runID][t_id] = sorted_m[t_id]

        for alpha in alphas:

            new_measures = {}
            for runID in CAsT.runs:
                new_measures[runID] = {}
                for conv in convs:
                    new_measures[runID][conv] = conv_measures.recursive_measure(convs[conv], measures[runID][conv],
                                                                                alpha=alpha)

            for runID in new_measures:
                for conv in new_measures[runID]:
                    for e, v in enumerate(new_measures[runID][conv]):
                        results.append([q, n, runID, conv, e, alpha, v])
    logging.info(f'Done in {time.time() - t2start:.2f} s')
logging.info(f'Overall evaluation done in {time.time() - tstart:.2f} s')

results = pd.DataFrame(results, columns=["p", "rep", "run", "conv", "utt", "alpha", "score"])
logging.info(f'saving results')
tstart = time.time()
results.to_csv(f"../data/downsampled_short_NDCG_cut_5.csv")
logging.info(f'results saved in {time.time() - tstart:.2f} s')
