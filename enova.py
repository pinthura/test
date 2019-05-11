#SQL vs pandas tute https://medium.com/jbennetcodes/how-to-rewrite-your-sql-queries-in-pandas-and-more-149d341fc53e


import pandas as pd
import numpy as np
tr=pd.read_csv(r'D:\enova\Assessment_Files\Assessment_Files\training.csv')
tr.info()
a=tr.describe() #descriptive statistics only numerical variables

#clean variable with characters other than 0-9 and .
tr['Measurements2'] = tr['Measurements'].str.replace(r'[^.0-9]', ',')

#split the Measurements variable in to 3 columns
tr['length'],tr['width'],tr['hight']=tr['Measurements2'].str.split(',',2).str
cols=['length','width','hight']
tr[cols]=tr[cols].apply(pd.to_numeric)
del cols
#del tr['depth']


#! pip install pandasql
import pandasql as ps
q = """SELECT Shape ,count(0) as count FROM tr group by Shape;"""
print(ps.sqldf(q, locals()))

#remove white space
tr['Shape1'] = tr['Shape'].str.replace(r'\s+', '')

tr['Shape2'] = pd.np.where(tr.Shape1.str.contains('Marquis|Marwuise'),'Marquise',
  pd.np.where(tr.Shape1.str.contains('ROUND'),'Round',tr['Shape1']))
tr['Shape']=tr['Shape2']
del (tr['Shape1'], tr['Shape2'])

q1="""SELECT Cut ,count(0) as count FROM tr group by Cut;"""
print(ps.sqldf(q1, locals()))

#tr['Cert']=tr.Cert.fillna('None')
tr['Clarity1'] = pd.np.where(tr.Clarity.str.contains('N'),'None',tr['Clarity'])
tr['Color']=tr["Color"].str[0:1] #remove variations of the main color
tr.Fluroescence1.unique()
tr['Fluroescence1'] = pd.np.where(tr['Fluroescence']==' ','None',tr['Fluroescence'] )
tr['Fluroescence1'] = pd.np.where(tr['Fluroescence1']=='','None',tr['Fluroescence1'] )
tr['Fluroescence1'] = tr.Fluroescence1.fillna('None') #change NAN values to some other value
tr['Fluroescence1'] =tr['Fluroescence'].replace(r' ', , regex=True) #change white space values to some nan
tr['Fluroescence1'] = pd.np.where(tr['Fluroescence']==' ',np.nan,tr['Fluroescence'] )
