from flask import Flask
import os 

app = Flask(__name__)

@app.route('/')

version_from_file = 'none'
#print("[ricc] Starting the super-duper vanilla server in python to say HelloWorld!\n")

with open("VERSION", "r") as f:
    version_from_file = f.readlines()

def index():
  version = version_from_file # "1.1a"
  fav_color = os.environ.get('FAVORITE_COLOR')

  print("[ricc][web.py] INDEX: the super-duper vanilla server in python to say HelloWorld v{}!\n".format(version))
  return """<h1>app01 v<b>{}</b></h1> 
        Hello world from Skaffold in python! This is a demonstrative app to demonstrate CI/CD with Cloud Deploy and Cloud Build<br/>
        FAVORITE_COLOR={}
  """.format(version, fav_color)
