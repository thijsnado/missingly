Feature: As a programmer
  When I call respond_to? with something done method missingly
  I want a true or false answer
  So that I know I can call the method.

  Scenario: querying respond_to? with good method
    Given the following class definition:
      """
      class Foo
        include Missingly::Matchers
        handle_missingly /find_by_*/ do
        end
      end
      """
    When I create a new instance of "Foo"
    And I call respond_to? with "find_by_id" on that instance
    Then I should get true
    When I call respond_to? with "fluffy_buffy_bunnies" on that instance
    Then I should get false
