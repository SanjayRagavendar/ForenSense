# # app.py
# from flask import Flask, render_template, redirect, url_for, request, session
# from flask_bootstrap import Bootstrap
# import psutil

# app = Flask(__name__)
# app.config['SECRET_KEY'] = 'your_secret_key'
# Bootstrap(app)

# # Hardcoded admin credentials (replace with a proper authentication system)
# ADMIN_USERNAME = 'admin'
# ADMIN_PASSWORD = 'admin'

# @app.route('/')
# def login():
#     return render_template('login.html')

# @app.route('/dashboard')
# def dashboard():
#     if 'username' in session and session['username'] == ADMIN_USERNAME:
#         # Gather real-time system information
#         cpu_temp = 58
#         ram_usage = psutil.virtual_memory().percent
#         system_load = psutil.getloadavg()[0]

#         return render_template('dashboard.html', cpu_temp=cpu_temp, ram_usage=ram_usage, system_load=system_load)
    
#     return redirect(url_for('login'))

# @app.route('/login', methods=['POST'])
# def do_login():
#     username = request.form['username']
#     password = request.form['password']
    
#     if username == ADMIN_USERNAME and password == ADMIN_PASSWORD:
#         session['username'] = username
#         return redirect(url_for('dashboard'))
#     return redirect(url_for('login'))

# @app.route('/logout')
# def logout():
#     session.pop('username', None)
#     return redirect(url_for('login'))

# if __name__ == '__main__':
#     app.run(debug=True)

# app.py
from flask import Flask, render_template, redirect, url_for, request, session, jsonify

from flask_bootstrap import Bootstrap
import psutil
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'
Bootstrap(app)

# Hardcoded admin credentials (replace with a proper authentication system)
ADMIN_USERNAME = 'admin'
ADMIN_PASSWORD = 'admin'

alerts = []

@app.route('/')
def login():
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    if 'username' in session and session['username'] == ADMIN_USERNAME:
        # Gather real-time system information
        cpu_temp = 58
        ram_usage = psutil.virtual_memory().percent
        system_load = psutil.getloadavg()[0]

        return render_template('dashboard.html', cpu_temp=cpu_temp, ram_usage=ram_usage, system_load=system_load)
    
    return redirect(url_for('login'))

@app.route('/checksum-anomaly')
def render_log():
    log_entries = []

    # Read log entries from the log.txt file
    with open('log.txt', 'r') as log_file:
        for line in log_file:
            # Assuming the log entries are in a specific format, parse them accordingly
            parts = line.strip().split('|')
            if len(parts) == 6:
                timestamp, client_ip, file, expected_checksum, actual_checksum = [part.strip() for part in parts[1:6]]
                log_entries.append({
                    "timestamp": timestamp,
                    "client_ip": client_ip,
                    "file": file,
                    "expected_checksum": expected_checksum,
                    "actual_checksum": actual_checksum
                })

    return render_template('log_template.html', log_entries=log_entries)
@app.route('/api/checksum-anomaly', methods=['POST'])
def handle_checksum_anomaly():
    data = request.get_json()

    if data:
        log_anomaly(data)
        print("Anomaly Detected:")
        print(f'IP Address: {request.remote_addr}')
        print(f"File: {data['file']}")
        print(f"Expected Checksum: {data['expectedChecksum']}")
        print(f"Actual Checksum: {data['actualChecksum']}")
        print(f"Timestamp: {data['timestamp']}")
    else:
        print("No anomalies found.")

    return jsonify({"message": "Data received successfully"})

def log_anomaly(data):
    log_path = "log.txt"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    with open(log_path, 'a') as log_file:
        log_file.write(f"| {timestamp} | {request.remote_addr} | {data['file']} | {data['expectedChecksum']} | {data['actualChecksum']} |\n")


@app.route('/login', methods=['POST'])
def do_login():
    username = request.form['username']
    password = request.form['password']
    
    if username == ADMIN_USERNAME and password == ADMIN_PASSWORD:
        session['username'] = username
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/logout')
def logout():
    session.pop('username', None)
    return redirect(url_for('login'))

@app.route('/api/chksum', methods=['POST'])
def receive_checksum_alert():
    alert_data = request.get_data(as_text=True)
    alerts.append(alert_data)

    # Perform any additional processing or analysis based on the received alert data
    # For example, you can log the alert, send notifications, etc.

    return jsonify({"status": "Alert received successfully"})

@app.route('/alerts', methods=['GET'])
def display_alerts():
    return jsonify({"alerts": alerts})

@app.route('/api/reg', methods=['POST'])
def handle_reg():
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files['file']
    
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    file.save(f"uploads/{file.filename}")

    return jsonify({"message": "File uploaded successfully"}), 200

    

if __name__ == '__main__':
    app.run(debug=True)
