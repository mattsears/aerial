module Aerial
  class Migrator

    class << self
      attr_accessor :provider, :dbname, :user, :pass, :host
    end

    # Public: Create a new Migrator instance.
    #
    # options - A Hash of options (default: {}):
    #           :provider - String the blog or service that provides the content
    #
    # Examples
    #
    #   m = Aerial::Migrator.new({:provider => 'mephisto'})
    #
    # Returns a newly initialized Grit::Migrator.
    # Raises NameError if the migrator does not exist.
    #
    def initialize(options = {})
      @provider = options['articles']['provider']
      @dbname = options['articles']['dbname']
      @user = options['articles']['user']
      @pass = options['articles']['pass']
      @host = options['articles']['host']
    end

    def process!
      migrator = eval("Aerial::#{@provider.classify}")
      require 'aerial/migrators/#{migrator}'
      migrator.import(@dbname, @user, @pass, @host)
    rescue NameError
      puts "Oh sorry, #{@provider} isn't supported by Aerial"
    end

  end
end
