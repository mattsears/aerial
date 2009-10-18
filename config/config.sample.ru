#!/usr/bin/env ruby
require "rubygems"
require "aerial"
require 'sinatra'

root_dir = File.dirname(__FILE__)
env = ENV['RACK_ENV'].to_sym

# set :environment          => env,
#     :root                 => root_dir,
#     :app_file             => File.join(root_dir, 'lib', 'aerial.rb'),
#     :cache_enabled        => env == :production ? true : false,
#     :cache_page_extension => '.html',
#     :cache_output_dir     => ''
# disable :run
# run Sinatra::Application

# Load configuration and initialize Integrity
Aerial.new(File.dirname(__FILE__) + "/config.yml")

# You probably don't want to edit anything below
Aerial::App.set :environment, ENV["RACK_ENV"] || :production
Aerial::App.set :port, 4567

run Aerial::App
