@general
Feature: AMO001 Get Member Wallet Balance
  As APISYS
  I request wallet balances from Merchant for wallet actions and display

  @success
  Scenario: Get balances for requested currencies
    Return balances only for requested currencies

    When I call AMO001 API with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | [<currency>]        |
    Then the response should be successful
    And the response should contain:
      | field             | value               |
      | platform_username | <platform_username> |
    And the response should contain balances for "<currency>"  
    
  @success
  Scenario: Get balances for all currencies
    Return balances for all supported currencies

    When I call AMO001 API with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | <currencies>        |
    Then the response should be successful
    And the response should contain:
      | field             | value               |
      | platform_username | <platform_username> |
    And the response should contain balances for "<currencies>"
  
  @validation
  Scenario: Reject invalid platform username
    Member must exist

    When I call AMO001 API with:
      | field             | value               |
      | platform_username | invalid_username    |
      | currencies        | [<currency>]        |
    Then the response should fail validation

  @validation
  Scenario: Reject empty currencies
    At least one currency is required

    When I call AMO001 API with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | []                  |
    Then the response should fail validation

  @validation @contract
  Scenario: Reject unsupported currency
    Invalid currency rejected

    When I call AMO001 API with:
      | field             | value                  |
      | platform_username | <platform_username>    |
      | currencies        | [<currency>,"INVALID"] |
    Then the response should fail validation

  @validation @contract
  Scenario Outline: Reject request with missing required field "<required_field>"
    Request rejected when required field missing

    When I prepare a request payload with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | [<currency>]        |
    And I remove "<required_field>" from the request payload
    And I call AMO001 API
    Then the response should fail validation

    Examples:
      | required_field    |
      | platform_username |
      | currencies        |