@transfer @integration
Feature: Integration: Transfer Wallet Lifecycle
  As APISYS
  I call transfer APIs in sequence following business flow
  So that Merchant updates wallet correctly across the lifecycle

  Scenario: Transfer Wallet Game Session
    Wallet reflects transfer out, notify wager activity, and transfer in
    Validate final balance 

    # transfer out
    Given the "<currency>" wallet has at least "100" balance
    And I record the current balance in "<currency>" wallet
    When I call AMO011 "Request Transfer Out - Session start" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no_1>             |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -100                        |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the balance in "<currency>" wallet should decrease by 100

    When I call AMO013 "Notify Wager Update - Betting" API with:
      """
      {
        "notification_type": "WAGER_UPDATE",
        "notifications": [
          {
            "game_type": <game_type_transfer_wallet>,
            "game_key": <game_key_transfer_wallet>,
            "wager_no": <wager_no_1>,
            "origin_wager_no": null,
            "ticket_no": <ticket_no_1>,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.pending>,
            "currency": <currency>,
            "amount": 20,
            "payment_amount": 20,
            "effective_amount": 20,
            "profit_and_loss": 0,
            "wager_time": <wager_time>,
            "settlement_time": <settlement_time>,
            "is_system_reward": false
          }
        ]
      }
      """
    Then the response should be successful

    # transfer in
    Given I record the current balance in "<currency>" wallet
    When I call AMO010 "Request Transfer In - Session end" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no_2>             |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | 80                          |
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 80



  Scenario: Transfer Wallet Settlement and Re-settlement
    Validate wallet updates with session settlement, re-settlement and cancel
    Validate final balance 
    
    # transfer in
    Given I record the current balance in "<currency>" wallet
    When I call AMO010 "Request Transfer In - Settlement" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no_1>             |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | 3000                        |
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 3000

    # transfer out
    Given I record the current balance in "<currency>" wallet
    When I call AMO011 "Request Transfer Out - Re-settlement" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no_2>             |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -1000                       |
    Then the response should be successful
    And the balance in "<currency>" wallet should decrease by 1000

    # cancel transfer
    Given I record the current balance in "<currency>" wallet
    When I call AMO014 "Cancel Transfer" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no_2>             |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | any non-empty value         |
    And the balance in "<currency>" wallet should increase by 1000