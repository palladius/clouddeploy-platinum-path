from flask import Flask
import os

app = Flask(__name__)

@app.route('/')

#version_from_file = 'none'
#print("[ricc] Starting the super-duper vanilla server in python to say HelloWorld!\n")


def index():
  with open("VERSION", "r") as f:
    version_from_file = "".join(f.readlines())
  version = version_from_file.rstrip() # "1.1a"
  fav_color = os.environ.get('FAVORITE_COLOR')
  env_app_name = os.environ.get('APP_NAME')
  cd_stage =  os.environ.get('CLOUD_DEPLOY_TARGET')
  ric_msg = os.environ.get('RICCARDO_MESSAGE')
  cloud_deploy_target_common = os.environ.get('CLOUD_DEPLOY_TARGET_COMMON')

  print("[ricc][web.py] INDEX: the super-duper vanilla server in python to say HelloWorld - v{}!\n".format(version))
  return """<h1>App01 (🐍) v<b>{ver}</b></h1>

        Hello world from Skaffold in python! This is a demonstrative app to demonstrate CI/CD with Cloud Deploy and Cloud Build<br/>

        I read version from file and this ./VERSION file is actually read by the build pipeline
        into the Cloud Deploy release name - wOOOt!<br/>

        FAVORITE_COLOR={fav_color}<br/>
        CD_TARGET={cd_stage} <br/>
        CLOUD_DEPLOY_TARGET_COMMON={cloud_deploy_target_common} <br/>

        APP_NAME={env_app_name} <br/>
        RICCARDO_MESSAGE={ric_msg}

        Favorite Color from v14: <b style='background-color:#{fav_color};' >#{fav_color}</b><br/>

        <hr/>
          <center>
           <!-- /statusz --> app01 (🐍) v<b>{ver}</b> CTARGET=<b>{cloud_deploy_target_common}</b>
          </center>
  """.format(
    ver=version,
    fav_color=fav_color,
    env_app_name=env_app_name,
    cd_stage=cd_stage,
    cloud_deploy_target_common=cloud_deploy_target_common,
    ric_msg=ric_msg)
