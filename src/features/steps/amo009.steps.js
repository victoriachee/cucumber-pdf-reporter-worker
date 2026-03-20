const { When, Then } = require("@cucumber/cucumber");

When("APISYS resettles a wager with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.resettle_wager_api,
    payload,
  );
});

Then("the AMO009 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO009 response to be successful");
  }
});

Then("the AMO009 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected AMO009 response to fail validation");
  }
});
