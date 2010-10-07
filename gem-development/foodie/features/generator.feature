Feature: Generating things
  In order to generate many a thing
  As a CLI newbie
  I want gem_name to hold my hand, tightly
  
  Scenario: Recipes
    When I run "foodie recipe dinner steak"
    Then the following files should exist:
      | dinner/steak.txt |
    Then the file "dinner/steak.txt" should contain:
      """
      ##### Ingredients #####
      Ingredients for delicious steak go here.
      
      
      ##### Instructions #####
      Tips on how to make delicious steak go here.
      """
