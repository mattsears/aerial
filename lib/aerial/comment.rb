module Aerial

  # Anonymous feedback
  class Comment < Content

    attr_reader   :id,           :permalink, :article,      :spam,       :file_path
    attr_accessor :archive_name, :spam,      :published_at, :name,
                  :email,        :homepage,  :user_ip,      :user_agent, :referrer

    def initialize(atts = {})
      super
      sanitize_url
    end

    # =============================================================================================
    # PUBLIC CLASS METHODS
    # =============================================================================================

    # Create a new instance and write comment to disk
    #   +path+ the file location of the comment
    def self.create(archive_name, attributes ={})
      comment = Comment.new(attributes.merge(:archive_name => archive_name))
      if comment.valid?
        return self.save_new(comment)
      end
      false
    end

    # Open and existing comment
    #   +data+ contains info about the comment
    def self.open(data, options={})
      self.new( self.extract_comment_from(data, options) )
    end

    # =============================================================================================
    # PUBLIC INSTANCE METHODS
    # =============================================================================================

    # Save the instance to disk
    #   +archive_name+ the parent directory of the article, we're forcing the parameter to ensure
    #   the archive_name is established before attemping to write it to disk
    def save(archive_name)
      self.archive_name = archive_name
      if File.directory? self.archive_path
        Comment.save_new(self)
      end
    end

    # Absolute path of the comment file
    def expand_file
      return unless self.archive_name
      File.join(self.archive_path, self.name)
    end

    # The absolute file path of the archive
    def archive_path
      File.join(Aerial.repo.working_dir, Aerial.config.articles.dir, self.archive_name)
    end

    # Make sure comment has the required data
    def valid?
      return false if self.email.blank? || self.author.blank? || self.body.blank?
      true
    end

    # Ask Akismetor if comment is spam
    def suspicious?
      return self.spam if self.spam
      self.spam = Akismetor.spam?(akismet_attributes)
    end

    # Create a unique file name for this comment
    def generate_name!
      return self.name unless self.name.nil?

      extenstion = self.suspicious? ? "spam" : "comment"
      self.name = "#{DateTime.now.strftime("%Y%m%d%H%d%S")}_#{self.email}.#{extenstion}"
    end

    # String representation
    def to_s
      me = ""
      me << "Author: #{self.author} \n" if self.author
      me << "Published: #{self.published_at} \n" if self.published_at.to_s
      me << "Email: #{self.email} \n" if self.email
      me << "Homepage: #{self.homepage} \n" if self.homepage
      me << "User IP: #{self.user_ip} \n" if self.user_ip
      me << "User Agent: #{self.user_agent} \n" if self.user_agent
      me << "Spam?: #{self.spam} \n" if self.user_agent
      me << "\n#{self.body}" if self.body
      return me
    end

    private

    # =============================================================================================
    # PRIVATE CLASS METHODS
    # =============================================================================================

    # Create a new Comment instance with data from the given file
    def self.extract_comment_from(data, options)
      comment_file          = data.to_s
      comment               = Hash.new
      comment[:id]          = self.extract_header("id", comment_file)
      comment[:user_ip]          = self.extract_header("ip", comment_file)
      comment[:user_agent]  = self.extract_header("user-agent", comment_file)
      comment[:referrer]    = self.extract_header("referrer", comment_file)
      comment[:permalink]   = self.extract_header("permalink", comment_file)
      comment[:author]      = self.extract_header("author", comment_file)
      comment[:email]       = self.extract_header("email", comment_file)
      comment[:homepage]    = self.extract_header("homepage", comment_file)
      comment[:published_at]= DateTime.parse(self.extract_header("published", comment_file))
      comment[:body]        = self.scan_for_field(comment_file, self.body_field)
      return comment
    end

    # Write the contents of the comment to the same directory as the article
    def self.save_new(comment)
      return false unless comment && comment.archive_name
      comment.generate_name!
      comment.published_at = DateTime.now
      path = File.join(Aerial.config.articles.dir, comment.archive_name, comment.name)
      Dir.chdir(Aerial.repo.working_dir) do
        File.open(path, 'w') do |file|
          file << comment.to_s
        end
      end
      Aerial::Git.commit_and_push(path, "New comment: #{comment.name}")
      return comment
    end

    # =============================================================================================
    # PRIVATE INSTANCE METHODS
    # =============================================================================================

    # Make sure the url is cleaned
    def sanitize_url
      return unless self.homepage
      homepage.gsub!(/^(.*)/, 'http://\1') unless homepage =~ %r{^http://} or homepage.empty?
    end

    # Try to prevent spam with akismet
    def akismet_attributes
      {
        :key                  => Aerial.config.akismet.key,
        :blog                 => Aerial.config.akismet.url,
        :user_ip              => self.user_ip,
        :user_agent           => self.user_agent,
        :referrer             => self.referrer,
        :permalink            => self.permalink,
        :comment_type         => 'comment',
        :comment_author       => self.author,
        :comment_author_email => self.email,
        :comment_author_url   => self.homepage,
        :comment_content      => self.body
      }
    end

  end
end
