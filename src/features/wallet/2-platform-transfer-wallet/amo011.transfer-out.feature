Feature: AMO011 Request Transfer Out
  As APISYS
  I want to call the merchant transfer out API
  So that I can debit funds from the member wallet

  Background:
    Given a merchant member exists

  Scenario: Transfer out decreases wallet balance
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When APISYS requests transfer out with:
      | field              | value                |
      | platform_username  | <platform_username>  |
      | transfer_no        | <transfer_no_1>      |
      | currency           | <currency>           |
      | amount             | -20.5                |
    Then the AMO011 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | amount       | -20.5               |
      | status       | success             |
    And the wallet balance in "<currency>" should decrease by 20.5

  Scenario: Insufficient balance returns failed status
    Given I record the current wallet balance in "<currency>"
    And I prepare an insufficient-balance transfer out amount in "<currency>" with extra 1
    When APISYS requests transfer out with:
      | field              | value                          |
      | platform_username  | <platform_username>            |
      | transfer_no        | <transfer_no_3>                |
      | currency           | <currency>                     |
      | amount             | <insufficient_transfer_amount> |
    Then the AMO011 response should be successful
    And the response should contain:
      | field  | value  |
      | status | failed |
    And the wallet balance in "<currency>" should remain unchanged