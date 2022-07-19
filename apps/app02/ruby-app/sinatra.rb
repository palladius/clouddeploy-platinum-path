require 'sinatra'

$VERSION = File.read("VERSION").chomp
# Removing RACK_ENV because its always DEV and its confusing! :)
$interesting_envs = %w{ CLOUD_DEPLOY_TARGET RICCARDO_MESSAGE FAVORITE_COLOR  APP_NAME
  CLOUD_DEPLOY_TARGET_COMMON FAVORITE_COLOR_COMMON CLOUD_DEPLOY_TARGET_SHORT_COMMON}


class App < Sinatra::Base

  def cloud_deploy_target()
    ENV.fetch 'CLOUD_DEPLOY_TARGET_SHORT_COMMON', '_dunno_'
  end

  def favorite_color()
    ENV.fetch 'FAVORITE_COLOR_COMMON', 'black'  # default to black
  end


  get '/' do
    #"Hello, world!"
    fav_color = ENV.fetch("FAVORITE_COLOR", "#161616") rescue :UNKNOWN_COLOR # OLD ONE.

    interesting_infos = {
      :version => $VERSION,
      :hostname =>  Socket.gethostname.split('.').first, # lets not disclose domain ;)
      :interesting_envs => $interesting_envs,
    }

    # populating based on interesting ENVs
    $interesting_envs.each{ |env_name|
     interesting_infos["ENV_#{env_name}"] = ENV[env_name] rescue :err
    }

    interesting_infos_htmlified = "<ul>"
    interesting_infos.each do |k,v|
      v = '?!?' if v.to_s == ''
      interesting_infos_htmlified << "<li>#{k}: <b>#{v}</b></li>"
    end
    interesting_infos_htmlified << "</ul>"

    # todo put in ERB..
    html_string =  "<h1>app02 in 💎 Ruby 💎</h1>
    Hello from Riccardo!
    More exciting stuff coming soon from ENV vars.<br/>

    Favorite Color v1: <b style='background-color:#{fav_color};' >#{fav_color}</b> (so 90s!)<br/>
    Favorite Color v2: <b style='background-color:#{favorite_color};' >#{favorite_color}</b><br/>

    <h2>Deployment Info 😎</h2>

    RICCARDO_KUSTOMIZE_ENV (seems broken): #{ ENV['RICCARDO_KUSTOMIZE_ENV'] }<br/>
    CLOUD_DEPLOY_TARGET (often works): <tt><b>#{ENV['CLOUD_DEPLOY_TARGET']}</b></tt> <br/>
    CLOUD_DEPLOY_TARGET_COMMON: <tt><b>#{ENV.fetch 'CLOUD_DEPLOY_TARGET_COMMON'}</b></tt> <br/>
    CLOUD_DEPLOY_TARGET_SHORT_COMMON: <tt><b>#{cloud_deploy_target()}</b></tt> <br/>

    <h2>Interesting Info 😎</h2>

    PATH_INFO: <tt><b>#{ENV['PATH_INFO']}</b></tt> <br/>

    #{interesting_infos_htmlified}<br/>

    Btw, I really love <a href='https://skaffold.dev/' >skaffold</a>!
    Note that the version below is now read by file since v1.3 and also properly associated to a Cloud Deploy
    release. If you want to steal my logic, feel free to check the code in github.com: palladius/clouddeploy-platinum-path.git

    There is currently a problem with app and UTF-8 and emojis (🍻 😎 ❤ 💎). interetisngly enough, a local curl renders
    these icons perfectly, but my browser doesnt so i believe the culprit is in the Content-Type?
    <hr/>
    <center>
      <b>#{ENV['APP_NAME']}</b>
      <!-- /statusz --> app02 💎 v<b>#{$VERSION}</b> target:<b>#{cloud_deploy_target}</b>
      <!-- directly from kustomize CLOUD_DEPLOY_TARGET_COMMON variable ! -->
    </center>
    "

    return html_string
  end
  get '/statusz' do
    "app=app02 version=#{$VERSION} target=#{cloud_deploy_target} emoji=💎"
  end
end

# get '/' do
#   'Hello, voter!'
# end



