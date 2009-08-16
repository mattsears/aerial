class Article
  def initialize(browser)
    @browser = browser
  end

  def goto
    @browser.goto 'http://localhost:4567/2009/3/31/congratulations-aerial-is-configured-correctly'
  end
end
