from flask import Flask
app = Flask(__name__)

@app.route('/')

print("[ricc] Starting the super-duper vanilla server in python to say HelloWorld!\n")

def index():
  version = "1.0alpha"
  return "[app01 v<b>{}</b>] Hello world from Skaffold in python!".format(version)
