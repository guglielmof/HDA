import importlib
import numpy as np
import pytrec_eval
import json
from python_code import conv_measures, eval_collections
import logging
import time
import pandas as pd
import scipy.stats as sts
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import python_code
import python_code.utils as utils
from python_code.framework_functions import framework_functions


utils = importlib.reload(python_code.utils)
eval_collections = importlib.reload(eval_collections)
conv_measures = importlib.reload(conv_measures)


logging.basicConfig(
    level=logging.INFO,
    # filename=logfile_path,
    filemode='w',
    format='[%(asctime)s - %(levelname)s]: %(message)s',
    datefmt='%m-%d %H:%M', )

logging.info('Importing CAsT')
tstart = time.time()

# import the collection
CAsT = eval_collections.CAsT().import_collection(conv=True)

# import the list of manual runs
with open("../data/manual_runs.csv", "r") as F:
    mruns = [_.strip() for _ in F.readlines()][1:]

logging.info(f'Done in {time.time() - tstart:.2f} s')

logging.info('Evaluating CAsT runs')
tstart = time.time()
measure = sys.argv[1]

# ----- COMPUTE THE REQUIRED MEASURE ----- #
measures = utils.compute_measure(measure, CAsT.runs, CAsT.qrels_ts)
measures_df = [[r, c, e, v] for r in measures for c in measures[r] for e, v in enumerate(measures[r][c])]
measures_df = pd.DataFrame(measures_df, columns=['run', 'conv', 'utt', 'score'])
# sort systems according to the required measure
sorted_systems = {r[0]: e
                  for e, r in enumerate(
        sorted([(r, np.mean([np.mean(measures[r][c]) for c in measures[r]]))
                for r in measures],
               key=lambda x: x[1])
    )}
logging.info(f'Done in {time.time() - tstart:.2f} s')





from python_code.framework_functions import framework_functions

fwname = sys.argv[2]
fw = framework_functions[fwname]

convs = fw['conv_importer']()

# ----- COMPUTE THE MEASURE FOR DIFFRENT SETUPS ----- #
results = []
for alpha in fw['default_alphas']:
    for runID in CAsT.runs:
        for conID in convs:
            mvec = fw['f'](convs[conID], measures[runID][conID], alpha, **fw['p'])
            if runID =='input.datasetreorder' and conID =='68' and alpha==0.0:
                print(mvec)
                print(measures[runID][conID])
            for e, v in enumerate(mvec):
                results.append([runID, conID, e, alpha, v])

results = pd.DataFrame(results, columns=["run", "conv", "utt", "alpha", "score"])


results['roots'] = results.apply(lambda x: x['utt'] in convs[x['conv']]['root'], axis=1)
results['leaves'] = results.apply(lambda x: x['utt'] in convs[x['conv']]['leaves'], axis=1)
if fw['keep_only']=='roots':
    results = results[results['roots']==True]
if fw['keep_only']=='leaves':
    results = results[results['leaves']==True]

results.to_csv(f"../data/{measure}-{fwname}.csv")


# ----- GROUP AND PLOT RESULTS ----- #
if len(fw['default_alphas'])>1:
    conv_results = results.groupby(["run", "conv", "alpha"]).mean().reset_index()


    plot_res = conv_results.groupby(["run", "alpha"]).mean().reset_index()


    #variance over different alphas
    var_results = plot_res[['run', 'score']].groupby(['run']).std().reset_index()
    var_results['manual'] = var_results.apply(lambda x: x['run'] in mruns, axis=1)
    ktau, pvkt = sts.kendalltau(var_results['score'], 1- var_results['manual'])
    logging.info(f"kendall's tau between variance over different alphas and manual {ktau:.5f} (p-val: {pvkt:.5f})")


    plot_res['rank'] = plot_res.apply(lambda x: sorted_systems[x['run']], axis=1)
    plot_res['manual'] = plot_res.apply(lambda x: x['run'] in mruns, axis=1)

    figure = plt.figure(figsize=(13, 8))
    sns.scatterplot(data=plot_res, x='rank', y='score', style='alpha', hue='manual')

    #plt.savefig(f'../data/scatter_{measure}-{fwname}.png')
else:
    conv_results = results.groupby(["run", "conv"]).mean().reset_index()
    plot_res = conv_results.groupby(["run"]).mean().reset_index()

    plot_res['rank'] = plot_res.apply(lambda x: sorted_systems[x['run']], axis=1)
    plot_res['manual'] = plot_res.apply(lambda x: x['run'] in mruns, axis=1)
    plot_res['original'] = plot_res.apply(lambda x: False, axis = 1)

    plot_res = plot_res[['rank', 'score', 'manual', 'original']]


    original_conv_results = measures_df.groupby(["run", "conv"]).mean().reset_index()
    original_plot_res = original_conv_results.groupby(["run"]).mean().reset_index()
    original_plot_res['rank'] = original_plot_res.apply(lambda x: sorted_systems[x['run']], axis=1)
    original_plot_res['manual'] = original_plot_res.apply(lambda x: x['run'] in mruns, axis=1)
    original_plot_res['original'] = original_plot_res.apply(lambda x: True, axis = 1)

    original_plot_res = original_plot_res[['rank', 'score', 'manual', 'original']]

    plot_res = pd.concat([plot_res, original_plot_res])

    figure = plt.figure(figsize=(13, 8))
    sns.scatterplot(data=plot_res, x='rank', y='score', style='original', hue='manual')

    plt.savefig(f'../data/scatter_{measure}-{fwname}.png')
