from flask import Flask, request

app = Flask(_name_)

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

if _name_ == '_main_':
    app.run(debug=True)  # Run the Flask app in debug mode for development