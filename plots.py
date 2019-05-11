# -*- coding: utf-8 -*-
"""
Created on Sat May 11 11:00:25 2019

@author: Kavisha
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
plt.close('all')

ts = pd.Series(np.random.randn(1000), index=pd.date_range('1/1/2000', periods=1000))
ts = ts.cumsum()
ts.plot()

df3 = pd.DataFrame(np.random.randn(1000, 2), columns=['B', 'C']).cumsum()
df3['A'] = pd.Series(list(range(len(df3))))
df3.plot(x='A', y='B')

df2 = pd.DataFrame(np.random.rand(10, 4), columns=['a', 'b', 'c', 'd'])
df2.plot.bar()
df3.plot.hist('B')
