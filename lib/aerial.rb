libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
AERIAL_ROOT = File.join(File.dirname(__FILE__), '..') unless defined? AERIAL_ROOT

# System requirements
require 'rubygems'
require 'grit'
require 'yaml'
require 'sinatra'
require 'haml'
require 'sass'
require 'rdiscount'
require 'aerial/base'
require "aerial/app"

module Aerial

  def self.new(config=nil)
    if config.is_a?(String) && File.file?(config)
      self.config = YAML.load_file(config)
    elsif config.is_a?(Hash)
      self.config = config
    end
  end

end
