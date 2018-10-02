"""
    Filename:       version.py
    Author:         Samantha Emily-Rachel Belnavis
    Date:           June 23, 2018
    Description:    Prints out useful debugging info
"""

# import required packages
import sys
import os
import scipy
import numpy
import matplotlib
import pandas
import sklearn

# clear console
os.system('clear')

# print out system debug info
print('Python: {}'.format(sys.version))
print('scipy: {}'.format(scipy.__version__))
print('numpy: {}'.format(numpy.__version__))
print('matplotlib: {}'.format(matplotlib.__version__))
print('pandas: {}'.format(pandas.__version__))
print('sklearn: {}'.format(sklearn.__version__))
