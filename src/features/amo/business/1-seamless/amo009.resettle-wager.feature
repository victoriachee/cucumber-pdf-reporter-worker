@seamless
Feature: AMO009 Resettle Wager
  As APISYS
  I resettle a terminal-state wager (Settled, Cancelled, Undone)
  So that Merchant adjusts the wallet
  And APISYS creates a Resettled wager referencing origin_wager_no

  Background:
    # create a pending wager and settle it before each resettlement scenario
    Given the member has positive wallet balance in "<currency>"
    And I prepare a deduction amount of 100
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
            "wager_no": <origin_wager_no>,
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

    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
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

  @success @business
  Scenario: Multiple resettlements on same origin wager
    Apply multiple resettlements on the same origin_wager_no
    Merchant updates wallet for each request

    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - Lose" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - Win" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_4>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_2>     |
      | ticket_no         | <ticket_no_3>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | 150                       |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 150

  @business
  Scenario: Zero amount
    Accept request with no wallet change

    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - Zero amount" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | 0                         |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should remain unchanged

  @edge
  Scenario: Support up to 6 decimal places
    Validate decimal precision up to 6 places is supported
    Wallet updates without rounding errors

    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - 6 decimal places" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -149.999999               |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 149.999999

  @idempotency
  Scenario: Idempotent request
    Process once per transaction_no
    Validate same reference_id is returned in both attempts
    Wallet is updated only once

    Given I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    And I call AMO009 "Resettle Wager - First request" API
    Then the response should be successful
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should decrease by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - Duplicate transaction_no" API
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged