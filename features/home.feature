Feature: Homepage
    In order to view recent Articles
    As anonymous
    wants to view the most recent articles

    Scenario: Opening the home page
        Given there are articles
        When I view the Homepage
        Then the title should be "Aerial | A Microblog by Matt Sears"
        Then I should see "Congratulations! Aerial is configured correctly"
        Then I should see a link to "Home":http://localhost:4567/home
        Then I should see a link to "About":http://localhost:4567/about
        Then I should see a link to "ruby":http://localhost:4567/tags/ruby
        Then I should see a link to "sinatra":http://localhost:4567/tags/sinatra
        Then I should see a link to "git":http://localhost:4567/tags/git
        Then I should see a link to "aerial":http://localhost:4567/tags/aerial
