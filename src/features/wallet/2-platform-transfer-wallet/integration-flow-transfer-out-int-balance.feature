Feature: Integration Flow - Transfer out all integer balance
  As APISYS
  I want to call the merchant transfer APIs in sequence
  So that I can verify full integer-balance withdrawal behavior end to end

  Background:
    Given a merchant member exists with platform username "<platform_username>"

  Scenario: Transfer in 120.5 then transfer out without amount deducts 120 and leaves 0.5
    When APISYS requests transfer in with:
      | transfer_no       | <transfer_in_uuid_1> |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | 120.5                |
    Then the response should be successful
    And the wallet balance for "<platform_username>" in "<currency>" should become 120.5

    When APISYS requests transfer out with:
      | transfer_no       | <transfer_out_uuid_1> |
      | platform_username | <platform_username>   |
      | currency          | <currency>            |
    Then the response should be successful
    And the response should contain:
      | status | success |
      | amount | 120     |
    And the wallet balance for "<platform_username>" in "<currency>" should become 0.5

    When APISYS requests member wallet balances with:
      | platform_username | <platform_username> |
      | currencies        | <currency>          |
    Then the response should be successful
    And the response should contain balances:
      | <currency> | 0.5 |