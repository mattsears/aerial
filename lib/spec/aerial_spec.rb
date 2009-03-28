require "#{File.dirname(__FILE__)}/spec_helper"

describe 'main aerial application' do

  before do
    @articles = Article.all
    setup_repo
  end

  it "should define the root directory" do
    AERIAL_ROOT.should_not be_nil
  end

  it "should define the configuration file" do
    CONFIG.should_not be_nil
  end

  it 'should show the default index page' do
    get '/'
    @response.should be_ok
  end

  it 'should send 404 properly' do
    get '/not-found.html'
    @response.status.should == 404
  end

  it "should render a single article page" do
    get '/2009/1/31/test-article'
    @response.status.should == 200
  end

  it "should render the home page" do
    get '/home'
    @response.status.should == 200
  end

  describe "calling /style.css" do

    before do
      get '/style.css'
    end

    it "should return an okay status code" do
      @response.status.should == 200
    end

    it "should return a css stylesheet" do
      @response.headers["Content-Type"].should == "text/css;charset=utf-8"
    end

  end

   describe "calling /tags" do

    before do
      @article = Article.new(:title        => "Test Article",
                             :tags         => "git, sinatra",
                             :published_at => DateTime.new,
                             :comments     => [],
                             :file_name    => "test-article")
      Aerial::Article.stub!(:with_tag).and_return([@article])
      get '/tags/git'
    end

    it "should return a valid response" do
      @response.status.should == 200
    end

    it "should return a response body" do
      @response.body.should_not be_empty
    end

  end

  describe "calling /feed" do

    before do
      @articles = Article.find_all
      Aerial::Article.stub!(:all).and_return(@articles)
      get '/feed'
    end

    it "should produce an rss tag" do
      @response.body.should have_tag('//rss')
    end

    it "should contain a title tag" do
      @response.body.should have_tag('//title').with_text(Aerial.config.title)
    end

    it "should contain a language tag" do
      @response.body.should have_tag('//language').with_text("en-us")
    end

    it "should contain a description tag that containts the subtitle" do
      @response.body.should have_tag('//description').with_text(Aerial.config.subtitle)
    end

    it "should contain an item tag" do
      @response.body.should have_tag('//item')
    end

    it "should have the title tags for the articles" do
      @response.body.should have_tag('//item[1]/title').with_text(@articles[0].title)
      @response.body.should have_tag('//item[2]/title').with_text(@articles[1].title)
    end

    it "should have the link tag with the articles permalink" do
      #@response.body.should have_tag('//item[1]/link').with_text("http://#{@articles[0].permalink}")
    end

    it "should have a pubDate tag with the article's publication date" do
      @response.body.should have_tag('//item[1]/pubDate').with_text(@articles[0].published_at.to_s)
      @response.body.should have_tag('//item[2]/pubDate').with_text(@articles[1].published_at.to_s)
    end

    it "should have a guid date that matches the articles id" do
      @response.body.should have_tag('//item[1]/guid').with_text(@articles[0].id)
      @response.body.should have_tag('//item[2]/guid').with_text(@articles[1].id)
    end

    after do
      @articles = nil
    end

  end

  describe "calling /feed" do

    before do
      @articles = Article.find_all
      Aerial::Article.stub!(:all).and_return(@articles)
      get '/articles'
    end

    it "should return a valid response" do
      @response.status.should == 200
    end

    it "should return a response body" do
      @response.body.should_not be_empty
    end

  end


  describe "calling /arhives" do
    before do
      @article = Article.new(:title        => "Test Article",
                             :body         => "Test Content",
                             :id           => 333,
                             :published_at => DateTime.new,
                             :comments     => [],
                             :file_name    => "test-article.article")
      Aerial::Article.stub!(:with_date).and_return([@article])
      get '/archives/year/month'
    end

    it "should return a valid response" do
      @response.status.should == 200
    end

  end

  describe "posting a new comment" do

    before do
      @article = Article.new(:title     => "Test Article",
                             :body      => "Test Content",
                             :file_name => "test-article",
                             :archive_name => "test-article",
                             :id        => 333)
      Aerial::Article.stub!(:find).and_return(@article)
      @article.stub!(:comments).and_return(Array.new)
      @article.stub!(:permalink).and_return('/permalink')
      post "/article/#{@article.id}/comments"
    end

    it "should return a valid response" do
      @response.status.should == 204
    end
  end

  describe "calling Git operations" do

    before do
      @dir = "#{Aerial.repo.working_dir}/articles/new_dir"
      FileUtils.mkdir(@dir)
      FileUtils.cd(@dir) do
        FileUtils.touch 'new.file'
      end
    end

    it "should commit all new untracked and tracked content" do
      Aerial.repo.status.untracked.should_not be_empty
      get '/'
      # Aerial.repo.status.untracked.should be_empty
    end

  end

end
