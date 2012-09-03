"""
File: lsa.py
Author: James Howard

Performs both standard latent semantic analysis using numpy's singular value 
decomposition of a matrix and probabilistic latent semantic analysis.

A tdMatrix is of the form N x M where each N_i in N corresponds to a word
in the dictionary and each M_i in M corresponds to a given document.

TODO: Add dirchilet semantic analysis and modified plsa with a longer history.
"""

import pybb.data.dataio as dataio
import numpy
import random

def lsa(tdMatrix):
    """Calculate the singular value decomosition of the tdMatrix.
    
    u corresponds to a orthogonal set of vectors that can best be used to 
    reconstruct the original documents.
    
    s corresponds to the diagonal matrix indicating the strength of the 
    orthogonal vectors.
    
    vh corresponds to a orthogonal set of vectors that can be used to 
    reconstruct a given word from the set of documents.
    """
    u, s, vh = numpy.linalg.svd(tdMatrix, full_matrices = 0)

    return u, s, vh
    
    
def lda(tdm, numTopics):
    """Latent dirichlet analysis
    
    TODO: Make"""
    pass

    
def plsa(tdMatrix, numTopics, iterations = 500, stopThreshold = None):
    """Performs a plsa on a given tdMatrix.
    
    tdMatrix must be an ARRAY (not matrix) of dimensions Words By Documents
    
    TODO: Implement stopping threshold.
    """

    pz = numpy.zeros((numTopics, 1), float)
    pwz = numpy.zeros((tdMatrix.shape[0], numTopics), float)
    pdz = numpy.zeros((tdMatrix.shape[1], numTopics), float)
    pzdw = numpy.zeros((numTopics, tdMatrix.shape[1], tdMatrix.shape[0]), float)
    normConst = sum(sum(tdMatrix))

    pz, pwz, pdz, pzdw = _initArrays(pz, pwz, pdz, pzdw)
    pz, pwz, pdz, pzdw = _normalizeArrays(pz, pwz, pdz, pzdw)

    for i in range(iterations):
        pzdw = _calcPZDW(pz, pwz, pdz, pzdw)
        pz, pwz, pdz = _calcArrays(tdMatrix, normConst, pz, pwz, pdz, pzdw)
        print str(i) + "    " + str(pz)

    pzd = _convertPDZ(pdz, pz)
    
    return pz, pwz, pdz, pzd, pzdw


def _convertPDZ(pdz, pz):
    
    pzd = pdz.copy()
    
    for i in range(pzd.shape[0]):
        for j in range(pzd.shape[1]):
            pzd[i][j] /= pz[j]
            
        pzd[i, :] /= pzd.sum(1)[i]
        
    return pzd

    
def _initArrays(pz, pwz, pdz, pzdw):
    #Initialize the arrays
    for i in range(pz.shape[0]):
        pz[i] = random.random()
        #pz[i] = 0.1
        
    for i in range(pwz.shape[0]):
        for j in range(pwz.shape[1]):
            pwz[i][j] = random.random()
            #pwz[i][j] = 0.2
    
    for i in range(pdz.shape[0]):
        for j in range(pdz.shape[1]):
            pdz[i][j] = random.random()
            #pdz[i][j] = 0.3
            
    for i in range(pzdw.shape[0]):
        for j in range(pzdw.shape[1]):
            for k in range(pzdw.shape[2]):
                pzdw[i][j][k] = random.random()
                #pzdw[i][j][k] = 0.5
                
    return pz, pwz, pdz, pzdw


def _normalizeArrays(pz, pwz, pdz, pzdw):
    """
    Normalize all arrays
    """
    normConstant = sum(pz)
    pz = pz/normConstant
    
    normConstant = sum(pwz)
    pwz = pwz / numpy.tile(normConstant, (pwz.shape[0], 1))
    
    normConstant = sum(pdz)
    pdz = pdz / numpy.tile(normConstant, (pdz.shape[0], 1))
    
    return pz, pwz, pdz, pzdw

    
    
def _calcPZDW(pz, pwz, pdz, pzdw, beta = 1):

    #First calculate the normalizations.
    tilePZ = numpy.tile(pz.transpose(), (pzdw.shape[2], pzdw.shape[1], 1)).transpose()
    tilePDZ = numpy.tile(pdz, (pzdw.shape[2], 1, 1)).transpose()
    tilePWZ = numpy.tile(pwz.transpose(), (pzdw.shape[1], 1, 1)).transpose(1, 0, 2)
    pzdw = tilePZ * tilePDZ * tilePWZ

    #Included to remove the accidental divide by zero errors.  Only occurs
    #when a given pattern has not appeared in a given timeframe.
    pzdw += 0.0000001
    normConstant = sum(pzdw)
    normConstant = numpy.tile(normConstant, (pzdw.shape[0], 1, 1))
    
    pzdw = pzdw/normConstant
    return pzdw
    
    
def _calcArrays(tdMatrix, normConst, pz, pwz, pdz, pzdw):
    tileTD = numpy.tile(tdMatrix, (pzdw.shape[0], 1, 1))
    tileTD = tileTD.transpose(0, 2, 1)

    #Update pwz
    pwz = numpy.sum(tileTD * pzdw, axis = 1).transpose()
    normConstant = sum(pwz)
    pwz = pwz / numpy.tile(normConstant, (pwz.shape[0], 1))
    
    pdz = numpy.sum(tileTD * pzdw, axis = 2).transpose()
    normConstant = sum(pdz)
    pdz = pdz / numpy.tile(normConstant, (pdz.shape[0], 1))
    
    pz = numpy.sum(numpy.sum(tileTD * pzdw, axis = 1), axis = 1).transpose()
    pz = pz/normConst
    
    return pz, pwz, pdz


    
    
