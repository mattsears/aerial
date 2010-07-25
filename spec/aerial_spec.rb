require "#{File.dirname(__FILE__)}/spec_helper"

describe 'main aerial application' do

  before do
    setup_repo
  end

  it "should load the configuration from the file" do
    Aerial.config.should_not be_nil
    Aerial.config.name.should == "Aerial"
    Aerial.config.public.dir.should == "public"
    Aerial.config.author.should == "Awesome Ruby Developor"
    Aerial.config.subtitle.should == "Article, Pages, and such"
    Aerial.config.email.should == "aerial@example.com"
  end

end
