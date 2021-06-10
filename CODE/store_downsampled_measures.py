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
import python_code.downsamplePool as downsamplePool
from python_code.framework_functions import framework_functions
import os

utils = importlib.reload(python_code.utils)
eval_collections = importlib.reload(eval_collections)
conv_measures = importlib.reload(conv_measures)
downsamplePool = importlib.reload(python_code.downsamplePool)

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

if f"{measure}" not in os.listdir("../data/downsampled_measures/"):
    os.mkdir(f"../data/downsampled_measures/{measure}")



if "1" not in os.listdir(f"../data/downsampled_measures/{measure}"):
    os.mkdir(f"../data/downsampled_measures/{measure}/1")

tstart = time.time()
# ----- COMPUTE THE REQUIRED MEASURE ----- #
measures = utils.compute_measure(measure, CAsT.runs, CAsT.qrels_ts)
measures_df = [[r, c, e, v] for r in measures for c in measures[r] for e, v in enumerate(measures[r][c])]
measures_df = pd.DataFrame(measures_df, columns=['run', 'conv', 'utt', 'score'])
measures_df.to_csv(f"../data/downsampled_measures/{measure}/1/0.csv")
logging.info(f'Done in {time.time() - tstart:.2f} s')

new_qrels = downsamplePool.downsampling(CAsT.qrels_ts)

for dsprop in new_qrels:
    if f"{dsprop}" not in os.listdir(f"../data/downsampled_measures/{measure}"):
        os.mkdir(f"../data/downsampled_measures/{measure}/{dsprop}")

    for rep in new_qrels[dsprop]:
        
        tstart = time.time()
        # ----- COMPUTE THE REQUIRED MEASURE ----- #
        measures = utils.compute_measure(measure, CAsT.runs, new_qrels[dsprop][rep])
        measures_df = [[r, c, e, v] for r in measures for c in measures[r] for e, v in enumerate(measures[r][c])]
        measures_df = pd.DataFrame(measures_df, columns=['run', 'conv', 'utt', 'score'])

        measures_df.to_csv(f"../data/downsampled_measures/{measure}/{dsprop}/{rep}.csv")
        logging.info(f'Done in {time.time() - tstart:.2f} s')
