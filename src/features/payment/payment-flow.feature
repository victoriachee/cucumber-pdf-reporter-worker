Feature: Payment lifecycle

  Scenario: Request payment lifecycle
    Given a user exists
    When I call wallet balance
    Then response should be success
    When I request payment
    Then payment status should be success
    When I settle wager
    Then settlement should succeed