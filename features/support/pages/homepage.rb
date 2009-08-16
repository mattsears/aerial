class Homepage
  def initialize(browser)
    @browser = browser
  end

  def goto
    @browser.goto 'http://localhost:4567/'
  end
end
