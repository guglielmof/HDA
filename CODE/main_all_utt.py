import importlib
import numpy as np
import pytrec_eval
import json
from python_code import conv_measures, eval_collections
import logging
import time
import pandas as pd
import scipy.stats as sts


logging.basicConfig(
    level=logging.INFO,
    # filename=logfile_path,
    filemode='w',
    format='[%(asctime)s - %(levelname)s]: %(message)s',
    datefmt='%m-%d %H:%M', )

eval_collections = importlib.reload(eval_collections)
conv_measures = importlib.reload(conv_measures)

logging.info('Importing CAsT')
tstart = time.time()
CAsT = eval_collections.CAsT().import_collection(conv=True)
logging.info(f'Done in {time.time() - tstart:.2f} s')

logging.info('Evaluating CAsT runs')
tstart = time.time()
topic_evaluator = {t: pytrec_eval.RelevanceEvaluator({t: CAsT.qrels_ts[t]}, {'ndcg_cut.3'})
                   for t in CAsT.qrels_ts}

measures_orig = {r: {} for r in CAsT.runs}
for runID in CAsT.runs:
    measures_orig[runID] = {t: topic_evaluator[t].evaluate({t: CAsT.runs[runID][t]})[t]['ndcg_cut_3'] for t in CAsT.qrels_ts}


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

logging.info(f'Done in {time.time() - tstart:.2f} s')

with open("../data/conv_annotations.json", "r") as read_file:
    conv_annotations = json.load(read_file)


#SANITY CHECK: all the runs have the score for each annotated value
for c in conv_annotations:
    for runID in CAsT.runs:
        if not len(measures[runID][str(c['number'])]) == len(c['raw_utterances']):
            print(f"{runID} doesn't pass the sanity check for topic {c['number']}")


convs = {}
for c in conv_annotations:
    adjMatrix = np.array(c['links'])
    idx = str(c['number'])
    roots = [e for e, i in enumerate(adjMatrix) if np.all(i == 0)]
    children = {e: list(np.where(i == 1)[0]) for e, i in enumerate(adjMatrix.T)}
    convs[idx] = {'root': roots, 'children': children}


alphas = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]

results = []
for alpha in alphas:

    new_measures = {}
    for runID in CAsT.runs:
        new_measures[runID] = {}
        for conv in convs:
            new_measures[runID][conv] = conv_measures.recursive_measure(convs[conv], measures[runID][conv], alpha=alpha)


    for runID in new_measures:
        for conv in new_measures[runID]:
            for e, v in enumerate(new_measures[runID][conv]):
                results.append([runID, conv, e, alpha, v])

results = pd.DataFrame(results, columns=["run", "conv", "utt", "alpha", "score"])

results.to_csv("../data/NDCG_cut_3.csv")

measures_orig_filtered = {}
convs_considered = set([c for c in convs])
for runID in measures_orig:
    measures_orig_filtered[runID] = {}
    for utt in measures_orig[runID]:
        if utt.split("_")[0] in convs_considered:
            measures_orig_filtered[runID][utt] = measures_orig[runID][utt]

marginal_measure = results.groupby(["alpha", "run"]).mean().reset_index()
runIDs = [r for r in CAsT.runs]
global_vecs = {}
for a in alphas:
    global_vecs[a] = [np.array(marginal_measure[(marginal_measure['alpha']==a) & (marginal_measure['run']==r)]['score'])[0] for r in runIDs]


for a in alphas:
    tau, p_value = sts.kendalltau(global_vecs[a], global_vecs[1])
    print(f"alpha:{a}, tau:{tau:.4f} p-val:{p_value:.4f}")