require "thor"
require File.dirname(__FILE__) + "/../aerial"

module Aerial
  class Build < Thor
    attr_reader :root
    include Thor::Actions

    desc "build", "Build alls static files."
    def build
      @root = Pathname(File.dirname('.')).expand_path
      Aerial.new(@root, "/config.yml")
      Aerial::App.set :root, @root
      Aerial::Build.source_root(@root)
      @site_path = Aerial.config.static.dir
      @blog_path = File.join(@site_path, Aerial.config.articles.dir)
      @articles = Aerial::Article.all
      @request = Rack::MockRequest.new(Aerial::App)
      @site = Aerial::Site.new
      build_pages_html
      #build_style_css
      build_articles_html
      build_tags_html
      build_archives_html
      build_feed_xml
      say "Static site generated"
    end

    private

    def build_style_css
      create_file "#{@site_path}/style.css" do
        @request.request('get', '/style.css').body
      end
    end

    def build_pages_html
      create_file "#{@site_path}/index.html" do
        @request.request('get', '/').body
      end
      create_file "#{@site_path}/#{Aerial.config.articles.dir}.html" do
        @request.request('get', Aerial.config.articles.dir).body
      end
      @site.read_pages.each do |f|
        path = f.chomp(File.extname(f))
        create_file "#{@site_path}/#{f.gsub(File.extname(f), '.html')}" do
          @request.request('get', "/#{path}").body
        end
      end
    end

    def build_articles_html
      @articles.each do |article|
        create_file "#{@site_path}/#{article.permalink}.html" do
          @request.request('get', "#{article.permalink}").body
        end
      end
    end

    def build_tags_html
      Aerial::Article.tags.each do |tag|
        create_file "#{@blog_path}/tags/#{tag}.html" do
          @request.request('get', "/tags/#{tag}").body
        end
      end
    end

    def build_archives_html
      Aerial::Article.archives.each do |archive|
        create_file "#{@blog_path}/archives/#{archive.first.first}.html" do
          @request.request('get', "/archives/#{archive.first.first}").body
        end
      end
    end

    def build_feed_xml
      create_file "#{@site_path}/feed.xml" do
        @request.request('get', "/feed.xml").body
      end
    end

  end
end
