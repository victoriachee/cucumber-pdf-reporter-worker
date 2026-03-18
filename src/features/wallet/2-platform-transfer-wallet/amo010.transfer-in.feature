Feature: AMO010 Request Transfer In
  As APISYS
  I want to call the merchant transfer in API
  So that I can credit funds into the member wallet

  Background:
    Given a merchant member exists

  Scenario: Transfer in increases wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS requests transfer in with:
      | field              | value                |
      | platform_username  | <platform_username>  |
      | transfer_no        | <transfer_no_1>      |
      | currency           | <currency>           |
      | amount             | 75.125               |
    Then the AMO010 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should increase by 75.125

  Scenario: Zero amount transfer does not change balance
    Given I record the current wallet balance in "<currency>"
    When APISYS requests transfer in with:
      | field              | value                |
      | platform_username  | <platform_username>  |
      | transfer_no        | <transfer_no_2>      |
      | currency           | <currency>           |
      | amount             | 0                    |
    Then the AMO010 response should be successful
    And the response should contain:
      | field  | value |
      | status | 1     |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Validation fails when amount precision is invalid
    When APISYS requests transfer in with:
      | field              | value                |
      | platform_username  | <platform_username>  |
      | transfer_no        | <transfer_no_3>      |
      | currency           | <currency>           |
      | amount             | 1.1234567            |
    Then the AMO010 response should fail validation

  Scenario: Validation fails when amount is negative
    When APISYS requests transfer in with:
      | field              | value                |
      | platform_username  | <platform_username>  |
      | transfer_no        | <transfer_no_4>      |
      | currency           | <currency>           |
      | amount             | -1                   |
    Then the AMO010 response should fail validation