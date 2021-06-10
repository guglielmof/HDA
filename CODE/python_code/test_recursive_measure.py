import numpy.random as npr
import numpy as np
measures = npr.rand(10)

'''
the structure forest contains, for each node, its childrens in the conversation.

Assume the following structure
0       4     
|\    / | \   
1 2  5  6  7  
|          |
3          8
           | 
           9
'''

roots = [0, 4]
forest = {0: [1, 2], 1:[3], 4:[5, 6, 7], 7:[8], 8:[9]}

'''
ALGORITHM:
    put the roots in the stack
    
    do it until there are nodes into the stack
        look at the first node of the stack
            if you can compute its value:
                compute the value and remove the node from the stack
            else:
                put each of its childrens into the stack
'''

alpha = 0.5
scores = [np.NaN for i in range(len(measures))]

stack = [r for r in roots]
while len(stack)>0:
    node = stack[0]
    if node not in forest or forest[node]==[]:
        scores[node] = measures[node]
        stack = stack[1:]
    else:
        children = forest[node]
        computable = True
        for c in children:
            if np.isnan(scores[c]):
                stack = [c]+stack
                computable = False

        if computable:
            scores[node] = alpha*(measures[node])+(1-alpha)*(np.mean([scores[c] for c in children]))
            stack = stack[1:]

print(np.mean(scores))
print(np.mean(measures))