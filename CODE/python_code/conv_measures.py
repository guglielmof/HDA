import numpy as np


def recursive_measure(conv_struct, measures, alpha, default_alpha=True, aggregator=np.mean):
    scores = [np.NaN for i in range(len(measures))]

    stack = [r for r in conv_struct['root']]
    while len(stack) > 0:
        node = stack[0]
        if conv_struct['children'][node] == []:
            scores[node] = (alpha if default_alpha else 1) * measures[node]
            stack = stack[1:]
        else:
            children = conv_struct['children'][node]
            computable = True
            for c in children:
                if np.isnan(scores[c]):
                    stack = [c] + stack
                    computable = False

            if computable:
                scores[node] = alpha * (measures[node]) + (1 - alpha) * (aggregator([scores[c] for c in children]))
                stack = stack[1:]

    return scores


def recursive_inverse_measure(conv_struct, measures, alpha, default_alpha=True, aggregator=np.mean):
    scores = [np.NaN for i in range(len(measures))]

    queue = list(conv_struct['parents'].keys())

    while len(queue) > 0:
        node = queue[0]
        if conv_struct['parents'][node] == []:
            scores[node] = (alpha if default_alpha else 1) * measures[node]
            queue = queue[1:]
        else:
            parents = conv_struct['parents'][node]
            computable = True
            for c in parents:
                if np.isnan(scores[c]):
                    computable = False
                    queue = queue[1:] + [node]

            if computable:
                scores[node] = alpha * (measures[node]) + (1 - alpha) * (aggregator([scores[c] for c in parents]))
                queue = queue[1:]

    return scores


def distance_from_root(conv_struct, measures, alpha):
    scores = [np.NaN for i in range(len(measures))]
    queue = list(conv_struct['parents'].keys())

    weights = {}

    for node in queue:
        tot_p = len(conv_struct['parents'][node])
        stack = conv_struct['parents'][node].copy()
        visited = set()
        while len(stack) > 0:
            p = stack[0]
            stack = stack[1:]
            if p not in visited:
                visited.add(p)
                not_visited = list(set(conv_struct['parents'][p]).difference(visited))
                stack = not_visited + stack
                tot_p += len(conv_struct['parents'][p])

        weights[node] = tot_p
    tot_w = np.sum([alpha ** w for _, w in weights.items()])
    for node in queue:
        scores[node] = measures[node] * alpha ** weights[node] / tot_w * len(queue)

    return scores


def markov_recursive(conv_struct, measures, alpha=None, aggregator=np.mean):
    scores = [np.NaN for i in range(len(measures))]

    stack = [r for r in conv_struct['root']]
    while len(stack) > 0:
        node = stack[0]
        if conv_struct['children'][node] == []:
            scores[node] = measures[node]
            stack = stack[1:]
        else:
            children = conv_struct['children'][node]
            computable = True
            for c in children:
                if np.isnan(scores[c]):
                    stack = [c] + stack
                    computable = False

            if computable:
                scores[node] = (measures[node]) + (1 - measures[node]) * (aggregator([scores[c] for c in children]))
                stack = stack[1:]

    return scores


def markov_recursive_inverse(conv_struct, measures, alpha=None, aggregator=np.mean):
    scores = [np.NaN for i in range(len(measures))]

    queue = list(conv_struct['parents'].keys())

    while len(queue) > 0:
        node = queue[0]
        if conv_struct['parents'][node] == []:
            scores[node] = measures[node]
            queue = queue[1:]
        else:
            parents = conv_struct['parents'][node]
            computable = True
            for c in parents:
                if np.isnan(scores[c]):
                    computable = False
                    queue = queue[1:] + [node]

            if computable:
                scores[node] = measures[node] + (1 - measures[node]) * (aggregator([scores[c] for c in parents]))
                queue = queue[1:]

    return scores


def markov_recursive_inverse_II(conv_struct, measures, alpha=None, aggregator=np.mean):
    scores = [np.NaN for _ in range(len(measures))]
    pexit = [np.NaN for _ in range(len(measures))]
    queue = list(conv_struct['parents'].keys())

    while len(queue) > 0:
        node = queue[0]
        if conv_struct['parents'][node] == []:
            pexit[node] = 1 - measures[node]
            queue = queue[1:]
        else:
            parents = conv_struct['parents'][node]
            computable = True
            for c in parents:
                if np.isnan(pexit[c]):
                    computable = False
                    queue = queue[1:] + [node]

            if computable:
                pexit[node] = np.mean(
                    [pexit[p] * (1 / len(conv_struct['children'][p])) * (1 - measures[node]) for p in parents])
                queue = queue[1:]

    for node in conv_struct['parents'].keys():

        if conv_struct['parents'][node] == []:
            scores[node] = measures[node]

        else:
            scores[node] = measures[node] * np.mean(
                [pexit[p] / (len(conv_struct['children'][p])) for p in conv_struct['parents'][node]])
    return scores


def identity(conv_struct, measures, alpha=None, aggregator=np.mean):
    scores = [measures[i] for i in range(len(measures))]

    return scores


def hrbp_f(conv_struct, measures, alpha, aggregator=np.mean):
    scores = [np.NaN for _ in range(len(measures))]

    queue = list(conv_struct['parents'].keys())

    while len(queue) > 0:
        node = queue[0]
        if conv_struct['children'][node]==[]:
            scores[node] = measures[node]
            queue = queue[1:]
        else:
            children = conv_struct['children'][node]
            computable = True
            for c in children:
                if np.isnan(scores[c]):
                    computable = False
                    queue = queue[1:] + [node]
                    break

            if computable:
                scores[node] = (measures[node] + alpha * (aggregator([scores[c] for c in children]))) / (1 + alpha)
                queue = queue[1:]

    return scores


def hrbp_b(conv_struct, measures, alpha, aggregator=np.mean):
    scores = [np.NaN for _ in range(len(measures))]

    queue = list(conv_struct['parents'].keys())

    while len(queue) > 0:
        node = queue[0]
        if conv_struct['parents'][node]==[]:
            scores[node] = measures[node]
            queue = queue[1:]
        else:
            parents = conv_struct['parents'][node]
            computable = True
            for p in parents:
                if np.isnan(scores[p]):
                    computable = False
                    queue = queue[1:] + [node]
                    break

            if computable:
                scores[node] = (measures[node] + alpha * (aggregator([scores[p] for p in parents]))) / (1 + alpha)
                queue = queue[1:]

    return scores
