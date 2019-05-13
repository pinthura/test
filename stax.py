import pandas as pd

#import csv
data = pd.read_csv('D:\Stax\dataprep_testdata_praz\dataprep_testdata.csv')

#Check Data set
data.info()
data.head()

#Identify unique elements in geounit.
data["geounit"].unique()

#remove noise and tidy geounit 
#method 1
data["geounit1"]=data["geounit"].str.replace(r'\D+','')
#method 2
tran={"*":"","@":"","%":"","~":"","^":"","&":"","$":"","#":"","!":"","(":"",")":""}
tt="abc".maketrans(tran)
data["geounit"]=data["geounit"].str.translate(tt)

#create region and sub region variables
data['region']=data["geounit"].str[0:2]
data['subregion']=data["geounit"].str[0:5]

#fill in with leading zeros where nessecery
data["geounit"] = pd.to_numeric(data["geounit"])
data["geounit"]= data["geounit"].apply(lambda x: '{0:0>12}'.format(x))

# check for maximum distance recorded
list=data.distance.unique()
list.sort()
list[len(list)-2]

#create categorical variable for distance
data['dist'] = pd.cut(data.distance,
                        bins=[0, 20, 40, 60, 80, 100, 120, 99999], 
                        labels=['dist_0_20', 'dist_20_40', 'dist_40_60', 'dist_60_80', 'dist_80_100','dist_100_120','unreported'],
                        include_lowest=True)

#create frequency cross tabulation between region and distance
final=pd.crosstab(data.region, data.dist)
final

final2=pd.crosstab(data.region, data.dist,data.distance, aggfunc="sum")
final2


#export result
final.to_csv (r'D:\Stax\dataprep_testdata_praz\distance_by_region.csv', header=True)


