require 'sequel'
require 'sequel/extensions/inflector'
require 'sequel/extensions/string_date_time'
require 'fileutils'
require 'yaml'
require 'aerial/migrators/mephisto'
require 'mcbean'

module Aerial
  class Migrator

    class << self
      attr_accessor :provider, :dbname, :user, :pass, :host
    end

    def initialize(options = {})
      @provider = options['articles']['provider']
      @dbname = options['articles']['dbname']
      @user = options['articles']['user']
      @pass = options['articles']['pass']
      @host = options['articles']['host']
    end

    def process!
      migrator = eval("Aerial::#{@provider.classify}")
      migrator.import(@dbname, @user, @pass, @host)
    #rescue NameError
    #  puts "Oh sorry, #{@provider} isn't supported by Aerial"
    end

  end
end
