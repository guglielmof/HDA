import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
data = []
sns.set_style("whitegrid")
with open("../data/correlations.txt", "r") as F:
    for l in F.readlines():
        data.append(np.array([float(d) for d in l.strip().split(",")]))


figure = plt.figure(figsize=(13, 8))
sns.lineplot(x=data[0], y=data[1], linewidth=6, linestyle="-")
sns.lineplot(x=data[0], y=data[2], linewidth=6, linestyle=(0, (5, 5)))
sns.lineplot(x=data[0], y=data[3], linewidth=6, linestyle=(0,(3, 2, 1, 2)))

plt.xlim([0, 0.7])

plt.xlabel(r"Kendall's $\tau$", fontsize=27)
plt.ylabel("PDF", fontsize=27)
plt.tick_params(labelsize=27)


plt.legend(['different convs.', 'same convs.', 'same tree'], fontsize=24)
plt.tight_layout()
plt.savefig(f'../data/corrs.pdf')