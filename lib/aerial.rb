require 'yaml'
libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
AERIAL_ROOT = File.join(File.dirname(__FILE__), '..') unless defined? AERIAL_ROOT
CONFIG = YAML.load_file( File.join(AERIAL_ROOT, 'config', 'config.yml') ) unless defined?(CONFIG)

# System requirements
require 'rubygems'
require 'grit'
require 'sinatra'
require 'haml'
require 'sass'
require 'rdiscount'
require 'html_truncator'
require 'aerial/base'
require 'aerial/content'
require 'aerial/article'
require 'aerial/config'
require 'aerial/migrator'
require 'aerial/site'

module Aerial

  # Make sure git is added to the env path
  ENV['PATH'] = "#{ENV['PATH']}:/usr/local/bin"

  class << self
    attr_accessor :debug, :logger, :repo, :config, :root, :env
  end

  def self.new(overrides, env = :development)
    @root   ||= Dir.pwd
    @logger ||= ::Logger.new(STDOUT)
    @debug  ||= false
    @repo   ||= Grit::Repo.new(@root) rescue nil
    @env    = env
    @config = Aerial::Config.new(overrides)
    require 'aerial/app'
    return self
  end

  def self.log(str)
    logger.debug { str } if debug
  end

end
