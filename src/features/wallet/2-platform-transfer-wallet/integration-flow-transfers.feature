Feature: Integration Flow - Transfer lifecycle through merchant wallet APIs
  As APISYS
  I want to call the merchant wallet APIs in sequence
  So that I can verify transfer credit, debit, reversal, and balance retrieval end to end

  Background:
    Given a merchant member exists with platform username "<platform_username>"

  Scenario: Transfer in 100, get balance, transfer out 35, get balance, cancel transfer, get balance
    When APISYS requests transfer in with:
      | transfer_no       | <transfer_in_uuid_1> |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | 100                  |
    Then the response should be successful
    And the response should contain:
      | status | success |
    And the wallet balance for "<platform_username>" in "<currency>" should become 100

    When APISYS requests member wallet balances with:
      | platform_username | <platform_username> |
      | currencies        | <currency>          |
    Then the response should be successful
    And the response should contain balances:
      | <currency> | 100 |

    When APISYS requests transfer out with:
      | transfer_no       | <transfer_out_uuid_1> |
      | platform_username | <platform_username>   |
      | currency          | <currency>            |
      | amount            | -35                   |
    Then the response should be successful
    And the response should contain:
      | status | success |
      | amount | -35     |
    And the wallet balance for "<platform_username>" in "<currency>" should become 65

    When APISYS requests member wallet balances with:
      | platform_username | <platform_username> |
      | currencies        | <currency>          |
    Then the response should be successful
    And the response should contain balances:
      | <currency> | 65 |

    When APISYS requests cancel transfer with:
      | transfer_no | <transfer_out_uuid_1> |
    Then the response should be successful
    And the response should contain:
      | reference_id | any non-empty value |
    And the wallet balance for "<platform_username>" in "<currency>" should become 100

    When APISYS requests member wallet balances with:
      | platform_username | <platform_username> |
      | currencies        | <currency>          |
    Then the response should be successful
    And the response should contain balances:
      | <currency> | 100 |