import pytrec_eval
import os
import json
import logging

class collection:

    def import_collection(self):

        self.runs = self.import_runs()
        self.qrels = self.import_qrels()

        self.systems = list(self.runs.keys())
        self.topics = list(self.qrels.keys())

    def import_runs(self, nruns=-1):

        systems_paths = os.listdir(self.runs_path)
        if nruns!=-1:
            systems_paths = systems_paths[:nruns]
        # -------------------------- IMPORT RUNS -------------------------- #
        runs = {}
        for run_filename in systems_paths:
            with open(self.runs_path + run_filename, "r") as F:
                try:
                    runs[".".join(run_filename.split(".")[:-1])] = pytrec_eval.parse_run(F)
                except Exception as e:
                    logging.error(f"Error in uploading {run_filename}: {e}")
        return runs

    def import_qrels(self, qPath=None):

        # -------------------------- IMPORT QRELS -------------------------- #
        if qPath is None:
            qPath = self.qrel_path

        with open(qPath, "r") as F:
            qrels = pytrec_eval.parse_qrel(F)

        return qrels


class robust04(collection):
    def __init__(self):
        self.data_path = "../../../data/TREC/TREC_13_2004_Robust/"
        self.runs_path = self.data_path + "runs/"
        self.qrel_path = self.data_path + "pool/qrels.robust2004.txt"


class trec03(collection):
    def __init__(self):
        self.data_path = "../../../data/TREC/TREC_03_1994_AdHoc/"
        self.runs_path = self.data_path + "runs/all/"
        self.qrel_path = self.data_path + "pool/qrels.151-200.disk1-3.txt"


class conv_collection(collection):

    def import_collection(self, conv=False, nconv=-1):
        self.runs = self.import_runs(nconv)
        self.qrels_tr = self.import_qrels(self.qrel_tr_path)
        self.qrels_ts = self.import_qrels(self.qrel_ts_path)

        self.systems = list(self.runs.keys())

        self.topics_tr = list(self.qrels_tr.keys())
        self.topics_ts = list(self.qrels_ts.keys())

        self.conv2utt_tr = {}
        self.conv2utt_ts = {}

        for t in self.topics_tr:
            tid, uid = t.split("_")
            if tid not in self.conv2utt_tr:
                self.conv2utt_tr[tid] = []
            self.conv2utt_tr[tid].append(t)

        for t in self.topics_ts:
            tid, uid = t.split("_")
            if tid not in self.conv2utt_ts:
                self.conv2utt_ts[tid] = []
            self.conv2utt_ts[tid].append(t)

        if conv:
            self.conv_tr = self.import_conv(self.conv_tr_path)
            self.conv_ts = self.import_conv(self.conv_ts_path)

        return self

    def import_conv(self, path):
        with open(path) as file:
            return json.load(file)


class CAsT(conv_collection):
    def __init__(self):
        '''
		The collection has some problems:
		1) MARCO_5089548
		   MARCO_4867704
		   are duplicates for topic 4_4

		2) input.UDInfoC_BL is illformed (duplicate row)

		3) input.UDInfoC_TS has scores between apexes

		'''

        self.data_path = "../data/TREC_28_2019_CAsT/"

        self.runs_path = self.data_path + "runs/"

        self.qrel_tr_path = self.data_path + "qrels/training/train_topics_mod.qrel.txt"
        self.qrel_ts_path = self.data_path + "qrels/test/2019qrels.txt"

        self.conv_tr_path = self.data_path + "topics/training/train_topics_v1.0.json"
        self.conv_ts_path = self.data_path + "topics/test/evaluation_topics_v1.0.json"
