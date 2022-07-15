$VERSION = File.read("VERSION").chomp
$interesting_envs = %w{ RICCARDO_KUSTOMIZE_ENV RICCARDO_MESSAGE FAVORITE_COLOR RACK_ENV APP_NAME }


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


    return [ 200, {
      "Content-Type" => "text/html"},
      ["<h1>[app02 in 💎Ruby💎] Hello from Riccardo!</h1>  More exciting stuff coming soon from ENV vars.<br/>

      Favorite Color: <b style='background-color:#{fav_color};' >#{fav_color}</b><br/>

      #{interesting_infos_htmlified}

      Manual RICCARDO_KUSTOMIZE_ENV: #{ ENV['RICCARDO_KUSTOMIZE_ENV'] }

      Btw, I really love skaffold!
      Note that the version below is now read by file since v1.3 and also properly associated to a Cloud Deploy
      release. If you want to steal my logic, feel free to check the code in github.com: palladius/clouddeploy-platinum-path.git

      <hr/>
      <center>
        APP
        <b>#{ENV['APP_NAME']}</b>
        (from env)) v.<b>#{$VERSION}</b> -
        CD_TARGET: <tt><b>#{ENV['CLOUD_DEPLOY_TARGET']}</b></tt>
      </center>
      "]
    ]
  end
end
