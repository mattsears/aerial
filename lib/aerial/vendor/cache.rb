require 'memcache'
require 'digest/md5'

module Sinatra
  module Cache

    class Store
      attr_accessor :logger

      # Creates an html comment that contains the date and time when the page was cached
      def timestamp
        "<!-- page cached: #{Time.now.strftime("%Y-%d-%m %H:%M:%S")} -->"
      end

    end

    # A cache store implementation which stores everything on the filesystem.
    class FileStore < Store
      attr_reader   :cache_path

      def initialize
        @cache_path = Aerial.config.public.dir
      end

      # Save the response to an html file
      def write(name, content, options = nil)
        return if name.nil?
        path = cache_file_path(name)
        ensure_cache_path(File.dirname(path))
        File.open(path, 'wb+') do |f|
          f << content
          f << timestamp
        end
        content
      rescue => e
        Aerial.log "Couldn't save html file to cache directory because #{e}"
      end

      # Removed the cached file from the disk
      def delete(name, options = nil)
        File.delete(cache_file_path(name))
        Aerial.log("Cache expired: #{name}")
      rescue SystemCallError => e
        # There's no cache, so no probem
      end

      # Determine if cache exists
      def exist?(name, options = nil)
        File.exist?(cache_file_path(name))
      end

      private

      # Relative path to the cached file
      def cache_file_path(name, options = {})
        "#{self.cache_path}/#{cache_file_name(name,options)}"
      end

      # Determine the file name based on the request path
      def cache_file_name(path, options={})
        name = (path.empty? || path == "/") ? "index" : Rack::Utils.unescape(path.sub(/^(\/)/,'').chomp('/'))
        name << ".html" unless (name.split('/').last || name).include? '.'
        return name
      end

      # Create directory to store the cached pages
      def ensure_cache_path(path)
        unless File.exist?(path)
          FileUtils.makedirs(path)
        end
      end

    end
  end
end

module Cacheable

  def self.included(base)
    base.send :include, Cacheable::InstanceMethods
  end

  module InstanceMethods

    # Write the content to a cache store
    #   +content+ is a string to be saved
    def cache(content, opts={})
      return content unless options.respond_to?("cache_enabled") && options.cache_enabled

      page = content
      path = self.env["REQUEST_URI"]
      store = Sinatra::Cache::FileStore.new
      store.write(path, page)
      page
    end

    # Removed the cached page from the cache store
    #  +name+ the location of the cached content
    def expire_cache(name = nil, options={})

      store = Sinatra::Cache::FileStore.new
      store.delete(name)
      name
    end

  end
end

