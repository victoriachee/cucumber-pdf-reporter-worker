@seamless
Feature: AMO007 Settle Wager
  As APISYS
  I settle a wager (Pending or Partial Settled)
  So that Merchant adjusts the wallet
  And APISYS updates wager to Settled or Partial Settled

  Background:
    # create a pending wager before each settlement scenario
    Given the "<currency>" wallet has at least "100" balance and I prepare "deduction_amount"
    When I call AMO003 "Request Payment - Create pending wager" API with:
      """
      {
        "transaction_no": <transaction_no_1>,
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

  @success
  Scenario: Full settlement
    Apply full settlement amount to wallet
    Validate settlement can be completed without partial_settlement_history

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Full settlement" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 150,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should increase by 150

  @success
  Scenario: Partial settlement
    Apply partial settlement amount to wallet
    Validate the same wager_no can be settled in parts before final settlement

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Partial settlement" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 40,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should increase by 40

    
  @business
  Scenario: Support multiple partial settlements for the same wager_no
    Process multiple partial settlements for the same wager_no
    Validate repeated partial settlements are allowed before final settlement
    Wallet increases by each partial settlement amount when processed

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Partial settlement 1" API with:
      """
      {
        "transaction_no": <partial_transaction_no_1>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 30,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 30

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Partial settlement 2" API with:
      """
      {
        "transaction_no": <partial_transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 25,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 25

  @success @business
  Scenario: Final settlement after partial settlements
    Apply only remaining amount to wallet
    Validate only unprocessed partial settlement amounts are applied
    Validate settlement can be completed with partial_settlement_history

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Partial settlement 1" API with:
      """
      {
        "transaction_no": <partial_transaction_no_1>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 20,
        "effective_amount": 20,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 20

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Partial settlement 2" API with:
      """
      {
        "transaction_no": <partial_transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 15,
        "effective_amount": 15,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 15

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Final settlement with partial history" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 80,
        "effective_amount": 80,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false,
        "partial_settlement_history": [
          {
            "transaction_no": <partial_transaction_no_1>,
            "amount": 20,
            "settlement_time": <settlement_time>
          },
          {
            "transaction_no": <partial_transaction_no_2>,
            "amount": 15,
            "settlement_time": <settlement_time>
          },
          {
            "transaction_no": <partial_transaction_no_3>,
            "amount": 5,
            "settlement_time": <settlement_time>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should increase by 85


  @business
  Scenario: Zero amount
    Accept request with no wallet change

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Zero amount - Lose" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 0,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should remain unchanged

  @edge
  Scenario: Support up to 6 decimal places
    Validate decimal precision up to 6 places is supported
    Wallet updates without rounding errors

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - 6 decimal places" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 1.123456,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should increase by 1.123456

  @idempotency
  Scenario: Idempotent request
    Process once per transaction_no
    Validate same reference_id is returned in both attempts
    Wallet is updated only once

    Given I record the current balance in "<currency>" wallet
    When I prepare a request payload with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 150,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    And I call AMO007 "Settle Wager - First request" API
    Then the response should be successful
    And I store the full response as "first_response"
    And the balance in "<currency>" wallet should increase by 150

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Duplicate transaction_no" API
    Then the response should be the same as stored response "first_response"
    And the balance in "<currency>" wallet should remain unchanged