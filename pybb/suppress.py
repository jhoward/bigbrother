"""
supress.py

Author: James Howard

Supress the output of a external module.
TODO add windows support.
"""
import os

fd = os.dup(1)

def suppress(fdNum = 1):
    """Suppresses output of a file descriptor. 
    
    fdNum = 1 -- Suppresses normal output
    fdNum = 2 -- Suppresses exception output
    """
    
    if fdNum == 1:
        print ""
    fd = os.dup(fdNum)
    
    d = os.open(os.devnull, os.O_WRONLY)
    
    os.dup2(d, fdNum)
    os.close(d)

    
def restore(fdNum = 1):
    """Restores output of any suppressed file descriptor.
    """
    os.dup2(fd, fdNum)
    
    
if __name__ == "__main__":
    print "before"
    suppress(1)
    print "inside"
    restore(1)
    print "after"