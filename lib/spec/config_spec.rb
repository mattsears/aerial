require "#{File.dirname(__FILE__)}/spec_helper"

describe 'system configuration settings' do

  it "should set theme directory" do
    Aerial.config.views.dir.should == "views"
  end

  it "should set a value for blog directory" do
    Aerial.config.articles.dir.should == "articles"
  end

  it "should define the directory for the theme directory" do
    Aerial.config.theme_directory.should == "#{AERIAL_ROOT}/views"
  end

  it "should define the directory for the public directory" do
    Aerial.config.public.dir.should == "public"
  end

  it "should return false if config does not contain a variable" do
    Aerial.config.undefined == false
  end

end
