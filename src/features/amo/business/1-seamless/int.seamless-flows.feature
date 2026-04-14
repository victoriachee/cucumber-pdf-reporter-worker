@seamless @integration
Feature: Integration: Seamless Wager Correction Flows
  As APISYS
  I call Merchant wager lifecycle APIs in sequence
  To validate support for valid business correction flows
  And ensure the wallet reflects the correct net outcome

  Background:
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
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the balance in "<currency>" wallet should decrease by 100

  @success @business
  Scenario: Cancel then resettle
    Cancel a pending wager, then apply a final result via resettlement
    Wallet balance reflects the cancel refund and resettlement amount

    Given I record the current balance in "<currency>" wallet
    When I call AMO008 "Cancel Wager" API with:
      | field             | value               |
      | transaction_no    | <transaction_no_2>  |
      | game_key          | <game_key_seamless> |
      | wager_no          | <wager_no_1>        |
      | platform_username | <platform_username> |
      | metadata          | <metadata>          |
      | metadata_type     | <metadata_type>     |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should increase by 100

    Given I record the current balance in "<currency>" wallet
    When I call AMO009 "Resettle Wager - Win" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <wager_no_1>              |
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
    And the balance in "<currency>" wallet should increase by 150
  

  @success @business
  Scenario: Partial settle, cancel, then resettle
    Partially settle a wager, cancel it, then apply a final result via resettlement
    Wallet balance reflects each processed correction step

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Partial settlement" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <wager_no_1>              |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 40                        |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | true                      |
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 40

    Given I record the current balance in "<currency>" wallet
    When I call AMO008 "Cancel Wager" API with:
      | field             | value               |
      | transaction_no    | <transaction_no_3>  |
      | game_key          | <game_key_seamless> |
      | wager_no          | <wager_no_1>        |
      | platform_username | <platform_username> |
      | metadata          | <metadata>          |
      | metadata_type     | <metadata_type>     |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should increase by 60

    Given I record the current balance in "<currency>" wallet
    When I call AMO009 "Resettle Wager - Win" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_4>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <wager_no_1>              |
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
    And the balance in "<currency>" wallet should increase by 150

  @success @business
  Scenario: Cancel, undo, then resettle
  Cancel a wager, undo the cancellation, then apply a final result via resettlement
    Wallet balance reflects each processed correction step

    Given I record the current balance in "<currency>" wallet
    When I call AMO008 "Cancel Wager" API with:
      | field             | value               |
      | transaction_no    | <transaction_no_2>  |
      | game_key          | <game_key_seamless> |
      | wager_no          | <wager_no_1>        |
      | platform_username | <platform_username> |
      | metadata          | <metadata>          |
      | metadata_type     | <metadata_type>     |
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 100

    Given I record the current balance in "<currency>" wallet
    When I call AMO012 "Undo Wager - Cancellation" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <wager_no_1>              |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -100                      |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should decrease by 100

    Given I record the current balance in "<currency>" wallet
    When I call AMO009 "Resettle Wager - Win" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_4>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_3>             |
      | origin_wager_no   | <undo_wager_no_1>         |
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
    And the balance in "<currency>" wallet should increase by 150

  @success @business
  Scenario: Settle, undo, then resettle
    Settle a wager, undo the settlement, then apply a new result via resettlement
    Wallet balance reflects each processed correction step

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <wager_no_1>              |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 150                       |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | false                     |
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 150

    Given I record the current balance in "<currency>" wallet
    When I call AMO012 "Undo Wager - Entire wager" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <wager_no_1>              |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should decrease by 150

    Given I record the current balance in "<currency>" wallet
    When I call AMO009 "Resettle Wager - Win" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_4>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_3>             |
      | origin_wager_no   | <undo_wager_no_1>         |
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
    And the balance in "<currency>" wallet should increase by 150