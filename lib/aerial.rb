libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
AERIAL_ROOT = File.join(File.dirname(__FILE__), '..') unless defined? AERIAL_ROOT
CONFIG = YAML.load_file( File.join(AERIAL_ROOT, 'config', 'config.yml') ) unless defined?(CONFIG)

# System requirements
require 'rubygems'
require 'grit'
require 'yaml'
require 'sinatra'
require 'haml'
require 'sass'
require 'rdiscount'
require 'aerial/base'
require 'aerial/content'
require 'aerial/article'
require 'aerial/comment'
require 'aerial/vendor/cache'
require 'aerial/vendor/akismetor'
require 'aerial/config'
require 'aerial/app'

module Aerial

  # Make sure git is added to the env path
  ENV['PATH'] = "#{ENV['PATH']}:/usr/local/bin"
  VERSION = '0.1.0'

  class << self
    attr_accessor :debug, :logger, :repo, :config
  end

  def self.new(root, config_name = nil)
    @root   ||= root
    @logger ||= ::Logger.new(STDOUT)
    @debug  ||= false
    @repo   ||= Grit::Repo.new(@root)
    config  = File.join(root, config_name)

    if config.is_a?(String) && File.file?(config)
      @config = Aerial::Config.new(YAML.load_file(config))
    elsif config.is_a?(Hash)
      @config = Aerial::Config.new(config)
    end
  end

  def self.log(str)
    logger.debug { str } if debug
  end

end
