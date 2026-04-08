@transfer
Feature: AMO013 Notify Wager Update
  As APISYS
  I notify Merchant of wager activity during a transfer session
  So that Merchant reconciles transfer out and transfer in values

  Background:
    Given the member has positive wallet balance in "<currency>"

    # transfer out to game
    When I call AMO011 "Request Transfer Out" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -100                        |
      | session_id        | <session_id>                |
    Then the response should be successful

  @success
  Scenario: Single wager update
    No direct wallet change
    Notified wager reflects session activity (e.g. Transfer out 100 → Transfer in 80 = 20 wagered)

    When I call AMO013 "Notify Wager Update" API with:
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
          "status": <wager_status.settled>,
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

  @success
  Scenario: Multiple wager updates
    No direct wallet change
    Validate all wager updates contribute to session total

    When I call AMO013 "Notify Wager Update" API with:
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
          "status": <wager_status.settled>,
          "currency": <currency>,
          "amount": 10,
          "payment_amount": 10,
          "effective_amount": 10,
          "profit_and_loss": 0,
          "wager_time": <wager_time>,
          "settlement_time": <settlement_time>,
          "is_system_reward": false
        },
        {
          "game_type": <game_type_transfer_wallet>,
          "game_key": <game_key_transfer_wallet>,
          "wager_no": <wager_no_2>,
          "origin_wager_no": null,
          "ticket_no": <ticket_no_2>,
          "platform_username": <platform_username>,
          "type": <wager_type.normal_wager>,
          "status": <wager_status.settled>,
          "currency": <currency>,
          "amount": 10,
          "payment_amount": 10,
          "effective_amount": 10,
          "profit_and_loss": 0,
          "wager_time": <wager_time>,
          "settlement_time": <settlement_time>,
          "is_system_reward": false
        }
      ]
    }
    """
    Then the response should be successful