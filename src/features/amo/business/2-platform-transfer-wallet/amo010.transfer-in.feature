@transfer
Feature: AMO010 Request Transfer In
  As APISYS
  I request transfer in to Merchant
  So that Merchant credits the wallet
  And APISYS records the transfer result

  Scenario: Transfer in increases wallet balance
    Wallet increases by transfer amount
    Validate successful response

    Given I record the current wallet balance in "<currency>"
    When I call AMO010 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | 175.125                     |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | any non-empty value         |
      | status            | 1                           |
    And the wallet balance in "<currency>" should increase by 175.125

  Scenario: Idempotent transfer
    Wallet updates once per transfer_no
    Validate same reference_id is returned in both attempts
    
    Given I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | 100                         |
      | session_id        | <session_id>                |
    And I call AMO010 "Request Transfer In - First request" API
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | any non-empty value         |
      | status            | 1                           |
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should increase by 100

    Given I record the current wallet balance in "<currency>"
    When I call AMO010 "Request Transfer In - Duplicate transfer_no" API
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Zero amount
    Accept request with no wallet change
    Validate successful response

    Given I record the current wallet balance in "<currency>"
    When I call AMO010 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | 0                           |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | any non-empty value         |
      | status            | 1                           |
    And the wallet balance in "<currency>" should remain unchanged

  @validation @contract
  Scenario Outline: Reject request with missing required field "<required_field>"
    Note: APISYS should send complete payload
    Test contract: missing required fields should fail
    Wallet remains unchanged

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | platform_username | <platform_username>         |
      | game_type         | <game_type_transfer_wallet> |
      | currency          | <currency>                  |
      | amount            | 100                         |
      | session_id        | <session_id>                |
    And I remove "<required_field>" from the request payload
    When I call AMO010 API
    Then the response should fail validation
    And the wallet balance in "<currency>" should remain unchanged

    Examples:
      | required_field    |
      | transfer_no       |
      | platform_username |
      | game_type         |
      | currency          |
      | amount       |
      | session_id        |