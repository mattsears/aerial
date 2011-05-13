module Aerial
  class Site

    attr_accessor :config, :exclude

    def initialize
      self.config  = Aerial.config
      self.exclude = ['blog', 'post', 'layout', 'not_found', 'rss', 'style']
    end

    # Public: Loads a local Sinatra app if exists.
    #
    # name    - The String file name of the app.
    #           Traditionally it's called "app.rb".
    #
    # Returns Boolean if app exists and loads.
    #
    def self.include_local_app(name = 'app')
      require File.expand_path(File.join(Aerial.root, name))
    rescue LoadError
    end

    def process!
      self.read_pages
    end

    def read_pages
      base = File.join(Aerial.root, 'views')
      return unless File.exists?(base)
      request = Rack::MockRequest.new(Aerial::App)
      pages = Dir.chdir(base) { filter_entries(Dir['**/*']) }
    end

    def filter_entries(entries)
      entries = entries.reject do |e|
        unless ['.htaccess'].include?(e)
          file_name = File.basename(e, File.extname(e))
          ['.', '_', '#'].include?(file_name[0..0]) || file_name[-1..-1] == '~' || self.exclude.include?(file_name) || File.directory?(e)
        end
      end
    end

  end
end
