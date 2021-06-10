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
import os

utils = importlib.reload(python_code.utils)
eval_collections = importlib.reload(eval_collections)
conv_measures = importlib.reload(conv_measures)

logging.basicConfig(
    level=logging.INFO,
    # filename=logfile_path,
    filemode='w',
    format='[%(asctime)s - %(levelname)s]: %(message)s',
    datefmt='%m-%d %H:%M', )

measure = sys.argv[1]
fwname = sys.argv[2]
fw = framework_functions[fwname]

convs = fw['conv_importer']()

start_path = "../data/downsampled_measures"

fwpath = f"{start_path}/{fwname}"
if fwname not in os.listdir(start_path):
    os.mkdir(fwpath)

mpath = f"{fwpath}/{measure}"
if measure not in os.listdir(fwpath):
    os.mkdir(mpath)

for dsprop in os.listdir(f"{start_path}/{measure}"):
    dspath = f"{mpath}/{dsprop}"
    if dsprop not in os.listdir(mpath):
        os.mkdir(dspath)
    for rep in os.listdir(f"{start_path}/{measure}/{dsprop}"):
        tstart = time.time()
        reppath = f"{dspath}/{rep}"
        measures = {}
        with open(f"{start_path}/{measure}/{dsprop}/{rep}", "r") as F:
            for l in F.readlines()[1:]:
                _, run, conv, utt, score = l.strip().split(",")
                if run not in measures:
                    measures[run] = {}
                if conv not in measures[run]:
                    measures[run][conv] = []
                measures[run][conv].append((utt, float(score)))
        for r in measures:
            for c in measures[r]:
                measures[r][c] = np.array([s for _, s in sorted(measures[r][c], key=lambda x: int(x[0]))])

        # ----- COMPUTE THE MEASURE FOR DIFFRENT SETUPS ----- #
        results = []
        for alpha in fw['default_alphas']:
            for runID in measures:
                for conID in convs:
                    mvec = fw['f'](convs[conID], measures[runID][conID], alpha, **fw['p'])
                    for e, v in enumerate(mvec):
                        results.append(
                            [runID, conID, e, alpha, v, e in convs[conID]['root'], e in convs[conID]['leaves']])

        results = pd.DataFrame(results, columns=["run", "conv", "utt", "alpha", "score", 'roots', 'leaves'])
        if fw['keep_only'] is not None:
            results = results[results[fw['keep_only']] == True]
        results.to_csv(reppath)
        logging.info(f'Done in {time.time() - tstart:.2f} s')