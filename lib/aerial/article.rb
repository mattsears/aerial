require 'date'

module Aerial

  class Article < Content

    attr_reader :comments, :id,         :tags,      :archive_name, :body_html,
                :meta,     :updated_on, :published, :file_name

    # =============================================================================================
    # PUBLIC CLASS METHODS
    # =============================================================================================

    # Find all articles, including drafts
    def self.all(options={})
      self.find_all
    end

    # A quick way to load an article
    #   +id+ of the blob
    def self.open(id, options = {})
      self.find_by_blob_id(id, options)
    end

    # Find a single article
    #   +id+ of the blob
    def self.find(id, options={})
      self.find_by_id(id, options)
    end

    # Find a single article
    #   +name+ of the article file
    def self.with_name(name, options={})
      self.find_by_name(name, options)
    end

    # Find articles by tag
    #   +tag+ category
    def self.with_tag(tag, options={})
      self.find_by_tag(tag, options)
    end

    # Find articles by month and year
    #   +year+ of when article was published
    #   + month+ of when the article was published
    def self.with_date(year, month, options={})
      self.find_by_date(year, month, options)
    end

    # Return an article given its permalink value
    #   +link+ full path of the link
    def self.with_permalink(link, options={})
      self.find_by_permalink(link, options)
    end

    # Find the most recent articles
    def self.recent(options={})
      limit = options.delete(:limit) || 4
      self.find_all(options).first(limit)
    end

    # Return true if the article file exists
    def self.exists?(id)
      self.find_by_name(id) ? true : false
    end

    # Return all the tags assigned to the articles
    def self.tags
      self.find_tags
    end

    # Calculate the ar
    def self.archives
      self.find_archives
    end

    # =============================================================================================
    # PUBLIC INSTANCE METHODS
    # =============================================================================================

    # Add a comment to the list of this Article's comments
    #  +comment new comment
    def add_comment(comment)
      self.comments << comment.save(self.archive_name) # should we overload the << method?
    end

    # Permanent link for the article
    def permalink
      link = self.file_name.gsub('.article', '')
      "/#{published_at.year}/#{published_at.month}/#{published_at.day}/#{escape(link)}"
    end

    # Returns the absolute path of the Article's file
    def expand_path
      return "#{self.archive_expand_path}/#{self.file_name}"
    end

    # Returns the full path of the article's archive
    def archive_expand_path
      return unless archive = self.archive_name
      return "#{Aerial.repo.working_dir}/#{Aerial.config.articles.dir}/#{archive}"
    end

    private

    # =============================================================================================
    # PRIVATE CLASS METHODS
    # =============================================================================================

    # Find a single article given the article name
    #   +name+ file name
    def self.find_by_name(name, options={})
      if tree = Aerial.repo.tree/"#{Aerial.config.articles.dir}/#{name}"
        return self.find_article(tree)
      end
    end

    # Find the single article given the id
    #   +id+ the blob id
    #   +options+
    def self.find_by_id(article_id, options = {})
      if blog = Aerial.repo.tree/"#{Aerial.config.articles.dir}"
        blog.contents.each do |entry|
          article = self.find_article(entry, options)
          return article if article.id == article_id
        end
      end
      raise "Article not found"
    end

    # Find the article given the blob id.
    # This is a more efficient way of find and Article
    # However, we won't know anything else about the article such as the filename, tree, etc
    #   +id+ of the blob
    def self.find_by_blob_id(id, options = {})
      blob = Aerial.repo.blob(id)
      if blob.size > 0
        attributes = self.extract_article(blob, options)
        return Article.new(attributes) if attributes
      end
      raise "Article doesn't exists"
    end

    # Returns the articles with the given tag
    #   +tag+ the article category
    def self.find_by_tag(tag, options = {})
      articles = []
      self.find_all.each do |article|
        if article.tags.include?(tag)
          articles << article
        end
      end
      return articles
    end

    # Find a single article given the article's permalink value
    def self.find_by_permalink(link, options={})
      if blog = Aerial.repo.tree/"#{Aerial.config.articles.dir}/"
        blog.contents.each do |entry|
          article = self.find_article(entry, options)
          return article if article.permalink == link
        end
      end
      return false
    end

    # Find all the articles with the given month and date
    def self.find_by_date(year, month, options ={})
      articles = []
      self.find_all.each do |article|
        if article.published_at.year == year.to_i &&
            article.published_at.month == month.to_i
          articles << article
        end
      end
      return articles
    end

    # Find all the articles in the reposiotory
    def self.find_all(options={})
      articles = []
      if blog = Aerial.repo.tree/"#{Aerial.config.articles.dir}/"
        blog.contents.first( options[:limit] || 100 ).each do |entry|
          article = self.find_article(entry, options)
          articles << self.find_article(entry, options) if article
        end
      end
      return articles.sort_by { |article| article.published_at}.reverse
    end

    # Look in the given tree, find the article
    #   +tree+ repository tree
    #   +options+ :blob_id
    def self.find_article(tree, options = {})
      comments = []
      attributes = nil
      tree.contents.each do |archive|
        if archive.name =~ /article/
          attributes = self.extract_article(archive, options)
          attributes[:archive_name] = tree.name
          attributes[:file_name] = archive.name
        elsif archive.name =~ /comment/
          comments << Comment.open(archive.data, {})
        end
      end
      return Article.new(attributes.merge(:comments => comments)) if attributes
    end

    # Find all the tags assign to the articles
    def self.find_tags
      tags = []
      self.all.each do |article|
        tags.concat(article.tags)
      end
      return tags.uniq
    end

    # Create a histogram of article archives
    def self.find_archives
      dates = []
      self.all.each do |article|
        date = article.published_at
        dates << [date.strftime("%Y/%m"), date.strftime("%B %Y")]
      end
      return dates.inject(Hash.new(0)) { |h,x| h[x] += 1; h }
    end

    # Extract the Article attributes from the file
    def self.extract_article(blob, options={})
      file                   = blob.data
      article                = Hash.new
      article[:id]           = blob.id
      article[:author]       = self.extract_header("author", file)
      article[:title]        = self.extract_header("title", file)
      article[:tags]         = self.extract_header("tags", file).split(/, /)
      article[:published_at] = DateTime.parse(self.extract_header("published", file))
      article[:body]         = self.scan_for_field(file, self.body_field)
      article[:body_html]    = RDiscount::new( article[:body] ).to_html
      return article
    end

  end

end
