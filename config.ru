require 'bundler/setup'
Bundler.require(:default)
require_relative './environment.rb'

require_relative './app.rb'
run Sinatra::Application
