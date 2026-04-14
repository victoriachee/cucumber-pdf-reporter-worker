@seamless
Feature: AMO004 Notify Payment Failed
  As APISYS
  I notify payment failure for a wager (Creating)
  So that Merchant restores wallet
  And APISYS updates wager to Creation Failed

  @success
  Scenario: Existing payment
    Restore deducted wallet balance for failed payment
    Fails all wagers under the same parent_wager_no

    Given the "<currency>" wallet has at least "100" balance and I prepare "deduction_amount"
    And I record the current balance in "<currency>" wallet
    When I call AMO003 "Request Payment" API with:
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
    And the balance in "<currency>" wallet should decrease by 100

    Given I record the current balance in "<currency>" wallet
    When I call AMO004 "Notify Payment Failed" API with:
      | field             | value               |
      | transaction_no    | <transaction_no_2>  |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
    Then the response should be successful
    And the response should contain: 
      | field             | value               |
      | reference_id      | any non-empty value |
    And the balance in "<currency>" wallet should increase by 100

  @business
  Scenario: No existing payment
    Accept request with no wallet change

    When I call AMO004 "Notify Payment Failed" API with:
      | field             | value               |
      | transaction_no    | <transaction_no>    |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |

    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should remain unchanged