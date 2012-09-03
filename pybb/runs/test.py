import ghmm
import numpy
import random

numModels = 1
states = 5
obs = 2
f = ghmm.Float()
pi = [0.1] * states

aMat = numpy.zeros((states, states), float)
bMat = numpy.zeros((states, obs), float)

for i in range(states):
    for j in range(states):
        aMat[i][j] = random.random()
    for j in range(obs):
        bMat[i][j] = random.random()
bMat[0][0] = 5
bMat[0][1] = 3
model = ghmm.HMMFromMatrices(f, ghmm.GaussianDistribution(f), aMat, bMat, pi)



            
