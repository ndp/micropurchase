Feature: logging in and out
  As a vendor
  I should be able to log into the application
  So that I can bid on auctions

  Scenario: User logs in and clicks the edit profile link
    Given I am a user with a verified SAM account
    When I visit the home page
    And I click on the Login button
    Then I should see an "Authorize with GitHub" button

    When I click on the "Authorize with GitHub" button
    Then I should be on the home page

    When I visit my profile page
    And I click on the "Edit profile" button
    Then I should see a profile form with my info
    And there should be meta tags for the edit profile form

  Scenario: New user logs in, created and logs out via header link
    Given I only have a Github account
    When I visit the home page
    And I click on the Login button
    Then I should see an "Authorize with GitHub" button

    When I click on the "Authorize with GitHub" button
    And I visit my profile page
    Then I should see the name from github authentication
    And I should see a "Logout" button

    When I fill out the profile form
    And I click on the "Submit" button
    Then I should be on the home page
    And I should see my changes

    When I click on the "Logout" button
    Then I should not see my name
    And I should see a "Login" button

  Scenario: Existing user logs in
    Given I am a user with a verified SAM account
    When I visit the home page
    And I click on the Login button
    Then I should see an "Authorize with GitHub" button

    When I click on the "Authorize with GitHub" button
    Then I should see my name
    And I should see a "Logout" button
