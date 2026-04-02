@seamless
Feature: AMO007 Settle Wager
  As APISYS
  I want to call the merchant settle wager API
  So that I can apply wager settlement results to the member wallet

  Background:
    Given a merchant member exists

  @success
  Scenario: Increase balance for full settlement
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 25.75,
        "effective_amount": 25.75,
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
    And the wallet balance in "<currency>" should increase by 25.75

  @success
  Scenario: Increase balance for partial settlement
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 99,
        "effective_amount": 99,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the response should contain:
      | field                 | value                     |
      | reference_id          | any non-empty value       |
    And the wallet balance in "<currency>" should increase by 99

  @success
  Scenario: Increase balance for final settlement with partial settlement history
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 10,
        "effective_amount": 10,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false,
        "partial_settlement_history": [
          {
            "transaction_no": <partial_transaction_no_1>,
            "amount": 2.5,
            "settlement_time": <settlement_time>
          },
          {
            "transaction_no": <partial_transaction_no_2>,
            "amount": 1,
            "settlement_time": <settlement_time>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 13.5

  @business
  Scenario: Allow zero amount without balance change
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 0,
        "effective_amount": 0,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And the response should contain:
      | field                  | value                    |
      | reference_id           | any non-empty value      |
    And the wallet balance in "<currency>" should remain unchanged

  @edge
  Scenario: Support up to 6 decimal places
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 1.123456,
        "effective_amount": 1.123456,
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
    And the wallet balance in "<currency>" should increase by 1.123456

  @idempotency
  Scenario: Return same result without balance change for duplicate transaction_no
    # first settle wager
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager" API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 10,
        "effective_amount": 10,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should increase by 10

    # settle wager with duplicate transaction_no
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Duplicate transaction_no" API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_2>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 10,
        "effective_amount": 10,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged

  @idempotency
  Scenario: Return same result without balance change for full settlement with duplicate wager_no
    
    # non-partial settle wager with wager_no
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Full Settle Wager" API with:
      """
      {
        "transaction_no": <transaction_no_1>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 10,
        "effective_amount": 10,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should increase by 10

    # non-partial settle wager with duplicate wager_no
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Full Settle Wager - Duplicate wager_no" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 10,
        "effective_amount": 10,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged


  
  @business
  Scenario: Increase balance for partial settlement with duplicate wager_no
    
    # partial settle wager with wager_no
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Partial Settle Wager" API with:
      """
      {
        "transaction_no": <transaction_no_1>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 10,
        "effective_amount": 10,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 10

    # partial settle wager with duplicate wager_no
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Partial Settle Wager - Duplicate wager_no" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 10,
        "effective_amount": 10,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 10

  @edge @business
  Scenario: Final settlement applies full partial history even if some partial calls were missing
    Given I record the current wallet balance in "<currency>"

    When I call AMO007 API with:
      """
      {
        "transaction_no": <partial_transaction_no_1>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 2.5,
        "effective_amount": 2.5,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 2.5

    Given I record the current wallet balance in "<currency>"

    When I call AMO007 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 10,
        "effective_amount": 10,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false,
        "partial_settlement_history": [
          {
            "transaction_no": <partial_transaction_no_1>,
            "amount": 2.5,
            "settlement_time": <settlement_time>
          },
          {
            "transaction_no": <partial_transaction_no_2>,
            "amount": 1,
            "settlement_time": <settlement_time>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 13.5