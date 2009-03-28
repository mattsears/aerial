require "#{File.dirname(__FILE__)}/spec_helper"

describe 'comment' do

  before do
    setup_repo
    @article_one = Article.with_name("test-article-one")
    @article_two = Article.with_name("test-article-two")
    @comment = Comment.new
    Akismetor.stub!(:spam?).and_return(false)
  end

  it "should ensure url is clean" do
    ['http://example.com', 'example.com'].each do |url_str|
      comment = Comment.new(:homepage => url_str)
      comment.homepage.should == 'http://example.com'
    end
  end

  describe "when finding comments" do

    before(:each) do
      @article = Article.with_name("test-article-two")
      @comments = @article.comments
      @comment = @article.comments.first
    end

    it "should be an instance of an array" do
      @comments.should be_instance_of(Array)
    end

    it "should find all comments with an article id" do
      @comments.should_not be_empty
    end

    it "should assign an id to the comment" do
      @comment.object_id.should_not be_nil
    end

    it "should assign an author of the comment" do
      @comment.author.should == "Anonymous Coward"
    end

    it "should assign an email of the commenter" do
      @comment.email.should == "anonymous@coward.com"
    end

    it "should assign an IP address of the commenter" do
      @comment.user_ip.should == "127.0.0.1"
    end

    it "should assign a homepage of the commenter" do
      @comment.homepage.should == "http://littlelines.com"
    end

    it "should assign a referrer of the commenter" do
      @comment.referrer.should == "http://mattsears.com"
    end

    it "should assign a user-agent of the commenter" do
      @comment.user_agent.should == "CERN-LineMode/2.15 libwww/2.17b3"
    end

    it "should format the string version of the comment" do
      comment = Comment.new(:author => "author", :email => "test@test.com")
      comment.to_s.should == "Author: author \nPublished: #{comment.published_at} \nEmail: test@test.com \n"
    end

  end

  describe "when creating new comments" do

    before do
      @article = Article.with_name("test-article-two")
      @comment = Comment.create(@article.archive_name,
                                :author    => "Matt Sears",
                                :body      => "Comment content",
                                :email     => "matt@mattsears.com",
                                :published => Date.today,
                                :homepage  => "http://example.com")
    end

    it "should return a valid Comment object" do
      @comment.should be_instance_of(Comment)
      @comment.valid?.should == true
    end

    it "should return invalid if Comment doesn not contain all require fields" do
      @comment.email = ""
      @comment.valid?.should == false
    end

    it "should not create the comment if it is not valid" do
      @comment = Comment.create(@article, :author => "Matt").should == false
    end

    it "should create a new instance" do
      @comment.should_not be_nil
      @comment.author.should == "Matt Sears"
      @comment.body.should == "Comment content"
    end

    it "should generate a file name based on the author and current time" do
      @comment.name.should =~ /matt@mattsears.com.comment/
    end

    it "should calculate the absoulte path to the comment file" do
      @comment.expand_file.should == File.join(@repo_path,
                                               Aerial.config.articles.dir,
                                               @article.archive_name,
                                               @comment.name)
    end

    it "should calculate the absoulte path of the comment's archive directory" do
      @comment.archive_path.should == File.join(@repo_path,
                                                Aerial.config.articles.dir,
                                                @article.archive_name)
    end

    it "should write a new comment to disk" do
      File.exists?(@comment.expand_file).should == true
    end

    after(:each) do
      @comment = nil
    end

  end

  describe "when saving Comments" do

    before do
      @article = Article.with_name("test-article-two")
      @comment = Comment.new(:author    => "Matt Sears",
                             :body      => "Comment content",
                             :email     => "matt@mattsears.com",
                             :published => Date.today,
                             :homepage  => "http://example.com")
    end

    it "should NOT have written a new comment to disk yet" do
      @comment.expand_file.should be_nil
    end

    it "should save a comment to a valid archive path" do
      @comment.save(@article.archive_name).should == @comment
    end

    it "should write the comment to the article's archive path" do
      @comment.save(@article.archive_name).should_not be_nil
      @comment.expand_file.should == File.join(@repo_path,
                                               Aerial.config.articles.dir,
                                               @article.archive_name,
                                               @comment.name)
    end

    it "should assign a publication date of the comment" do
      @comment.save(@article.archive_name).should == @comment
      @comment.published_at.should be_instance_of(DateTime)
    end

    it "should write a new comment to disk" do
      @comment.save(@article.archive_name)
      File.exists?(@comment.expand_file).should == true
    end

    after do
      File.delete @comment.expand_file if @comment.expand_file
    end

  end

  describe "when handling spam" do

    before do
      @article = Article.with_name("test-article-two")
      @comment = Comment.new(:author    => "Spammer",
                             :body      => "Something spammy",
                             :email     => "spam@example.com",
                             :published => Date.today,
                             :homepage  => "http://spam.com")
      Akismetor.stub!(:spam?).and_return(true)
      @comment.save(@article.archive_name)
    end

    it "should flag the comment as suspicious" do
      @comment.suspicious?.should == true
    end

    it "should flag the comment is spam if Akismetor says so" do
      @comment.expand_file.should =~ /.spam/
    end

    after do
      File.delete @comment.expand_file if @comment.expand_file
    end

  end

end
