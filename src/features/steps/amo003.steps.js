const { Given, When, Then } = require("@cucumber/cucumber");
const assert = require("assert");

Given(
  "I prepare an amount exceeding the balance by {float}",
  async function (extra) {
    const currency = this.vars.currency;

    const balance =
      this.vars[`wallet_${currency}_before`] ??
      (await this.walletBalance(currency));

    const amount = -(Math.max(balance, 0) + extra);
    this.vars.insufficient_payment_amount = String(amount);

    await this.attachInfo(`Amount to deduct: ${amount}`, {
      currency,
      balance,
      extra,
    });
  },
);

When("APISYS requests payment with:", async function (table) {
  const data = Object.fromEntries(
    table.rows().map(([field, value]) => [field, this.resolve(value)]),
  );

  await this.request(
    "POST",
    this.config.merchant_settings.request_payment_api,
    {
      transaction_no: data.transaction_no,
      platform_username: this.vars.platform_username,
      currency: data.currency,
      amount: Number(data.amount),
    },
  );
});

Then("the AMO003 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected successful response but got failure");
  }
});

Then("the AMO003 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected validation error but got success response");
  }
});
