from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
  #version = "1.0alpha"
  return '[app01 vTODO] hello, world from Skaffold in python.' # .format(version)
