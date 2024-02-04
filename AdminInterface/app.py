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
from plyer import notification  # Import the plyer notification module

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

@app.route('/display-alerts-on-windows', methods=['GET'])
def display_alerts_on_windows():
    if request.method == 'GET':
        if received_strings:
            # Display a pop-up notification with received strings
            alert_message = "\n".join(received_strings)
            notification.notify(
                title='Alerts',
                message=alert_message,
                app_name='Flask Alerts',
            )
        else:
            notification.notify(
                title='No Alerts',
                message='No alerts to display',
                app_name='Flask Alerts',
            )
        return 'Alerts displayed on Windows!', 200
    else:
        return 'Method not allowed', 405
system_stats_list = []

@app.route("/report",methods=['GET'])
def handle_reg():
    return render_template("uploads/report")
    
@app.route("/reg",methods=['GET'])
def display_reg():
    with open("data.txt","r") as f:
        data=f.read()

    return render_template("reg.html",data=data)

@app.route('/api/system-stats', methods=['POST'])
def handle_system_stats():
    data = request.get_json()

    if data:
        print("System Stats Received:")
        print(f"Timestamp: {data['Timestamp']}")
        print(f"Recently Accessed Files: {data['RecentlyAccessedFiles']}")
        print(f"Modified Files: {data['ModifiedFiles']}")
        print(f"Ram Usage: {data['RamUsage']} MB")
        print(f"Cpu Usage: {data['CpuUsage']}%")
        print(f"System Load: {data['Load']}%")

        # Store the received system stats in the list
        system_stats_list.append(data)

        # Store the data in the log.txt file
        log_path = "log.txt"
        with open(log_path, 'a') as log_file:
            log_file.write(f"Timestamp: {data['Timestamp']}\n")
            log_file.write(f"Recently Accessed Files: {data['RecentlyAccessedFiles']}\n")
            log_file.write(f"Modified Files: {data['ModifiedFiles']}\n")
            log_file.write(f"Ram Usage: {data['RamUsage']} MB\n")
            log_file.write(f"Cpu Usage: {data['CpuUsage']}%\n")
            log_file.write(f"System Load: {data['Load']}%\n\n")

        # You can also store the data in a file if needed
        # with open('system_stats.txt', 'a') as file:
        #     file.write(str(data) + '\n')

    return jsonify({"message": "System stats received successfully"})
@app.route('/show-alerts')
def show_alerts():
    # Read log entries from the log.txt file
    log_data = []
    with open('log.txt', 'r') as log_file:
        log_data = log_file.readlines()

    return render_template('your_template.html', log_data=log_data)
@app.route('/display-system-stats')
def display_system_stats():
    return render_template('system_stats.html', system_stats_list=system_stats_list)
@app.route('/api/get-system-stats', methods=['GET'])
def get_system_stats():
    return jsonify({"system_stats": system_stats_list})
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
    if request.method == 'GET':
        return jsonify({'received_strings': received_strings})
    else:
        return 'Method not allowed', 405




@app.route('/api/reg', methods=['POST'])
def handle_reg():
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files['file']
    
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    file.save(f"uploads/{file.filename}")

    return jsonify({"message": "File uploaded successfully"}), 200

# Store received strings in a list
received_strings = []

@app.route('/receive', methods=['POST'])
def receive_string():
    if request.method == 'POST':
        string_received = request.json.get('string')  # Assuming the string is sent in JSON format
        received_strings.append(string_received)
        return 'String received and stored successfully!', 200
    else:
        return 'Method not allowed', 405

@app.route('/display', methods=['GET'])
def display_strings():
    if request.method == 'GET':
        return jsonify({'received_strings': received_strings})
    else:
        return 'Method not allowed', 405

if __name__ == '__main__':
    app.run(debug=True)
