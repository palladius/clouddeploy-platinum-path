$VERSION = File.read("VERSION").chomp
# Removing RACK_ENV because its always DEV and its confusing! :)
$interesting_envs = %w{ CLOUD_DEPLOY_TARGET RICCARDO_MESSAGE FAVORITE_COLOR  APP_NAME CLOUD_DEPLOY_TARGET_COMMON }

class App
  require 'socket'

  def self.call(env)
    fav_color = ENV.fetch("FAVORITE_COLOR", "unknown color, presumably gray?") rescue :UNKNOWN_COLOR

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

    Favorite Color: <b style='background-color:#{fav_color};' >#{fav_color}</b><br/>

    <h2>Deployment Info 😎</h2>

    RICCARDO_KUSTOMIZE_ENV (seems broken): #{ ENV['RICCARDO_KUSTOMIZE_ENV'] }<br/>
    CLOUD_DEPLOY_TARGET (often works): <tt><b>#{ENV['CLOUD_DEPLOY_TARGET']}</b></tt> <br/>
    CLOUD_DEPLOY_TARGET_COMMON: <tt><b>#{ENV['CLOUD_DEPLOY_TARGET_COMMON']}</b></tt> <br/>

    <h2>Interesting Info 😎</h2>

    #{interesting_infos_htmlified}<br/>

    Btw, I really love <a href='https://skaffold.dev/' >skaffold</a>!
    Note that the version below is now read by file since v1.3 and also properly associated to a Cloud Deploy
    release. If you want to steal my logic, feel free to check the code in github.com: palladius/clouddeploy-platinum-path.git

    There is currently a problem with app and UTF-8 and emojis (🍻 😎 ❤ 💎). interetisngly enough, a local curl renders
    these icons perfectly, but my browser doesnt so i believe the culprit is in the Content-Type?
    <hr/>
    <center>
      <b>#{ENV['APP_NAME']}</b>
      <!-- /statusz --> app02 v<b>#{$VERSION}</b> - Target:<b>#{ ENV.fetch 'CLOUD_DEPLOY_TARGET_COMMON', 'dunno'}</b>
      <!-- directly from kustomize CLOUD_DEPLOY_TARGET_COMMON variable ! -->
    </center>
  "

    # https://mensfeld.pl/2014/03/rack-argument-error-invalid-byte-sequence-in-utf-8/
    #doesnt work html_string = URI.decode(html_string).force_encoding('UTF-8')

    # not sure if it works, but should fail pretty cleanly if it doesnt :)
    html_string = html_string.encode('UTF-8') rescue html_string

    return [
      200,
#      {"Content-Type" => "text/html"},
      {"Content-Type" => "text/html; charset=utf-8"},
      [
        html_string # .force_encoding('utf-8')
      ]
    ]
  end
end
