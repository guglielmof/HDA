import sys
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
sns.set_style("whitegrid")


measure = sys.argv[1]
fwname = sys.argv[2]

start_path = "../data/downsampled_measures"

# import the list of manual runs
with open("../data/manual_runs.csv", "r") as F:
    mruns = [_.strip() for _ in F.readlines()][1:]

measures = {}

with open(f"{start_path}/{measure}/1/0.csv", "r") as F:
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

sorted_systems = {r[0]: e
                  for e, r in enumerate(
        sorted([(r, np.mean([np.mean(measures[r][c]) for c in measures[r]]))
                for r in measures],
               key=lambda x: x[1])
    )}

figure = plt.figure(figsize=(13, 8))

new_measure = pd.read_csv(f"{start_path}/{fwname}/{measure}/1/0.csv").rename(columns={'alpha': 'p'})
new_measure['p'] = new_measure['p'].replace({np.nan: '0'})
single_alpha = True
if len(set(new_measure['p'])) > 1:
    single_alpha = False

if single_alpha:
    new_measure = new_measure.drop("p", axis=1)
    conv_results = new_measure.groupby(["run", "conv"]).mean().reset_index()
    plot_res = conv_results.groupby(["run"]).mean().reset_index()
    plot_res['Aggregation'] = plot_res.apply(lambda x: "Hierarchical Agg.", axis=1)

    original_measure = pd.read_csv(f"{start_path}/{measure}/1/0.csv")
    conv_results = original_measure.groupby(["run", "conv"]).mean().reset_index()
    conv_results = conv_results.groupby(["run"]).mean().reset_index()
    conv_results['Aggregation'] = plot_res.apply(lambda x: "Original Agg.", axis=1)

    plot_res = pd.concat([plot_res, conv_results])

else:
    new_measure = new_measure[new_measure['p'].isin(['0.8', '0.5', '0.2'])]
    conv_results = new_measure.groupby(["run", "conv", "p"]).mean().reset_index()
    plot_res = conv_results.groupby(["run", "p"]).mean().reset_index()

plot_res['rank'] = plot_res.apply(lambda x: sorted_systems[x['run']], axis=1)
plot_res['Run type'] = plot_res.apply(lambda x: x['run'] in mruns, axis=1)
plot_res['Run type'] = plot_res['Run type'].replace({True: 'Manual Rewriting', False: 'Automatic Rewriting'})

if single_alpha:
    plot = sns.scatterplot(data=plot_res, x='rank', y='score', hue='Run type', style='Aggregation', hue_order=['Automatic Rewriting', 'Manual Rewriting'], s=80)

    h, l = plot.get_legend_handles_labels()
    plt.legend(h[1:3]+h[4:], l[1:3]+l[4:], fontsize=24)
else:
    plot = sns.scatterplot(data=plot_res, x='rank', y='score', style='p', hue='manual')

plot.set_xlabel("rank", fontsize=27)
plot.set_ylabel("aggregated scores", fontsize=27)
plot.tick_params(labelsize=27)


plt.tight_layout()
plt.savefig(f'../data/scatter_{measure}-{fwname}.pdf')
