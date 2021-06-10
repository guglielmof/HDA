import random
import json
import numpy as np
import pytrec_eval


def get_all_nodes(forest):
    nodes = set(forest['root'])
    for n in forest['children']:
        nodes = nodes.union(set([n] + forest['children'][n]))
    return list(nodes)


def prune_nodes(tree, node):
    # run through the three and remove all the descendants of the node

    stack = [node]
    to_be_removed = []
    while len(stack) > 0:
        current = stack.pop()
        to_be_removed.append(current)
        for t in tree:
            if t == current:
                stack += tree[current]

    to_be_removed = set(to_be_removed)
    tree = {n: list(set(c) - to_be_removed) for n, c in tree.items() if
            n not in to_be_removed}
    return tree, to_be_removed


def random_prune(tree, p=0.5, keep_all_roots=False):
    '''
    prunes a conversation tree randomly.
    '''

    # produce a random sorting of the utterances
    nodes_list = get_all_nodes(tree)
    random.shuffle(nodes_list)
    removed = set()
    k = 0

    roots_left = set(tree['root'])
    tree_left = tree['children'].copy()

    # remove, starting from the beginning, the utterances until you are left with p*N nodes.
    while (len(removed) / len(nodes_list)) < p and k != len(nodes_list):
        if nodes_list[k] in tree['root'] and (len(roots_left) == 1 or keep_all_roots):
            pass
        else:
            tree_left, tbr = prune_nodes(tree_left, nodes_list[k])
            removed = removed.union(tbr)
            roots_left = roots_left - {nodes_list[k]}
        k += 1

    return {'root': list(roots_left), 'children': tree_left}


def compare_trees(t1, t2):
    li = len(set(t1['root']).intersection(set(t2['root'])))
    if len(t1['root']) != li or len(t2['root']) != li:
        return False
    nodes1 = set(t1['children'].keys())
    nodes2 = set(t2['children'].keys())
    linodes = len(nodes1.intersection(nodes2))
    if len(nodes1) != linodes or len(nodes2) != linodes:
        return False

    for n in nodes1:
        children1 = set(t1['children'][n])
        children2 = set(t2['children'][n])
        lic = len(children1.intersection(children2))
        if lic != len(children1) or lic != len(children2):
            return False

    return True


def get_convs(conv_type="forward"):
    with open("../data/conv_annotations.json", "r") as read_file:
        conv_annotations = json.load(read_file)

    convs = {}
    for c in conv_annotations:
        adjMatrix = np.array(c['links'])
        idx = str(c['number'])
        roots = [e for e, i in enumerate(adjMatrix) if np.all(i == 0)]
        leaves = [e for e, i in enumerate(adjMatrix.T) if np.all(i == 0)]

        parents = {e: list(np.where(i == 1)[0]) for e, i in enumerate(adjMatrix)}
        children = {e: list(np.where(i == 1)[0]) for e, i in enumerate(adjMatrix.T)}
        convs[idx] = {'root': roots, 'leaves': leaves, 'children': children, 'parents': parents}

    return convs


def compute_measure(measure, runs, qrels):
    if measure == 'NDCG_cut_5':
        pytrec_label1 = 'ndcg_cut.5'
        pytrec_label2 = 'ndcg_cut_5'
    if measure == 'NDCG_cut_3':
        pytrec_label1 = 'ndcg_cut.3'
        pytrec_label2 = 'ndcg_cut_3'
    if measure == 'P_cut_3':
        pytrec_label1 = 'P.3'
        pytrec_label2 = 'P_3'
    if measure == 'P_cut_1':
        pytrec_label1 = 'P.1'
        pytrec_label2 = 'P_1'

    evaluator = pytrec_eval.RelevanceEvaluator(qrels, {pytrec_label1})
    measures_orig = {rid: {t: res[pytrec_label2] for t, res in evaluator.evaluate(run).items()} for rid, run in
                     runs.items()}

    measures = {}
    for runID in runs:
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

    return measures
