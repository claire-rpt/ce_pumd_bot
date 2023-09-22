from mastodon import Mastodon
import pandas as pd
import numpy as np
from random import sample

#set up Mastodon
mastodon = Mastodon(
    access_token = '',
    api_base_url = 'https://botsin.space/'
)

#import bls interview-level data and add state name
state_fips = pd.read_csv("state_fips.csv",index_col=0)
expenditure_names = pd.read_csv("expenditure_names.csv",index_col=0)
bls_format = pd.read_csv("bls_format.csv",index_col=0)
bls_format = pd.merge(bls_format,state_fips,on='STATE',how='left')

#family type variable
fam_type_code = [1,2,3,4,5,6,7,8,9]
fam_type_desc = ["married","married","married","married","married","single","single","single","single"]
fam_type = pd.DataFrame({
    'FAM_TYPE' : fam_type_code,
    'description' : fam_type_desc
})
bls_format = pd.merge(bls_format,fam_type,on='FAM_TYPE',how='left')

#create data frame for expenditure names
expenditure_names.set_index("column_numbers")["column_names"]
b = expenditure_names['column_numbers'].tolist()
c = []
for i in b:
    c.append(i-1)
d = bls_format.columns[c]
d = d.tolist()
expenditure_names["variable_names"] = d

#select individual
indv = bls_format.sample()

#select individual
indv = bls_format.sample()

#default demographic stats
indv.state = indv['s_names'].values[0]
indv.age = indv['AGE_REF'].values[0]
indv.marst = indv['description'].values[0]
indv.children = indv['PERSLT18'].values[0]

#default money stats
indv.food = round(indv['FDHOMECQ'].values[0],0)
indv.transportation = round(indv['ETRANPTC'].values[0],0)
indv.income = round(indv['FINCBTXM'].values[0],0)
indv.healthcare = round(indv['HEALTHCQ'].values[0],0)

#calculate mortgage, property taxes, & rent costs
indv["mortgage_rent"] = indv["EMRTPNOC"]+indv["MRTINTCQ"]+indv["RENDWECQ"]+indv["PROPTXCQ"]
indv.housing = round(indv['mortgage_rent'].values[0],0)
print(indv.housing)

#dynamic reference for variable expenditure pool
a = ["FDXMAPCQ","ALCBEVCQ","APPARCQ","EENTRMTC","PERSCACQ","READCQ",
           "EDUCACQ","TOBACCCQ","CASHCOCQ","LIFINSCQ","RETPENCQ"]
b = []
for i in a:
    c = bls_format.columns.get_loc(i)
    b.append(c)
print(b)

#function to select 3 non-zero expenditures from variable expenditure pool
def select_var_exp(df):
    df = df.iloc[:,b]
    #print(df)
    df = df.loc[:,(df!=0).any(axis=0)]
    df = df.transpose(copy=False)
    df.rename(columns={df.columns[0]:'expenditure_amt'},inplace=True)
    df['variable_names']=df.index
    df = df.sample(3)
    return df

variable_exp = select_var_exp(indv)
variable_exp = pd.merge(variable_exp,expenditure_names,on='variable_names',how='left')

var1_name = variable_exp['column_names'].loc[variable_exp.index[0]]
var2_name = variable_exp['column_names'].loc[variable_exp.index[1]]
var3_name = variable_exp['column_names'].loc[variable_exp.index[2]]
var1_val = round(variable_exp['expenditure_amt'].loc[variable_exp.index[0]],0)
var2_val = round(variable_exp['expenditure_amt'].loc[variable_exp.index[1]],0)
var3_val = round(variable_exp['expenditure_amt'].loc[variable_exp.index[2]],0)

#print function
print("I am {} and live in {}. I am {} with {} children at home.\nMy annual income is ${}. My monthly budget is \nMortgage or rent: ${}\nGroceries: ${}\nHealth care: ${}\nTransportation: ${}\n{}: ${}\n{}: ${}\n{}: ${}".format(indv.age,indv.state,indv.marst,indv.children,indv.income,indv.housing,indv.food,indv.healthcare,indv.transportation,var1_name,var1_val,var2_name,var2_val,var3_name,var3_val))


#status post
a = "I am {} and live in {}. I am {} with {} children at home.\nMy annual income is ${}. My monthly budget is \nMortgage or rent: ${}\nGroceries: ${}\nHealth care: ${}\nTransportation: ${}\n{}: ${}\n{}: ${}\n{}: ${}".format(indv.age,indv.state,indv.marst,indv.children,indv.income,indv.housing,indv.food,indv.healthcare,indv.transportation,var1_name,var1_val,var2_name,var2_val,var3_name,var3_val)
mastodon.status_post(a)
