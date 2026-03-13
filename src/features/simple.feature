Feature: Showcase detailed test scenarios
  This feature demonstrates multiple scenarios, steps, and failures
  to show full reporting in the custom detailed reporter.

  # -------------------------------
  Scenario: Basic addition
  # -------------------------------
  Given the system is ready
  When I add 2 and 3
  Then the result should be 5

  Given the system is ready
  When I add 10 and 5
  Then the result should be 15

  # -------------------------------
  Scenario: List operations
  # -------------------------------
  Given an empty list
  When I push 1 into the list
  Then the list length should be 1
  And the list should contain 1

  Given an empty list
  When I push 42 into the list
  Then the list length should be 1
  And the list should contain 42

  # -------------------------------
  Scenario: User login with failure
  # -------------------------------
  Given a user who is not logged in
  When the user attempts to login with password "wrong-password"
  Then the user should be logged in

  # -------------------------------
  Scenario: User login with success
  # -------------------------------
  Given a user who is not logged in
  When the user attempts to login with password "secret"
  Then the user should be logged in