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

    # Homepage
    get '/' do
      @articles = Aerial::Article.recent(:limit => 10)
      haml(Aerial.config.views.default.to_sym)
    end

    # Articles
    get '/articles' do
      @content_for_sidebar = partial(:sidebar)
      @articles = Aerial::Article.recent(:limit => 10)
      haml(:articles)
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

    # Single page
    get '/:page' do
      haml(params[:page])
    end

    # Single article page
    get '/:year/:month/:day/:article' do
      link = [params[:year], params[:month], params[:day], params[:article]].join("/")
      @content_for_sidebar = partial(:sidebar)
      @article = Aerial::Article.with_permalink("/#{link}")
      throw :halt, [404, not_found ] unless @article
      @page_title = @article.title
      haml(:post)
    end

    # Article tags
    get '/tags/:tag' do
      @content_for_sidebar = partial(:sidebar)
      @articles = Aerial::Article.with_tag(params[:tag])
      haml(:articles)
    end

    # Article archives
    get '/archives/:year/:month' do
      @content_for_sidebar = partial(:sidebar)
      @articles = Aerial::Article.with_date(params[:year], params[:month])
      haml(:articles)
    end

    not_found do
      @content_for_sidebar = partial(:sidebar)
      haml(:not_found)
    end

  end
end
