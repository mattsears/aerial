module Aerial
  class Config

    class << self
      attr_accessor :config
    end

    # Default options. Overriden by values in config.yml or command-line opts.
    # (Strings rather symbols used for compatability with YAML).
    DEFAULTS = {
      'title'        => 'Aerial Title',
      'subtitle'     => 'Aerial Subtitle',
      'name'         => 'Aerial User Name',
      'email'        => 'Aerial User Email',
      'server'       => false,
      'server_port'  => 3000,

      'source'       => Dir.pwd,
      'config'       => 'config.yml',
      'destination'  => File.join(Dir.pwd, 'public', '_site'),

      'markdown'     => 'maruku',
      'permalink'    => 'date',

      'articles'     => {
        'dir'     => 'articles'
      },

      'views'     => {
        'dir'     => 'views',
        'default' => 'home'
      }
    }

    # Generate a Aerial configuration Hash by merging the default options
    # with anything in config.yml, and adding the given options on top.
    #
    # override - A Hash of config directives that override any options in both
    #            the defaults and the config file. See Jekyll::DEFAULTS for a
    #            list of option names and their defaults.
    #
    # Returns the final configuration Hash.
    def self.new(override)
      # _config.yml may override default source location, but until
      # then, we need to know where to look for _config.yml
      config_name = override['config'] || Aerial::Config::DEFAULTS['config']
      source = override['source'] || Aerial::Config::DEFAULTS['source']

      # Get configuration from <source>/_config.yml
      config_file = File.join(source, config_name)

      begin
        config = YAML.load_file(config_file)
        raise "Invalid configuration - #{config_file}" if !config.is_a?(Hash)
        $stdout.puts "Configuration from #{config_file}"
      rescue => err
        $stderr.puts "WARNING: Could not read configuration. " +
          "Using defaults (and options)."
        $stderr.puts "\t" + err.to_s
        config = {}
      end

      # Merge DEFAULTS < _config.yml < override
      configs = Aerial::Config::DEFAULTS.deep_merge(config).deep_merge(override)
      self.nested_hash_to_openstruct(configs)
    end

    def method_missing(method_name, *attributes)
      if @config.respond_to?(method_name.to_sym)
        return @config.send(method_name.to_sym)
      else
        false
      end
    end

    private

    # Recursively convert nested Hashes into Openstructs
    def self.nested_hash_to_openstruct(obj)
      if obj.is_a? Hash
        obj.each { |key, value| obj[key] = nested_hash_to_openstruct(value) }
        OpenStruct.new(obj)
      else
        return obj
      end
    end

  end

end
