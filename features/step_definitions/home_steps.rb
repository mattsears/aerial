
Given /^there are articles$/ do
  @articles = Aerial::Article.all
end

Then /^I should have 2 articles$/ do
  @articles.size.should == 2
end
