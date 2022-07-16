$VERSION = File.read("VERSION").chomp
$interesting_envs = %w{ RICCARDO_KUSTOMIZE_ENV RICCARDO_MESSAGE FAVORITE_COLOR RACK_ENV APP_NAME }

require 'URI'

class App
  require 'socket'

  def self.call(env)
    fav_color = ENV.fetch("FAVORITE_COLOR", "unknown color, presumably gray?") rescue :UNKNOWN_COLOR

    interesting_infos = {
      :version => $VERSION,
      :hostname =>  Socket.gethostname,
      #:ric_msg => (ENV.fetch("RICCARDO_MESSAGE", "unknown message") rescue :UNKNOWN_MSG),
      #:RICCARDO_KUSTOMIZE_ENV => (ENV["RICCARDO_KUSTOMIZE_ENV"] rescue :_UNKNOWN_RICCARDO_KUSTOMIZE_ENV),
      :interesting_envs => $interesting_envs,
    }

    # populating based on interesting ENVs
    $interesting_envs.each{ |env_name|
     interesting_infos["ENV_#{env_name}"] = ENV[env_name] rescue :err
    }

    interesting_infos_htmlified = "<h2>Interesting Info</h2> <ul>"
    interesting_infos.each do |k,v|
      v = '?!?' if v.to_s == ''
      interesting_infos_htmlified << "<li>#{k}: <b>#{v}</b></li>"
    end
    interesting_infos_htmlified << "</ul>"

    # todo put in ERB..
    html_string =  "<h1>[app02 in Ruby] Hello from Riccardo!</h1>
    More exciting stuff coming soon from ENV vars.<br/>

    Favorite Color: <b style='background-color:#{fav_color};' >#{fav_color}</b><br/>

    #{interesting_infos_htmlified}<br/>

    Manual RICCARDO_KUSTOMIZE_ENV (seems broken): #{ ENV['RICCARDO_KUSTOMIZE_ENV'] }<br/>
    CD_TARGET (works): <tt><b>#{ENV['CLOUD_DEPLOY_TARGET']}</b></tt> <br/>

    Btw, I really love skaffold!
    Note that the version below is now read by file since v1.3 and also properly associated to a Cloud Deploy
    release. If you want to steal my logic, feel free to check the code in github.com: palladius/clouddeploy-platinum-path.git

    There is currently a problem with app and UTF9 and emojis (🍻 😎 ❤ 💎)
    <hr/>
    <center>
      APP
      <b>#{ENV['APP_NAME']}</b>
      (from env) v.<b>#{$VERSION}</b> -
    </center>
  "

    # https://mensfeld.pl/2014/03/rack-argument-error-invalid-byte-sequence-in-utf-8/
    #doesnt work html_string = URI.decode(html_string).force_encoding('UTF-8')


    return [
      200,
      {"Content-Type" => "text/html"},
      [
        html_string.force_encoding('utf-8')
      ]
    ]
  end
end
