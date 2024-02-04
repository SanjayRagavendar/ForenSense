from flask import Flask, request, jsonify
import pandas as pd
import os
import numpy as np
from sklearn.preprocessing import LabelEncoder, MinMaxScaler
from tensorflow.keras.models import load_model

app = Flask(__name__)

path = "../ForenSense/kddcup.testdata.unlabeled_10_percent.gz"
cols = """duration,protocol_type,service,flag,src_bytes,dst_bytes,land,wrong_fragment,
urgent,hot,num_failed_logins,logged_in,num_compromised,root_shell,su_attempted,num_file_creations,
num_shells,num_access_files,num_outbound_cmds,is_host_login,is_guest_login,count,srv_count,serror_rate,
rerror_rate,same_srv_rate,diff_srv_rate,srv_diff_host_rate,dst_host_count,dst_host_srv_count,
dst_host_same_srv_rate,dst_host_diff_srv_rate,dst_host_same_src_port_rate,dst_host_srv_diff_host_rate,
dst_host_serror_rate,dst_host_srv_serror_rate,dst_host_rerror_rate,dst_host_srv_rerror_rate"""

columns = [c.strip() for c in cols.split(',') if c.strip()]
columns.append('target')

df = pd.read_csv(path, names=columns)

num_cols = df._get_numeric_data().columns
cate_cols = list(set(df.columns) - set(num_cols))
df = df[[col for col in df if df[col].nunique() > 1]]

df.drop(['num_root', 'srv_serror_rate', 'srv_rerror_rate', 'dst_host_srv_serror_rate',
         'dst_host_serror_rate', 'dst_host_rerror_rate', 'dst_host_srv_rerror_rate',
         'dst_host_same_srv_rate', 'service', 'dst_host_same_src_port_rate'], axis=1, inplace=True)

pmap = {'icmp': 0, 'tcp': 1, 'udp': 2}
df['protocol_type'] = df['protocol_type'].map(pmap)
fmap = {'SF': 0, 'S0': 1, 'REJ': 2, 'RSTR': 3, 'RSTO': 4, 'SH': 5, 'S1': 6, 'S2': 7, 'RSTOS0': 8, 'S3': 9, 'OTH': 10}
df['flag'] = df['flag'].map(fmap)

label_encoder = LabelEncoder()
label_encoder.classes_ = np.array(['dos', 'normal', 'u2r', 'r2l', 'probe', 'dos'])

scaler = MinMaxScaler()
X = scaler.fit_transform(df)

model = load_model("model_withattack_type.h5")

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    input_data = np.array(data['input']).reshape(1, -1)
    scaled_data = scaler.transform(input_data)
    prediction = model.predict(scaled_data)
    predicted_label = label_encoder.inverse_transform(prediction.argmax(axis=1))[0]
    return jsonify({'prediction': predicted_label})

if __name__ == '__main__':
    app.run(port=5000, debug=True)
