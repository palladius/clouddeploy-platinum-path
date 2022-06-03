# version 1:1

class App

  def self.call(env)
    fav_color = ENV.fetch("FAVORITE_COLOR", "unknown color, presumably gray?") rescue :UNKNOWN_COLOR
    ric_msg = ENV.fetch("RICCARDO_MESSAGE", "unknown message") rescue :UNKNOWN_MSG

    return [ 200, {
      "Content-Type" => "text/html"}, 
      ["Hello Skaffold from Riccardo! More exiciting stuff coming soon from ENV vars.\n FavColor #{fav_color}"]
    ]
  end
end
