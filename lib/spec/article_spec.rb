require "#{File.dirname(__FILE__)}/spec_helper"

describe 'article' do

  before do
    setup_repo
  end

  describe "when finding an article" do

    before(:each) do
      @article = Article.with_name("test-article-one")
    end

    it "should find an article with .article extenstion " do
      @article.should_not be_nil
    end

    it "should assign the article's author" do
      @article.author.should == "Matt Sears"
    end

    it "should assign the article title" do
      @article.title.should == "This is the first article"
    end

    it "should assign the file name of the article" do
      @article.file_name.should == "test-article.article"
    end

    it "should assing a list of tags" do
      @article.tags.should == ["ruby", "sinatra", "git"]
    end

    it "should assign the article date" do
      @article.id.should_not be_empty
    end

    it "should assign the article a publication date" do
      @article.published_at.should == DateTime.new(y=2009,m=1,d=31)
    end

    it "should assign the article a body attribute" do
      @article.body.should == "Lorem ipsum dolor sit amet, adipisicing **elit**, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"
    end

    it "should convert body text to body html" do
      @article.body_html.should have_tag('//strong').with_text('elit')
    end

    it "should calculate a permalink based on the directory the article is saved in" do
      @article.permalink.should == "/2009/1/31/test-article"
    end

  end

  describe "when opening the article with the blob id" do

    before(:each) do
      article_id = Article.with_name("test-article-one").id
      @article = Article.open(article_id, :fast => true)
    end

    it "should return a valid article object" do
      @article.should_not be_nil
    end

    it "should be an instance of an Article object" do
      @article.should be_instance_of(Article)
    end

  end

  describe "when finding the first article by the id" do

    before(:each) do
      article_id = Article.with_name("test-article-one").id
      @article = Article.find(article_id)
    end

    it "should return a valid article object with the id" do
      @article.should_not be_nil
    end

    it "should assign a file name to the article " do
      @article.file_name.should == "test-article.article"
    end

    it "should assign a tree id of the article" do
      @article.archive_name.should == "test-article-one"
    end

    it "should find the file path of where the article is stored" do
      @article.expand_path.should == "#{@repo_path}/articles/test-article-one/test-article.article"
    end

    it "should be an instance of an Article object" do
      @article.should be_instance_of(Article)
    end

  end

  describe "when articles don't exitst"  do

    it "should raise error when article could not be found" do
      lambda {
        @article = Article.find("doesn't exists")
      }.should raise_error(RuntimeError)
    end


    it "should raise error when article blob doesn't exist" do
      lambda {
        @article = Article.open("doesn't exists")
      }.should raise_error(RuntimeError)
    end

  end

  describe "when finding the second article by the id" do

    before(:each) do
      article_id = Article.with_name("test-article-two").id
      @article   = Article.find(article_id)
    end

    it "should find the second article and not the first" do
      @article.should_not be_nil
    end

    it "should assign a tree id of the article" do
      @article.archive_name.should == "test-article-two"
    end

  end

  describe "when finding an article by permalink" do

    before(:each) do
      @article = Article.find_by_permalink("/2009/1/31/test-article")
    end

    it "should return an article with a valid permalink" do
      @article.should be_instance_of(Article)
    end

    it "should return nil if article can't be found" do
      Article.find_by_permalink("does-not-exist").should == false
    end

    after(:each) do
      @article = nil
    end
  end

  describe "finding all articles" do

    before do
      @articles = Article.find_all
    end

    it "should return an array of article objects" do
      @articles.should be_instance_of(Array)
    end

    it "should contain more than one Article" do
      @articles.size.should == 3
    end

    it "should contain a comments array even if empty" do
      @articles.each do |article|
        article.comments.should_not be_nil
      end
    end

    after do
      @articles = nil
    end

  end

  describe "finding all articles with a specific tag" do

    before do
      @tag = "sinatra"
      @articles = Article.with_tag(@tag)
    end

    it "should return an array of articles" do
      @articles.should be_instance_of(Array)
    end

    it "should contain more than one Article" do
      @articles.size.should == 2
    end

    it "should include articles with a specific task" do
      @articles.each { |article| article.tags.should include(@tag)}
    end

  end

  describe "finding all articles by publication date" do

    before do
      @articles = Article.with_date(2009, 12)
    end

    it "should return an array of articles" do
      @articles.should be_instance_of(Array)
    end

    it "should return 2 articles" do
      @articles.size.should == 2
    end

    it "should return 2 articles published in the 12th month" do
      @articles.each { |a| a.published_at.month.should == 12}
    end

    it "should return 2 articles published in the year 2009" do
      @articles.each { |a| a.published_at.year.should == 2009}
    end

    it "should find articles with dates in string format" do
      articles = Article.with_date("2009", "01")
      articles.should_not be_empty
    end

  end


  describe "calling Article.archives" do

    before do
      @archives = Article.archives
    end

    it "should return an array" do
      @archives.should be_instance_of(Hash)
    end

    it "should return a list of publication dates" do
      @archives.should == {["2009/01", "January 2009"]=>1, ["2009/12", "December 2009"]=>2}
    end

  end

  describe "calling Article.exists?" do

    it "should determine if an article exists" do
      Article.exists?("test-article-two").should == true
    end

    it "should return false when article doesn't exist" do
      Article.exists?("ghost-article").should == false
    end

  end

  describe "calling Article.comments" do

    before(:each) do
      @article_two = Article.with_name("test-article-two")
    end

    it "should not be nil" do
      @article_two.should_not be_nil
    end

    it "should have comments attached to the article" do
      @article_two.comments.size.should == 1
    end

    it "should have a valid comment" do
      @article_two.comments.first.author.should == "Anonymous Coward"
    end

  end

  describe "calling Article.recent" do

    before(:each) do
      @articles = Article.recent(:limit => 2)
    end

    it "should return an array of arricles" do
      @articles.should_not be_nil
    end

    it "should limit the number of articles" do
      @articles.size.should == 2
    end

  end

  describe "calling Article.tags" do

    before(:each) do
      @tags = Article.tags
    end

    it "should return an array even if empty" do
      @tags.should be_instance_of(Array)
    end

    it "should return a list of tag strings" do
      @tags.size.should == 3
    end

  end

  describe "adding comments to an Article" do

    before(:each) do
      @article = Article.with_name("test-article-one")
      @comment = Comment.new(:author    => "Matt Sears",
                             :body      => "Comment content",
                             :email     => "matt@mattsears.com",
                             :published => Date.today,
                             :homepage  => "http://example.com")
    end

    it "should add a new comment with no errors" do
      @article.add_comment(@comment).should_not be_nil
    end

    it "should increase the size of the Article's comments" do
      @article.comments.should be_empty
      @article.add_comment(@comment)
      retrieve_article = Article.with_name("test-article-one")
      retrieve_article.comments.size.should == 1
    end

  end

end
