Feature: Article
    In order to an Article
    As anonymous
    wants to view the the first article

   Scenario: View a single article
       Given there is one article
       When I view the Article
       Then the title should be "Aerial | Congratulations! Aerial is configured correctly"
       Then I should see "Comments"
