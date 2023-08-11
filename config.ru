require 'bundler/setup'
Bundler.require(:default)
require_relative './app.rb'
require_relative 'lib/house.rb'
require_relative 'lib/base_strategy.rb'
require_all 'lib/strategies'
require_all 'lib'

run App
