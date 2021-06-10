import pandas as pd
import numpy as np
measure = 'NDCG_cut_3'
start_path = "../data/downsampled_measures"

fwname1 = 'markovian-backward-mean'
fwname2 = 'markovian-forward-mean'

new_measure1 = pd.read_csv(f"{start_path}/{fwname1}/{measure}/1/0.csv")
new_measure2 = pd.read_csv(f"{start_path}/{fwname2}/{measure}/1/0.csv")
original_measure = pd.read_csv(f"{start_path}/{measure}/1/0.csv")

# import the list of manual runs
with open("../data/manual_runs.csv", "r") as F:
    man_runs = [_.strip() for _ in F.readlines()][1:]

measures = [original_measure, new_measure1, new_measure2]

for e, m in enumerate(measures):
    m = m[['run', 'conv', 'score']]
    m = m.groupby(['run', 'conv']).mean().reset_index()
    m = m.groupby(['run']).mean().reset_index()
    m = m[['run', 'score']]
    m['manual'] = m.apply(lambda x: x['run'] in man_runs, axis=1)
    measures[e] = m

tot_runs = list(set(measures[0]['run']))
aut_runs = list(set(tot_runs) - set(man_runs))

def comp(r1, r2, m):
    return m[m['run'] == r1]['score'].iloc[0] > m[m['run'] == r2]['score'].iloc[0]

tot_switches = np.array([0, 0])
for e1, r1 in enumerate(tot_runs[:-1]):
    for e2, r2 in enumerate(tot_runs[e1 + 1:]):
        d0 = comp(r1, r2, measures[0])
        d1 = comp(r1, r2, measures[1])
        d2 = comp(r1, r2, measures[2])

        tot_switches += np.array([d0!=d1, d0!=d2])

tot_switches = tot_switches/(len(tot_runs)*(len(tot_runs)-1)/2)


aut_switches = np.array([0, 0])
for e1, r1 in enumerate(aut_runs[:-1]):
    for e2, r2 in enumerate(aut_runs[:-1]):
        d0 = comp(r1, r2, measures[0])
        d1 = comp(r1, r2, measures[1])
        d2 = comp(r1, r2, measures[2])

        aut_switches += np.array([d0!=d1, d0!=d2])

aut_switches = aut_switches/(len(aut_runs)*(len(aut_runs)-1)/2)

man_switches = np.array([0, 0])
for e1, r1 in enumerate(man_runs[:-1]):
    for e2, r2 in enumerate(man_runs[:-1]):
        d0 = comp(r1, r2, measures[0])
        d1 = comp(r1, r2, measures[1])
        d2 = comp(r1, r2, measures[2])

        man_switches += np.array([d0!=d1, d0!=d2])

man_switches = man_switches/(len(man_runs)*(len(man_runs)-1)/2)

print(tot_switches)
print(aut_switches)
print(man_switches)

