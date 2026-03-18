const { When, Then } = require("@cucumber/cucumber");

When("APISYS requests transfer in with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.deposit_payment_api,
    payload,
  );
});

Then("the AMO010 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO010 response to be successful");
  }
});

Then("the AMO010 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected AMO010 response to fail validation");
  }
});
