Feature: Homepage
    In order to view recent Articles
    As anonymous
    wants to view the most recent articles

    Scenario: Opening the home page
        Given there are articles
        When I view the Homepage
        Then the title should be "Aerial | A Microblog by Matt Sears"
        Then I should see "Congratulations! Aerial is configured correctly"
        Then I should see a link to "Home":/home
        Then I should see a link to "About":/about
        Then I should see a link to "ruby":/tags/ruby
        Then I should see a link to "sinatra":/tags/sinatra
        Then I should see a link to "git":/tags/git
        Then I should see a link to "aerial":/tags/aerial
