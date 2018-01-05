#Use bundler to load gems
require 'bundler'

#Load gems from Gemfile
Bundler.require

#Load the app
require_relative 'main.rb'

#Models
require_relative 'models/users.rb'
require_relative 'models/schedule.rb'
require_relative 'models/weight.rb'
require_relative 'models/quote.rb'

#Makes SLIM pretty :o \(^ v ^)/
Slim::Engine.set_options pretty: true, sort_attrs: false

#Run the app
run Main