require "thor"
require File.dirname(__FILE__) + "/../aerial"

module Aerial

  class Installer < Thor
    include FileUtils
    map "-T" => :list

    desc "install [PATH]",
    "Copy template files to PATH for desired deployement strategy
       (either Thin or Passenger). Next, go there and edit them."
    method_options :passenger => :boolean, :thin  => :boolean
    def install(path = '.')
      @root = Pathname(path).expand_path
      create_dir_structure
      copy_config_files
      edit_config_files
      bootstrap
      puts post_install_message
    end

    desc "launch [CONFIG]", "Launch Aerial cartwheel."
    method_options :config => 'config.yml', :env => :development
    def server
      require 'thin'
      Aerial.new(options, options[:env] || :development)
      Aerial::App.set :root, Aerial.root
      Thin::Server.start("0.0.0.0", Aerial.config.server_port, Aerial::App)
    rescue LoadError => boom
      missing_dependency = boom.message.split("--").last.lstrip
      puts "Please install #{missing_dependency} to launch Aerial"
    end

    desc "overrides", "Allow aerial to be customized"
    def overrides
      @root = Pathname(".").expand_path
      create_app_file
    end

    desc "import", "Import articles from another blog."
    method_option :articles, :type => :hash, :default => {}, :required => true
    def import
      @root = Pathname(".").expand_path
      Aerial.new(@root, "/config.yml")
      Aerial::Migrator.new(options).process!
    rescue LoadError => boom
      missing_dependency = boom.message.split("--").last.lstrip
      puts "Please install #{missing_dependency} to import article into Aerial"
    end

    private

    # ==========================================================================
    # PRIVATE INSTANCE METHODS
    # ==========================================================================

    attr_reader :root

    def create_dir_structure
      mkdir_p root
      mkdir_p "#{root}/log"

      if options[:passenger]
        mkdir_p "#{root}/public"
        mkdir_p "#{root}/tmp"
      end
    end

    # Copy over all files need to run the app
    def bootstrap
      copy "views", "../../examples"
      create_initial_article
    end

    def create_initial_article
      copy "articles", "../../examples"
    end

    # Create a new repo if on none exists
    def initialize_repo
      unless File.exist?(File.join(root, '.git'))
        system "cd #{root}; git init"
      end
    end

    def initial_commit
      Aerial.new(root, "/config.yml")
      system "cd #{root}; git add ."
      Aerial::Git.commit("#{root}/articles", "Initial installation of Aerial")
    end

    # Rename and the sample config files
    def copy_config_files
      copy "config.sample.ru"
      copy "config.sample.yml"
    end

    # Customize the settings for the current location
    def edit_config_files
      edit_aerial_configuration
    end

    def edit_aerial_configuration
      config = File.read("#{root}/config.yml")
      config.gsub! %r(/var/log), "#{root}/log"
      File.open("#{root}/config.yml", "w") { |f| f.puts config }
    end

    def copy(source, path = "../../config")
      cp_r(Pathname(__FILE__).dirname.join(path, source),
         root.join(File.basename(source).gsub(/\.sample/, "")))
    end

    def create_app_file
      unless File.exist?(File.join(root, 'app.rb'))
        File.open('app.rb', 'w') do |file|
          file.puts "module Aerial"
          file.puts "  class App < Sinatra::Base"
          file.puts "    helpers do"
          file.puts ""
          file.puts "    end"
          file.puts "  end"
          file.puts "end"
        end
      end
    end

    def post_install_message
      <<EOF

Awesome! Aerial was installed successfully!

Don't forget to tweak #{root}/config.yml to your needs.
EOF
    end

  end
end
