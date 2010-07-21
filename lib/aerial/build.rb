require "thor"
require File.dirname(__FILE__) + "/../aerial"

module Aerial

  class Build < Thor
    attr_reader :root
    include FileUtils
    include Thor::Actions

    desc "build", "Build alls static files."
    def build
      # TODO: Need a better way to find the root
      # @root = Pathname(File.dirname(__FILE__) + "/../../").expand_path
      @root = Pathname(File.dirname('.')).expand_path
      @site_path = "#{@root}/public/site"
      Aerial.new(@root, "/config/config.yml")
      Aerial::App.set :root, @root
      @articles = Aerial::Article.all
      @request = Rack::MockRequest.new(Aerial::App)
      build_style_css
      build_pages_html
      build_articles_html
      build_tags_html
      build_archives_html
      build_feed_xml
    end

    desc "build_style_css", "Build all css files."
    def build_style_css
      create_file "#{@site_path}/style.css" do
        @request.request('get', '/style.css').body
      end
    end

    desc "build_html", "Build all html files."
    def build_pages_html

      create_file "#{@site_path}/index.html" do
        @request.request('get', '/').body
      end

      create_file "#{@site_path}/articles.html" do
        @request.request('get', '/articles').body
      end
    end

    desc "build_articles_html", "Build all the single article pages."
    def build_articles_html
      @articles.each do |article|
        create_file "#{@site_path}/#{article.permalink}.html" do
          @request.request('get', "#{article.permalink}").body
        end
      end
    end

    desc "build_tags_html", "Build all the tag pages"
    def build_tags_html
      Aerial::Article.tags.each do |tag|
        create_file "#{@site_path}/tags/#{tag}.html" do
          @request.request('get', "/tags/#{tag}").body
        end
      end
    end

    desc "build_archives_html", "Build all the archive pages"
    def build_archives_html
      Aerial::Article.archives.each do |archive|
        create_file "#{@site_path}/archives/#{archive.first.first}.html" do
          @request.request('get', "/archives/#{archive.first.first}").body
        end
      end
    end

    desc "build_feed_xml", "Build the feed rss xml"
    def build_feed_xml
      create_file "#{@site_path}/feed.xml" do
        @request.request('get', "/feed.xml").body
      end
    end
  end
end
