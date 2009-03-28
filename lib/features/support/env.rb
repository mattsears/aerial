require 'spec'
require 'webrat'
require 'spec/expectations'
require 'webrat/sinatra'
require 'safariwatir'

$0 = File.expand_path(File.dirname(__FILE__) + "/../../aerial.rb")
require File.expand_path(File.dirname(__FILE__) + "/../../aerial")

browser = Watir::Safari.new
pages = {
  "Homepage" => "http://localhost:4567",
  "Article"  => "http://localhost:4567/2009/3/31/congratulations-aerial-is-configured-correctly"
}

Before do
  @browser = browser
  @pages = pages
end

# Common steps - should these go somewhere else?

When /^I view the (.*)$/ do |page|
  @page =  eval("#{page}.new(@browser)")
  @page.goto
end

Then /^the title should be "(.*)"$/ do |text|
  @browser.title.should == text
end

Then /^I should see "(.*)"$/ do |text|
  @browser.text.should include(text)
end

Then /I should see a link to "(.*)":(.*)/ do |text, url|
  @browser.link(:url, url).text.should == text
end
