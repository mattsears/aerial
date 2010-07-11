#!/usr/bin/env ruby
require "rubygems"
require File.join(File.dirname('.'), "lib", "aerial.rb")

env  = ENV['RACK_ENV'].to_sym if ENV['RACK_ENV']
root = File.dirname(__FILE__)

# Load configuration and initialize Aerial
Aerial.new(root, "/config/config.yml")

# You probably don't want to edit anything below
Aerial::App.set :environment, ENV["RACK_ENV"] || :development
Aerial::App.set :port, 4567
Aerial::App.set :cache_enabled, env == :production ? true : false
Aerial::App.set :cache_page_extension, '.html'
Aerial::App.set :cache_output_dir, ''
Aerial::App.set :root, root

run Aerial::App
