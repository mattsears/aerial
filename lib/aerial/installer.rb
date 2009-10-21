require "thor"
require File.dirname(__FILE__) + "/../aerial"

module Aerial

  class Installer < Thor
    include FileUtils

    desc "install [PATH]",
    "Copy template files to PATH for desired deployement strategy
       (either Thin or Passenger). Next, go there and edit them."
    method_options :passenger => :boolean, :thin  => :boolean
    def install(path)
      @root = Pathname(path).expand_path
      create_dir_structure
      copy_config_files
      edit_config_files
      bootstrap
      puts post_install_message
    end

    desc "launch [CONFIG]", "Launch Aerial cartwheel."
    method_options :config => :optional, :port => 4567
    def launch
      @root = Pathname(".").expand_path
      require "thin"
      Aerial.new(@root, "/config.yml")
      Thin::Server.start("0.0.0.0", options[:port], Aerial::App)
    rescue LoadError => boom
      missing_dependency = boom.message.split("--").last.lstrip
      puts "Please install #{missing_dependency} to launch Aerial"
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
      copy "public", "../../examples"
      initialize_repo
      create_initial_article
      initial_commit
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
      copy "thin.sample.yml" if options[:thin]
    end

    # Customize the settings for the current location
    def edit_config_files
      edit_aerial_configuration
      edit_thin_configuration if options[:thin]
    end

    def edit_aerial_configuration
      config = File.read("#{root}/config.yml")
      config.gsub! %r(/var/log), "#{root}/log"
      File.open("#{root}/config.yml", "w") { |f| f.puts config }
    end

    def edit_thin_configuration
      config = File.read("#{root}/thin.yml")
      config.gsub! %r(/apps/aerial), root
      File.open("#{root}/thin.yml", 'w') { |f| f.puts config }
    end

    def copy(source, path = "../../config")
      cp_r(Pathname(__FILE__).dirname.join(path, source),
         root.join(File.basename(source).gsub(/\.sample/, "")))
    end

    def post_install_message
      <<EOF

Awesome! Aerial was installed successfully!

Don't forget to tweak #{root}/config.yml to your needs.
EOF
    end

  end
end
