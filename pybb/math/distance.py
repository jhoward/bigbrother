import numpy

def mahalanobis(x, y, useY = False):
    """
    mahalanobis(x, y, ci)

    Computes the Mahalanobis distance between a n rows by m columns
    list and another similar list of points y (y must have m columns).

    (mean(y) - mean(x))ci(mean(y) - mean(x))^T
    where ci is the inverse covariance matrix of x.
      
    Returns a list of the mahalnobis distances where the length of the list 
    is equal to the number of rows in y.
    """
    x = numpy.asarray(x)
    y = numpy.asarray(y)
    
    #Inverse covariance matrix
    xci = numpy.cov(x.T, bias = 1)
    
    if useY:
        yci = numpy.cov(y.T, bias = 1)
        total = x.shape[0] + y.shape[0]
        ci = (x.shape[0]/(total * 1.0) * xci) + (y.shape[0]/(total * 1.0)) * yci
    else:
        ci = xci
    
    ci = numpy.linalg.pinv(ci)
    ci = numpy.asarray(ci)
    
    #means
    xm = x.mean(axis = 0)
    ym = y.mean(axis = 0)

    return numpy.dot(numpy.dot((ym - xm), ci), (ym - xm).T)**0.5
    

def testMahalanobis():
    """
    test()
    
    from http://people.revoledu.com/kardi/tutorial/Similarity/MahalanobisDistance.html
    
    used to determine if calculation of mahalanobis is correct.
    
    Answer should be 1.41
    """
    
    x = [[2, 2], [2, 5], [6, 5], [7, 3], [4, 7], [6, 4], [5, 3], [4, 6], \
            [2, 5], [1, 3]]
    
    y =  [[6, 5], [7, 4], [8, 7], [5, 6], [5, 4]]
    
    print mahalanobis(x, y)


if __name__ == "__main__":
    testMahalanobis()