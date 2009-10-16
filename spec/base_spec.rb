require "#{File.dirname(__FILE__)}/spec_helper"

describe 'article' do

  before do
    setup_repo
  end

  it "should provide an interface to the logger when debug mode is on" do
    Aerial.debug = true
    Aerial.log("testing the logger!").should == true
  end

  it "should not log messages when debug mode is off" do
    Aerial.debug = false
    Aerial.log("this should not log").should be_nil
  end

  describe Aerial::Helper do

    it "should return 'Never' for invalid dates" do
      humanized_date("Invalid Date").should == "Never"
    end

    it "should properly format a valid date" do
      humanized_date(DateTime.now).should_not == "Never"
    end

    it "should create a list of hyperlinks for each tag" do
      tags = ["ruby", "sinatra"]
      link_to_tags(tags).should == "<a href='/tags/ruby' rel='ruby'>ruby</a>, <a href='/tags/sinatra' rel='sinatra'>sinatra</a>"
    end

    it "should default the current path to 'index' for the root of the application" do
      request.stub!(:env).and_return('/')
      path.should == "index"
    end

  end

  describe Aerial::Git do

    before do
      Aerial.repo.stub!(:add).and_return(true)
      Aerial.repo.stub!(:commit_index).and_return(true)
      Aerial.repo.status.untracked.stub!(:empty?).and_return(false)
    end

    it "should commit changes" do
      Aerial::Git.commit("/path/to/change", "message").should == true
    end

    it "should commit all changes" do
      Aerial::Git.commit_all.should == true
    end

    it "should add the remote repository " do
      Aerial::Git.push
    end

  end



end
