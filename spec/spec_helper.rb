$LOAD_PATH.unshift File.dirname(__FILE__)

require 'rubygems'
require 'hpricot'
require 'sinatra'
require 'git'
require 'fileutils'
require 'grit'
require 'rack'
require 'spec'
require 'rack/test'

def app
  Aerial::App.set :root, File.expand_path( File.join(File.dirname(__FILE__), 'repo') )
  Aerial::App
end

# Helper for matching html tags
module TagMatchers

  class TagMatcher

    def initialize (expected)
      @expected = expected
      @text     = nil
    end

    def with_text (text)
      @text = text
      self
    end

    def matches? (target)
      @target = target
      doc = Hpricot(target)
      @elem = doc.at(@expected)
      @elem && (@text.nil? || @elem.inner_html == @text)
    end

    def failure_message
      "Expected #{match_message}"
    end

    def negative_failure_message
      "Did not expect #{match_message}"
    end

    protected

    def match_message
      if @elem
        "#{@elem} to have text #{@text} but got #{@elem.inner_html}"
      else
        "#{@target.inspect} to contain element #{@expected.inspect}"
      end
    end
  end

  def have_tag (expression)
    TagMatcher.new(expression)
  end

end

# Helpers for creating a test Git repo
module GitHelper

  def new_git_repo
    delete_git_repo # delete the old repo first
    path = File.expand_path( File.join(File.dirname(__FILE__), 'repo') )
    data = File.expand_path( File.join(File.dirname(__FILE__), 'fixtures') )
    Dir.mkdir(path)
    Dir.chdir(path) do
      git = Git.init
      FileUtils.cp_r "#{data}/.", "#{path}/"
      git.add
      git.commit('Copied test articles from Fixtures directory so we can test against them')
    end
    return path
  end

  def delete_git_repo
    repo = File.join(File.dirname(__FILE__), 'repo')
    if File.directory? repo
      FileUtils.rm_rf repo
    end
  end

  def new_file(name, contents)
    File.open(name, 'w') do |f|
      f.puts contents
    end
  end

end

include GitHelper

Spec::Runner.configure do |config|
  repo_path = new_git_repo

  CONFIG = YAML.load_file( File.join(File.dirname(__FILE__), 'fixtures', 'config.yml') ) unless defined?(CONFIG)
  AERIAL_ROOT = File.join(File.dirname(__FILE__), 'repo') unless defined?(AERIAL_ROOT)

  require File.expand_path(File.dirname(__FILE__) + "/../lib/aerial")
  config.include TagMatchers
  config.include GitHelper
  config.include Rack::Test::Methods
  config.include Aerial
  config.include Aerial::Helper
end

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
set :views => File.join(File.dirname(__FILE__), "/..", "repo", "views"),
:public => File.join(File.dirname(__FILE__), "/..", "repo", "public")

include Aerial

def setup_repo
  @repo_path = new_git_repo
  @config_path = File.join(@repo_path, "config")
  Aerial.stub!(:repo).and_return(Grit::Repo.new(@repo_path))
  Aerial.new(@repo_path, "config.yml")

end
