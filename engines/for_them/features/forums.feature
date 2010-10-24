Feature: Forums
  In order to argue about the intricacies of corn
  As a user
  I want a place to do that
  
  Background:
    Given there are the following forums:
      | name       |
      | Corn Forum |
  
  Scenario: Viewing Forums
    Given I am on the homepage
    Then I should see "Corn Forum"
  
  
  

  
