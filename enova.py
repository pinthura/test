#SQL vs pandas tute https://medium.com/jbennetcodes/how-to-rewrite-your-sql-queries-in-pandas-and-more-149d341fc53e


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt   #Data visualisation libraries 
import seaborn as sns
#! pip install pandasql
import pandasql as ps

tr=pd.read_csv(r'D:\enova\Assessment_Files\Assessment_Files\training.csv')
tr.info()
a=tr.describe() #descriptive statistics only numerical variables
tr.columns

#clean variable with characters other than 0-9 and .
tr['Measurements2'] = tr['Measurements'].str.replace(r'[^.0-9]', ',')

#split the Measurements variable in to 3 columns
tr['length'],tr['width'],tr['hight']=tr['Measurements2'].str.split(',',2).str
cols=['length','width','hight']
tr[cols]=tr[cols].apply(pd.to_numeric)
del cols
del (tr['Measurements'], tr['Measurements2'])

tr['Profit']=tr['Retail']-tr['Price']
tr['Profit_flg'] = pd.np.where(tr['Profit']>=0,1,0)


sns.pairplot(tr)
sns.distplot(tr['Price'])
sns.distplot(tr['Retail'])
plt.box(tr['Retail'])
plt.scatter(tr['Carats'],tr['Price'])
sns.catplot(x="Vendor", y="Price", hue="Polish1", kind="swarm", data=tr)
corr=tr.corr() #correlation
# plot the heatmap
sns.heatmap(corr, xticklabels=corr.columns, yticklabels=corr.columns)

tr['Cart'] = pd.cut(tr.Carats,
                        bins=[0, 0.5, 1, 1.5, 2, 3, 4, 5,15], 
                        labels=['0_0.5', '0.5_1', '1-1.5', '1.5-2', '2-3','3-4','4-5','5+'],
                        include_lowest=True)

final=pd.crosstab(tr.Vendor, tr.Cart,tr.Price, aggfunc="mean")
final

final2=pd.crosstab(tr.Cert, tr.Cart,tr.Profit_flg, aggfunc="sum")
final2

q = """SELECT Cert , Profit_flg ,avg(Profit) as Avg_Profit ,count(0) as freq FROM tr group by Cert , Profit_flg;"""
print(ps.sqldf(q, locals()))

q = """SELECT Vendor , Cart ,avg(Price) as Avg_Pr ,count(0) as freq FROM tr group by Vendor, Cart;"""
print(ps.sqldf(q, locals()))
q = """SELECT Shape ,count(0) as count FROM tr group by Shape;"""
print(ps.sqldf(q, locals()))

#remove white space
tr['Shape1'] = tr['Shape'].str.replace(r'\s+', '')

tr['Shape2'] = pd.np.where(tr.Shape1.str.contains('Marquis|Marwuise'),'Marquise',
  pd.np.where(tr.Shape1.str.contains('ROUND'),'Round',tr['Shape1']))
tr['Shape']=tr['Shape2']
del (tr['Shape1'], tr['Shape2'])

q1="""SELECT Cert ,Vendor ,count(0) as count FROM tr group by Cert, Vendor;"""
print(ps.sqldf(q1, locals()))

tr['Cert']=tr.Cert.fillna('None')
tr['Clarity1'] = pd.np.where(tr.Clarity.str.contains('N'),'None',tr['Clarity'])
tr['Color']=tr["Color"].str[0:1] #remove variations of the main color
tr.Fluroescence1.unique()
tr['Fluroescence1'] = pd.np.where(tr['Fluroescence']==' ','None',tr['Fluroescence'] )
tr['Fluroescence1'] = pd.np.where(tr['Fluroescence1']=='','None',tr['Fluroescence1'] )
tr['Fluroescence1'] = tr.Fluroescence1.fillna('None') #change NAN values to some other value
tr['Fluroescence1'] = pd.np.where(tr['Fluroescence']==' ',np.nan,tr['Fluroescence'] )
tr['Fluroescence1'] = pd.np.where(tr['Fluroescence1']=='',np.nan,tr['Fluroescence1'] )
tr['Polish1'] = pd.np.where(tr['Polish']==' ','None',tr['Polish'] )

X=tr[['length',]]
Y=tr[['Price']]
from sklearn.linear_model import LinearRegression
lm = LinearRegression()
lm.fit(X,Y)

from sklearn.tree import DecisionTreeClassifier, export_graphviz
y = tr["Profit_flg"]
X = tr[["Cert","Cart","Cut","Shape","Table","Symmetry","Regions","Shape","Vendor","Polish1"]]
dt = DecisionTreeClassifier(min_samples_split=20, random_state=99)
dt.fit(X, y)
