#dependencies

import os
import pandas as pd
import numpy as np
import time

path = "../AdminInterface/output.csv"
cols="""duration,
protocol_type,
service,
flag,
src_bytes,
dst_bytes,
land,
wrong_fragment,
urgent,
hot,
num_failed_logins,
logged_in,
num_compromised,
root_shell,
su_attempted,
num_root,
num_file_creations,
num_shells,
num_access_files,
num_outbound_cmds,
is_host_login,
is_guest_login,
count,
srv_count,
serror_rate,
srv_serror_rate,
rerror_rate,
srv_rerror_rate,
same_srv_rate,
diff_srv_rate,
srv_diff_host_rate,
dst_host_count,
dst_host_srv_count,
dst_host_same_srv_rate,
dst_host_diff_srv_rate,
dst_host_same_src_port_rate,
dst_host_srv_diff_host_rate,
dst_host_serror_rate,
dst_host_srv_serror_rate,
dst_host_rerror_rate,
dst_host_srv_rerror_rate"""

columns=[]
for c in cols.split(','):
    if(c.strip()):
       columns.append(c.strip())
df = pd.read_csv(path,names=columns)
num_cols = df._get_numeric_data().columns
cate_cols = list(set(df.columns)-set(num_cols))
df = df[[col for col in df if df[col].nunique() > 1]]
df.drop('num_root',axis = 1,inplace = True)
df.drop('srv_serror_rate',axis = 1,inplace = True)
df.drop('srv_rerror_rate',axis = 1, inplace=True)
df.drop('dst_host_srv_serror_rate',axis = 1, inplace=True)
df.drop('dst_host_serror_rate',axis = 1, inplace=True)
df.drop('dst_host_rerror_rate',axis = 1, inplace=True)
df.drop('dst_host_srv_rerror_rate',axis = 1, inplace=True)
df.drop('dst_host_same_srv_rate',axis = 1, inplace=True)
pmap = {'icmp':0,'tcp':1,'udp':2}
df['protocol_type'] = df['protocol_type'].map(pmap)
fmap = {'SF':0,'S0':1,'REJ':2,'RSTR':3,'RSTO':4,'SH':5 ,'S1':6 ,'S2':7,'RSTOS0':8,'S3':9 ,'OTH':10}
df['flag'] = df['flag'].map(fmap)
df.drop('service',axis = 1,inplace= True)

from sklearn.preprocessing import LabelEncoder
l=LabelEncoder()
l.fit_transform(df["Attack Type","protocol_type"])
from sklearn.preprocessing import MinMaxScaler
sc = MinMaxScaler()
X = sc.fit_transform(df)

import tensorflow as tf
from tensorflow.keras.models import load_model

gg = load_model("/kaggle/working/model1.h5")

start_time = time.time()
figam=gg.predict(X)
end_time = time.time()

print(figam.mean())

label_encoder = LabelEncoder()
label_encoder.classes_ = np.array(['dos','normal','u2r', 'r2l', 'probe', 'dos'])

predicted_labels = label_encoder.inverse_transform(figam.argmax(axis=1))

print(predicted_labels)
