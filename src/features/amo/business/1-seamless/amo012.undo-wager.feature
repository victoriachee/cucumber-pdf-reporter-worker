@seamless
Feature: AMO012 Undo Wager
  As APISYS
  I undo a terminal-state wager (Settled or Cancelled)
  So that Merchant reverses prior wallet changes
  And APISYS creates an Undone wager referencing origin_wager_no

  Background:
    # Create the original wager W1 in pending state before each scenario.
    # Any terminal-state preparation (settle/cancel) is done inside the scenario.
    Given the "<currency>" wallet has at least "100" balance and I prepare "deduction_amount"
    When I call AMO003 "Request Payment - Create pending wager" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_1>        |
      | game_key          | <game_key_seamless>       |
      | parent_wager_no   | <parent_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -<deduction_amount>       |
      | orders            | <orders_payload>          |
    Then the response should be successful

  @success @business
  Scenario: Undo entire settled wager
    Validate both bet deduction and settlement payout are negated
    Wallet returns to pre-wager state

    # Flow:
    # W1 request payment    -> wallet -100
    # W1 settle to win      -> wallet +150
    # W2 undo entire wager  -> wallet -150

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
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
      | origin_wager_no   | <origin_wager_no>         |
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

  @business
  Scenario: Undo wager settlement result only
    Validate settlement result is negated and original wager deduction is retained
    Wallet returns to pre-settlement state and retains original wager deduction

    # Flow:
    # W1 request payment     -> wallet -100
    # W1 settle to win       -> wallet +150
    # W2 undo settlement     -> wallet -50

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
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
    When I call AMO012 "Undo Wager - Settlement only" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_4>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_2>         |
      | ticket_no         | <ticket_no_3>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -50                       |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should decrease by 50

  @business
  Scenario: Undo wager cancellation
    Reverse cancellation effect
    Validate refunded amount is deducted again
    Wallet returns to pre-cancellation state and retains original wager deduction

    # Flow:
    # W1 request payment  -> wallet -100
    # W1 cancel wager     -> wallet +100
    # W2 undo cancel      -> wallet -100
    #
    # This restores the original wager effect after the cancellation is reversed.
    Given I record the current balance in "<currency>" wallet
    When I call AMO008 "Cancel Wager" API with:
      | field             | value                 |
      | transaction_no    | <transaction_no_2>    |
      | game_key          | <game_key_seamless>   |
      | wager_no          | <origin_wager_no>     |
      | platform_username | <platform_username>   |
      | metadata          | <metadata>            |
      | metadata_type     | <metadata_type>       |
    Then the response should be successful
    And the balance in "<currency>" wallet should increase by 100

    Given I record the current balance in "<currency>" wallet
    When I call AMO012 "Undo Wager - Cancellation" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
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

  @business
  Scenario: Zero amount
    Accept request with no wallet change

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
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

    Given I record the current balance in "<currency>" wallet
    When I call AMO012 "Undo Wager - Zero amount" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | 0                         |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
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
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
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

    Given I record the current balance in "<currency>" wallet
    When I call AMO012 "Undo Wager - 6 decimal places" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -149.999999               |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the balance in "<currency>" wallet should decrease by 149.999999

  @idempotency
  Scenario: Idempotent request
    Process once per transaction_no
    Validate same reference_id is returned in both attempts
    Wallet is updated only once

    Given I record the current balance in "<currency>" wallet
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
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

    Given I record the current balance in "<currency>" wallet
    When I prepare a request payload with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    And I call AMO012 "Undo Wager - First request" API
    Then the response should be successful
    And I store the full response as "first_response"
    And the balance in "<currency>" wallet should decrease by 150

    Given I record the current balance in "<currency>" wallet
    When I call AMO012 "Undo Wager - Duplicate transaction_no" API
    Then the response should be the same as stored response "first_response"
    And the balance in "<currency>" wallet should remain unchanged