# app.py
from flask import Flask, render_template, redirect, url_for, request, session
from flask_bootstrap import Bootstrap
import psutil

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'
Bootstrap(app)

# Hardcoded admin credentials (replace with a proper authentication system)
ADMIN_USERNAME = 'admin'
ADMIN_PASSWORD = 'admin'

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

if __name__ == '__main__':
    app.run(debug=True)
