module Aerial
  class App < Sinatra::Base
    include Aerial

    before do
      # kill trailing slashes for all requests except '/'
      request.env['PATH_INFO'].gsub!(/\/$/, '') if request.env['PATH_INFO'] != '/'
    end

    # Helpers
    helpers do
      include Rack::Utils
      include Aerial::Helper
      alias_method :h, :escape_html
    end

    require File.expand_path(File.join(Aerial.root, 'app'))
    # Aerial::Overrides.load_local_app

    # Homepage
    get '/' do
      @articles = Aerial::Article.recent(:limit => 5)
      haml(Aerial.config.views.default.to_sym)
    end

    # Articles
    get "/#{Aerial.config.articles.dir}" do
      @articles = Aerial::Article.recent(:limit => 5)
      haml(:"#{Aerial.config.articles.dir}")
    end

    get '/feed*' do
      content_type 'text/xml', :charset => 'utf-8'
      @articles = Aerial::Article.all
      haml(:rss, :layout => false)
    end

    # Sassy!
    get '/style.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass(:style)
    end

    # Single article page
    get "/#{Aerial.config.articles.dir}/:year/:month/:day/:article" do
      link = [Aerial.config.articles.dir, params[:year], params[:month], params[:day], params[:article]].join("/")
      @article = Aerial::Article.with_permalink("#{link}")
      throw :halt, [404, not_found ] unless @article
      @page_title = @article.title
      haml(:"#{Aerial.config.articles.dir}/post")
    end

    # Article tags
    get "/#{Aerial.config.articles.dir}/tags/:tag" do
      @articles = Aerial::Article.with_tag(params[:tag])
      haml(:"#{Aerial.config.articles.dir}")
    end

    # Article archives
    get "/#{Aerial.config.articles.dir}/archives/:year/:month" do
      @articles = Aerial::Article.with_date(params[:year], params[:month])
      haml(:"#{Aerial.config.articles.dir}")
    end

    not_found do
      haml(:not_found)
    end

    # Try to find some kind of page
    get "*" do
      parts = params[:splat].map{ |p| p.sub(/\//, "") }
      page = File.expand_path(File.join(Aerial.root, 'views', parts))
      raise Sinatra::NotFound unless File.exist?("#{page}.haml")
      haml(parts.join('/').to_sym)
    end

  end
end
