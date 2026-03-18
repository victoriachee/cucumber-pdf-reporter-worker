const { Given, Then } = require("@cucumber/cucumber");
const { matchesExpected } = require("../support/utils");

Given("a merchant member exists", async function () {
  const username = this.vars.platform_username;

  if (!username) {
    throw this.error("No platform_username provided in test context");
  }

  await this.attachInfo({ platform_username: username });
});

Then("the response should contain:", function (table) {
  const data = this.responseData(this.lastResponse);

  for (const { field, value } of table.hashes()) {
    const actual = data?.[field];

    if (!matchesExpected(actual, value)) {
      throw this.error("Response field assertion failed", {
        field,
        expected: value,
        actual,
      });
    }
  }
});
