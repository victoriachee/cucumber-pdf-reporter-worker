const { When, Then } = require("@cucumber/cucumber");

When("APISYS notifies wager update with payload:", async function (docString) {
  const payload = this.resolve(docString);

  await this.request(
    "POST",
    this.config.merchant_settings.notify_wager_api,
    payload,
  );
});

Then("the AMO013 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO013 response to be successful");
  }
});
