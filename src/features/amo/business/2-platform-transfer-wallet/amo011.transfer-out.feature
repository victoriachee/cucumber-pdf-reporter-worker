@transfer
Feature: AMO011 Request Transfer Out
  As APISYS
  I request transfer out from Merchant
  So that Merchant debits the wallet
  And funds are available for game session, settlement, or resettlement

  @success
  Scenario: Transfer out decreases wallet balance
    Wallet decreases by transfer amount
    Validate successful response

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO011 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -20.5                       |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should decrease by 20.5

  @business
  Scenario: Insufficient balance
    Transfer fails with status 2
    Wallet remains unchanged

    Given I record the current wallet balance in "<currency>"
    And I prepare an amount exceeding the balance by 10
    When I call AMO011 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -<amount_exceeding_balance> |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the response should contain:
      | field  | value |
      | status | 2     |
    And the wallet balance in "<currency>" should remain unchanged

  @business
  Scenario: Transfer all integer balance when amount missing
    Transfer integer portion of wallet balance
    Remaining decimal is retained in wallet

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO011 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the wallet balance in "<currency>" should equal the remaining decimal balance

  @idempotency
  Scenario: Idempotent transfer
    Wallet updates once per transfer_no
    Validate same reference_id is returned

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -15                         |
      | session_id        | <session_id>                |
    And I call AMO011 "Request Transfer Out - First request" API
    Then the response should be successful
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should decrease by 15

    Given I record the current wallet balance in "<currency>"
    When I call AMO011 "Request Transfer Out - Duplicate transfer_no" API
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged


  @validation
  Scenario: Invalid amount precision
    Request is rejected
    Wallet remains unchanged

    When I call AMO011 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | session_id        | <session_id>                |
      | amount            | -1.1234567                  |
    Then the response should fail validation