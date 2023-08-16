require 'bundler/setup'
Bundler.require(:default)
require_relative './environment.rb'
require 'json'
require 'sinatra'
require_relative './app.rb'

run Sinatra::Applicationp
