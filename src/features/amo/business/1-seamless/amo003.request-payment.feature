@seamless
Feature: AMO003 Request Payment
  As APISYS
  I send a payment request for a wager (Creating) to Merchant
  So that Merchant deducts wallet 
  And APISYS updates wager status to Pending

  @success
  Scenario: Single wager payment
    Deduct amount from wallet for one wager

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    And I prepare a deduction amount of 10
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -<deduction_amount>,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": <deduction_amount>,
            "payment_amount": <deduction_amount>,
            "effective_amount": <deduction_amount>,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should decrease by "<deduction_amount>"

  @success
  Scenario: Multiple wagers same parent
    Deduct wallet once for multiple wagers under same parent_wager_no

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -10,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 5,
            "payment_amount": 5,
            "effective_amount": 5,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": true
          },
          {
            "wager_no": <wager_no_2>,
            "ticket_no": <ticket_no_2>,
            "type": <wager_type.system_reward>,
            "amount": 5,
            "payment_amount": 5,
            "effective_amount": 5,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": false
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should decrease by 10

  @business
  Scenario: Insufficient balance
    Accept request with no wallet change
    Validate correct response is returned

    Given I record the current wallet balance in "<currency>"
    And I prepare an amount exceeding the balance by 10
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -<amount_exceeding_balance>,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": <amount_exceeding_balance>,
            "payment_amount": <amount_exceeding_balance>,
            "effective_amount": <amount_exceeding_balance>,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field       | value            |
      | reference_id| <transaction_no> |
      | status      | 2                |
      | fail_reason | 3                |
    And the wallet balance in "<currency>" should remain unchanged

  @business
  Scenario: Zero amount
    Accept request with no wallet change

    Given I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": 0,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 0,
            "payment_amount": 0,
            "effective_amount": 0,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should remain unchanged

  @edge
  Scenario: Support up to 6 decimal places
    Wallet updates without rounding errors
    Validate decimal precision up to 6 places is supported

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -1.123456,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 1.123456,
            "payment_amount": 1.123456,
            "effective_amount": 1.123456,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should decrease by 1.123456

  @idempotency
  Scenario: Idempotent request
    Process once per transaction_no
    Validate same reference_id is returned in both attempts
    Wallet is updated only once

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    And I prepare a deduction amount of 10
    When I prepare a request payload with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -<deduction_amount>,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": <deduction_amount>,
            "payment_amount": <deduction_amount>,
            "effective_amount": <deduction_amount>,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    And I call AMO003 "Request Payment - First request" API
    Then the response should be successful
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should decrease by "<deduction_amount>"

    Given I record the current wallet balance in "<currency>"
    When I call AMO003 "Request Payment - Duplicate transaction_no" API
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged

  @validation
  Scenario: Reject positive amount
    Validate request payment amount must not be positive

    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": 5,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 5,
            "payment_amount": 5,
            "effective_amount": 5,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should fail validation

  @validation @contract
  Scenario: Reject amount exceeding 6 decimal places
    Note: APISYS should send valid payload
    Test contract: Amount exceeding 6 decimal places should fail

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -1.1234567,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 1.1234567,
            "payment_amount": 1.1234567,
            "effective_amount": 1.1234567,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should fail validation

  @validation @contract
  Scenario Outline: Reject request with missing required field "<required_field>"
    Note: APISYS should send complete payload
    Test contract: missing required fields should fail
    Wallet remains unchanged

    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -5,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 5,
            "payment_amount": 5,
            "effective_amount": 5,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": true
          }
        ]
      }
      """
    And I remove "<required_field>" from the request payload
    When I call AMO003 API
    Then the response should fail validation
    And the wallet balance in "<currency>" should remain unchanged

    Examples:
      | required_field    |
      | transaction_no    |
      | game_key          |
      | parent_wager_no   |
      | platform_username |
      | currency          |
      | amount            |
      | orders            |