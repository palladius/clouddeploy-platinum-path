#require './app.rb'
require './sinatra.rb'

require 'rack/unreloader'
Unreloader = Rack::Unreloader.new{App}

Unreloader.require './*.rb'
run Unreloader
