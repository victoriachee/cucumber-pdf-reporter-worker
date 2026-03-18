Feature: Wager lifecycle wallet correctness

Scenario: Complete wager lifecycle updates wallet correctly
Given player wallet balance is 100.00 USD

When a wager request is made with payment_amount 10.00
Then wallet balance should decrease by exactly 10.00
And wallet balance should be 90.00

When settlement amount is 15.00
Then wallet balance should increase by exactly 15.00
And wallet balance should be 105.00

When resettle amount is 10.00
Then wallet balance should decrease by exactly 5.00
And wallet balance should be 100.00

When undo wager request is made
Then wallet balance should increase by exactly 10.00
And wallet balance should be 110.00
