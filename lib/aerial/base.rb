CONFIG = YAML.load_file( File.join(AERIAL_ROOT, 'config', 'config.yml') ) unless defined?(CONFIG)

require 'aerial/content'
require 'aerial/article'
require 'aerial/comment'
require 'aerial/vendor/cache'
require 'aerial/vendor/akismetor'
require 'aerial/config'

module Aerial

  VERSION = '0.1.0'

  class << self
    attr_accessor :debug, :logger, :repo, :config

    def log(str)
      logger.debug { str } if debug
    end
  end

  # Make sure git is added to the env path
  ENV['PATH'] = "#{ENV['PATH']}:/usr/local/bin"
  @logger ||= ::Logger.new(STDOUT)
  @config ||= Aerial::Config.new(CONFIG)
  @repo   ||= Grit::Repo.new(File.join(AERIAL_ROOT, '.'))
  @debug  ||= false

  module Helper

    # Defines the url for our application
    def hostname
      if request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/
        request.env['HTTP_X_FORWARDED_SERVER']
      else
        request.env['HTTP_HOST']
      end
    end

    # Returns the
    def path
      base = "#{request.env['REQUEST_URI']}".scan(/\w+/).first
      return base.blank? ? "index" : base
    end

    # Creates a complete link including the hostname
    def full_hostname(link = "")
      "http://#{hostname}#{link}"
    end

    # Display the page titles in proper format
    def page_title
      title = @page_title ? "| #{@page_title}" : ""
      return "#{Aerial.config.title} #{title}"
    end

    # Format just the DATE in a nice easy to read format
    def humanized_date(date)
      if date && date.respond_to?(:strftime)
        date.strftime('%A %B, %d %Y').strip
      else
        'Never'
      end
    end

    # Format just the DATE in a short way
    def short_date(date)
      if date && date.respond_to?(:strftime)
        date.strftime('%b %d').strip
      else
        'Never'
      end
    end

    # Format for the rss 2.0 feed
    def rss_date(date)
      date.strftime("%a, %d %b %Y %H:%M:%S %Z") #Tue, 03 Jun 2003 09:39:21 GMT
    end

    # Truncate a string
    def blurb(text, options ={})
      options.merge!(:length => 160, :omission => "...")
      if text
        l = options[:length] - options[:omission].length
        chars = text
        (chars.length > options[:length] ? chars[0...l] + options[:omission] : text).to_s
      end
    end

    # Handy method to render partials including collections
    def partial(template, options = {})
      options.merge!(:layout => false)
      return if options.has_key?(:collection) && options[:collection].nil?

      if collection = options.delete(:collection) then
        collection.inject([]) do |buffer, member|
          buffer << haml(template, options.merge(:layout => false,
                                                 :locals => {template.to_sym => member}))
        end.join("\n")
      else
         haml(template, options)
      end
    end

    # Author link
    def link_to_author(comment)
      unless comment.homepage.blank?
        return "<a href='#{comment.homepage}' rel='external'>#{comment.author}</a>"
      end
      comment.author
    end

    # Create a list of hyperlinks with a set of tags
    def link_to_tags(tags)
      return unless tags
      links = []
      tags.each do |tag|
        links << "<a href='/tags/#{tag}' rel='#{tag}'>#{tag}</a>"
      end
      links.join(", ")
    end

  end

  # Provides a few methods for interacting with that Aerial repository
  class Git

    # Commit the new file and push it to the remote repository
    def self.commit_and_push(path, message)
      self.commit(path, message)
      self.push
    end

    # Added the file in the path and commit the changs to the repo
    #   +path+ to the new file to commit
    #   +message+ description of the commit
    def self.commit(path, message)
      Dir.chdir(File.expand_path(Aerial.repo.working_dir)) do
        Aerial.repo.add(path)
      end
      Aerial.repo.commit_index(message)
    end

    # Adds all untracked files and commits them to the repo
    def self.commit_all(path = ".", message = "Commited all changes at: #{DateTime.now}")
      unless Aerial.repo.status.untracked.empty?
        self.commit(path, message)
      end
      true
    end

    # Upload all new commits to the remote repo (if exists)
    def self.push
      return unless Aerial.config.git.name && Aerial.config.git.branch

      begin
        cmd = "push #{Aerial.config.git.name} #{Aerial.config.git.branch} "
        Aerial.repo.git.run('', cmd, '', {}, "")
      rescue Exception => e
        Aerial.log(e.message)
      end
    end

  end

end

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end
