const { When, Then } = require("@cucumber/cucumber");

When("APISYS settles a wager with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.settle_order_api,
    payload,
  );
});

Then("the AMO007 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO007 response to be successful");
  }
});

Then("the AMO007 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected AMO007 response to fail validation");
  }
});
