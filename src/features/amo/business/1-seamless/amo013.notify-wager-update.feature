@seamless
Feature: AMO013 Notify Wager Update
  As APISYS
  I notify Merchant of wager updates
  So that Merchant has the latest wager details
  E.g. used when values are finalized later or corrections are needed

  Background:
    Given the member has positive wallet balance in "<currency>"

    # initial request payment
    When I call AMO003 "Request payment" API with:
    """
    {
      "transaction_no": <transaction_no_1>,
      "game_key": <game_key_seamless>,
      "parent_wager_no": <parent_wager_no>,
      "platform_username": <platform_username>,
      "currency": <currency>,
      "amount": -100,
      "orders": [
        {
          "wager_no": <wager_no_1>,
          "ticket_no": <ticket_no_1>,
          "type": <wager_type.normal_wager>,
          "amount": 100,
          "payment_amount": 100,
          "effective_amount": 100,
          "metadata": <metadata>,
          "metadata_type": <metadata_type>,
          "wager_time": <wager_time>,
          "is_system_reward": false
        }
      ]
    }
    """
    Then the response should be successful

  @success
  Scenario: Update after request payment
    No wallet change
    Validate updated wager values are received

    When I call AMO013 "Notify Wager Update" API with:
    """
    {
      "notification_type": "WAGER_UPDATE",
      "notifications": [
        {
          "game_type": <game_type_seamless>,
          "game_key": <game_key_seamless>,
          "wager_no": <wager_no_1>,
          "origin_wager_no": null,
          "ticket_no": <ticket_no_1>,
          "platform_username": <platform_username>,
          "type": <wager_type.normal_wager>,
          "status": <wager_status.pending>,
          "currency": <currency>,
          "amount": 100,
          "payment_amount": 100,
          "effective_amount": 80,
          "profit_and_loss": 0,
          "wager_time": <wager_time>,
          "settlement_time": null,
          "is_system_reward": false
        }
      ]
    }
    """
    Then the response should be successful

  @success
  Scenario: Update after settlement
    No wallet change
    Validate updated wager values are received

    When I call AMO007 "Settle Wager" API with:
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

    When I call AMO013 "Notify Wager Update" API with:
    """
    {
      "notification_type": "WAGER_UPDATE",
      "notifications": [
        {
          "game_type": <game_type_seamless>,
          "game_key": <game_key_seamless>,
          "wager_no": <wager_no_1>,
          "origin_wager_no": null,
          "ticket_no": <ticket_no_1>,
          "platform_username": <platform_username>,
          "type": <wager_type.normal_wager>,
          "status": <wager_status.settled>,
          "currency": <currency>,
          "amount": 100,
          "payment_amount": 100,
          "effective_amount": 80,
          "profit_and_loss": 5.1,
          "wager_time": <wager_time>,
          "settlement_time": <settlement_time>,
          "is_system_reward": false
        }
      ]
    }
    """
    Then the response should be successful