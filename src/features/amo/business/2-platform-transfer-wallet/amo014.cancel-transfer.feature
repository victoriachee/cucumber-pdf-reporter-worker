@transfer
Feature: AMO014 Cancel Transfer
  As APISYS
  I cancal transfer
  So that Merchant reverses prior wallet change for the transfer

  Scenario: Cancel transfer in reverses wallet
    Validate successful response
    Wallet returns to pre-transfer state

    Given I record the current balance in "<currency>" wallet
    When I call AMO010 "Request Transfer In" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | 20                          |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 20

    Given I record the current balance in "<currency>" wallet
    When I call AMO014 "Cancel Transfer" API with:
      | field       | value         |
      | transfer_no | <transfer_no> |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should decrease by 20


  Scenario: Cancel transfer out reverses wallet
    Validate successful response
    Wallet returns to pre-transfer state

    Given the "<currency>" wallet has at least "20" balance
    And I record the current balance in "<currency>" wallet
    When I call AMO011 "Request Transfer Out" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -20                         |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the balance in "<currency>" wallet should decrease by 20

    Given I record the current balance in "<currency>" wallet
    When I call AMO014 "Cancel Transfer" API with:
      | field       | value         |
      | transfer_no | <transfer_no> |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should increase by 20


  Scenario: Cancel non-existing transfer
    Validate successful response
    Wallet remains unchanged

    Given I record the current balance in "<currency>" wallet
    When I call AMO014 "Cancel Transfer" API with:
      | field       | value         |
      | transfer_no | <transfer_no> |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should remain unchanged


  Scenario: Idempotent cancel transfer
    Wallet updates once per transfer_no
    Validate same reference_id is returned

    Given I record the current balance in "<currency>" wallet
    When I call AMO010 "Request Transfer In" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | 20                          |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 20
    
    Given I record the current balance in "<currency>" wallet
    When I prepare a request payload with:
      | field       | value         |
      | transfer_no | <transfer_no> |
    And I call AMO014 "Cancel Transfer - First request" API
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And I store the full response as "first_response"
    And the balance in "<currency>" wallet should decrease by 20

    Given I record the current balance in "<currency>" wallet
    When I call AMO014 "Cancel Transfer - Duplicate transfer_no" API
    Then the response should be the same as stored response "first_response"
    And the balance in "<currency>" wallet should remain unchanged