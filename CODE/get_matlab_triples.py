import importlib
import python_code
import python_code.utils as utils

import pandas as pd


utils = importlib.reload(python_code.utils)

convs = utils.get_convs()

triples = []
for conv in convs:
    for node in convs[conv]['children']:
        if convs[conv]['children'][node]:
            for child in convs[conv]['children'][node]:
                triples.append([conv, node, child])


df = pd.DataFrame(triples, columns=['conv', 'u1', 'u2'])
df.to_csv("../data/triples.csv")