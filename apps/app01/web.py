from flask import Flask
app = Flask(__name__)

@app.route('/')

version_from_file = 'none'
#print("[ricc] Starting the super-duper vanilla server in python to say HelloWorld!\n")

with open("VERSION", "r") as f:
    version_from_file = f.readlines()

def index():
  version = version_from_file # "1.1a"
  print("[ricc][web.py] INDEX: the super-duper vanilla server in python to say HelloWorld v{}!\n".format(version))
  return "[app01 v<b>{}</b>] Hello world from Skaffold in python!".format(version)
