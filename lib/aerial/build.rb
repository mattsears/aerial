require "thor"
require File.dirname(__FILE__) + "/../aerial"

module Aerial
  class Build < Thor
    attr_reader :root
    include Thor::Actions

    desc "build", "Build alls static files."
    method_options :config => 'config.yml'
    def build

      Aerial.new(options, :production)
      Aerial::App.set :root, Aerial.root
      Aerial::App.set :environment, :production
      @app = Aerial::App
      @app.set :root, @root
      @app.set :environment, :production
      # ENV['RACK_ENV'] = 'production'
      # Aerial.env = :production
      @request = Rack::MockRequest.new(@app)
      Aerial::Build.source_root(Aerial.root)
      @site_path = Aerial.config.static.dir
      @blog_path = File.join(@site_path, Aerial.config.articles.dir)
      @site = Aerial::Site.new

      build_pages_html
      build_style_css
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
      create_file "#{@site_path}/index.html", :force => true do
        @request.request('get', '/').body
      end
      create_file "#{@site_path}/#{Aerial.config.articles.dir}.html", :force => true do
        @request.request('get', Aerial.config.articles.dir).body
      end
      @site.read_pages.each do |f|
        path = f.chomp(File.extname(f))
        create_file "#{@site_path}/#{f.gsub(File.extname(f), '.html')}", :force => true do
          @request.request('get', "/#{path}").body
        end
      end
    end

    def build_articles_html
      @articles = Aerial::Article.all
      @articles.each do |article|
        create_file "#{@site_path}/#{article.permalink}.html", :force => true do
          @request.request('get', "#{article.permalink}").body
        end
      end
    end

    def build_tags_html
      Aerial::Article.tags.each do |tag|
        create_file "#{@blog_path}/tags/#{tag}.html", :force => true do
          @request.request('get', "/tags/#{tag}").body
        end
      end
    end

    def build_archives_html
      Aerial::Article.archives.each do |archive|
        create_file "#{@blog_path}/archives/#{archive.first.first}.html", :force => true do
          @request.request('get', "/archives/#{archive.first.first}").body
        end
      end
    end

    def build_feed_xml
      create_file "#{@site_path}/feed.xml", :force => true do
        @request.request('get', "/feed.xml").body
      end
    end

  end
end
