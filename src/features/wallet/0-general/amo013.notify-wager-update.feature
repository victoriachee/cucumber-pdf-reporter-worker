Feature: AMO013 Notify Wager Update
  As APISYS
  I want to notify the merchant of wager updates

  Scenario: Successful wager notification
    When APISYS notifies wager update with:
      """
      {
        "notification_type": "typeA",
        "notifications": [
          {
            "game_type": "IMSPORT",
            "game_key": "IMSPORT",
            "wager_no": "0001-20250117140015-188011927396-3",
            "origin_wager_no": "0001-20250117140015-188011927396-1",
            "ticket_no": "ticketno_123",
            "platform_username": "member01",
            "type": 3,
            "status": 2,
            "currency": "CNY",
            "amount": 10.1,
            "payment_amount": 10.1,
            "effective_amount": 10,
            "profit_and_loss": 5.1,
            "wager_time": 1720694402,
            "settlement_time": 1720698600,
            "is_system_reward": true
          },
          {
            "game_type": "CRASH",
            "game_key": "CRASH_V2",
            "wager_no": "0002-20250117140015-188011927398-1",
            "origin_wager_no": null,
            "ticket_no": null,
            "platform_username": "member02",
            "type": 1,
            "status": 2,
            "currency": "CNY",
            "amount": 5.1,
            "payment_amount": 5.1,
            "effective_amount": 5,
            "profit_and_loss": 0,
            "wager_time": 1720694403,
            "settlement_time": null,
            "is_system_reward": false
          }
        ]
      }
      """
    Then the AMO013 response should be successful

  Scenario: Notification with invalid currency
    When APISYS notifies wager update with:
      """
      {
        "notification_type": "typeA",
        "notifications": [
          {
            "game_type": "IMSPORT",
            "game_key": "IMSPORT",
            "wager_no": "0001-20250117140015-188011927396-3",
            "origin_wager_no": "0001-20250117140015-188011927396-1",
            "ticket_no": "ticketno_123",
            "platform_username": "member01",
            "type": 3,
            "status": 2,
            "currency": "INVALID",
            "amount": 10.1,
            "payment_amount": 10.1,
            "effective_amount": 10,
            "profit_and_loss": 5.1,
            "wager_time": 1720694402,
            "settlement_time": 1720698600,
            "is_system_reward": true
          }
        ]
      }
      """
    Then the AMO013 response should fail validation

  Scenario: Notification with invalid decimal precision
    When APISYS notifies wager update with:
      """
      {
        "notification_type": "typeA",
        "notifications": [
          {
            "game_type": "IMSPORT",
            "game_key": "IMSPORT",
            "wager_no": "0001-20250117140015-188011927396-3",
            "origin_wager_no": "0001-20250117140015-188011927396-1",
            "ticket_no": "ticketno_123",
            "platform_username": "member01",
            "type": 3,
            "status": 2,
            "currency": "CNY",
            "amount": 10.1234567,
            "payment_amount": 10.1,
            "effective_amount": 10,
            "profit_and_loss": 5.1,
            "wager_time": 1720694402,
            "settlement_time": 1720698600,
            "is_system_reward": true
          }
        ]
      }
      """
    Then the AMO013 response should fail validation