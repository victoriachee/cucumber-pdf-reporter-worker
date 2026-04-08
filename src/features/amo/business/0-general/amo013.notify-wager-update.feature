@general
Feature: AMO013 Notify Wager Metadata Update
  As APISYS
  I notify Merchant of wager metadata changes
  So that Merchant fetches latest wager data via AGI004 Get List of Wagers API

  @success
  Scenario: Notify single metadata update
    Notify update for one wager

    When I call AMO013 API with:
    """
    {
      "notification_type": "WAGER_METADATA_UPDATE",
      "notifications": [
        {
          "game_type": <game_type>,
          "game_key": <game_key>,
          "wager_no": <wager_no_1>,
          "origin_wager_no": null,
          "ticket_no": <ticket_no_1>,
          "platform_username": <platform_username>,
          "type": <wager_type.normal_wager>,
          "status": <wager_status.settled>,
          "currency": <currency>,
          "amount": 100,
          "payment_amount": 100,
          "effective_amount": 100,
          "profit_and_loss": 50,
          "wager_time": <wager_time>,
          "settlement_time": <settlement_time>,
          "is_system_reward": false,
          "metadata": <metadata>,
          "metadata_type": <metadata_type>
        }
      ]
    }
    """
    Then the response should be successful

  @success
  Scenario: Notify multiple metadata updates
    Notify updates for multiple wagers

    When I call AMO013 API with:
    """
    {
      "notification_type": "WAGER_METADATA_UPDATE",
      "notifications": [
        {
          "game_type": <game_type>,
          "game_key": <game_key>,
          "wager_no": <wager_no_1>,
          "origin_wager_no": null,
          "ticket_no": <ticket_no_1>,
          "platform_username": <platform_username>,
          "type": <wager_type.normal_wager>,
          "status": <wager_status.settled>,
          "currency": <currency>,
          "amount": 100,
          "payment_amount": 100,
          "effective_amount": 100,
          "profit_and_loss": 50,
          "wager_time": <wager_time>,
          "settlement_time": <settlement_time>,
          "is_system_reward": false,
          "metadata": <metadata>,
          "metadata_type": <metadata_type>
        },
        {
          "game_type": <game_type>,
          "game_key": <game_key>,
          "wager_no": <wager_no_2>,
          "origin_wager_no": null,
          "ticket_no": <ticket_no_2>,
          "platform_username": <platform_username>,
          "type": <wager_type.normal_wager>,
          "status": <wager_status.settled>,
          "currency": <currency>,
          "amount": 100,
          "payment_amount": 100,
          "effective_amount": 100,
          "profit_and_loss": 50,
          "wager_time": <wager_time>,
          "settlement_time": <settlement_time>,
          "is_system_reward": false,
          "metadata": <metadata>,
          "metadata_type": <metadata_type>
        }
      ]
    }
    """
    Then the response should be successful

  @validation @contract
  Scenario: Allow nullable fields
    Nullable fields are accepted

    When I call AMO013 API with:
    """
    {
      "notification_type": "WAGER_METADATA_UPDATE",
      "notifications": [
        {
          "game_type": <game_type>,
          "game_key": <game_key>,
          "wager_no": <wager_no_1>,
          "origin_wager_no": null,
          "ticket_no": null,
          "platform_username": <platform_username>,
          "type": <wager_type.normal_wager>,
          "status": <wager_status.settled>,
          "currency": <currency>,
          "amount": 100,
          "payment_amount": 100,
          "effective_amount": 100,
          "profit_and_loss": 50,
          "wager_time": <wager_time>,
          "settlement_time": null,
          "is_system_reward": false,
          "metadata": <metadata>,
          "metadata_type": <metadata_type>
        }
      ]
    }
    """
    Then the response should be successful