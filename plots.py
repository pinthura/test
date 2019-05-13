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
df2.plot.bar(stacked=True)
df2.plot.barh(stacked=True) #horizontal

df4 = pd.DataFrame({'a': np.random.randn(1000) + 1, 'b': np.random.randn(1000),
                    'c': np.random.randn(1000) - 1}, columns=['a', 'b', 'c'])
plt.figure()
df4.plot.hist(alpha=0.5)

#bringing the lag
df2['d2']=df2.d.shift()

# initialize list of lists 
data = [['tom', 10], ['nick', 15], ['juli', 14]] 
# Create the pandas DataFrame 
df = pd.DataFrame(data, columns = ['Name', 'Age']) 
df

#transpose of a df
result = df.transpose() 
result





