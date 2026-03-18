const { When, Then } = require("@cucumber/cucumber");

function parseCurrencies(raw) {
  try {
    const value = JSON.parse(raw || "[]");
    return Array.isArray(value) ? value : [];
  } catch {
    return [];
  }
}

When("APISYS requests member wallet balances with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request("GET", this.config.merchant_settings.get_payment_api, {
    platform_username: this.vars.platform_username,
    currencies: parseCurrencies(payload.currencies),
  });
});

Then("the AMO001 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected success but got failure");
  }
});

/**
 * @this {World}
 */
Then("the response should contain balances for:", function (table) {
  const { currencies } = table.rowsHash();
  const expectedCurrencies = parseCurrencies(currencies);
  const data = this.responseData(this.lastResponse);
  const balances = data?.balances;

  if (!balances || typeof balances !== "object") {
    throw this.error("No balances object in response");
  }

  const missing = expectedCurrencies.filter(
    (currency) => !(currency in balances),
  );
  if (missing.length) {
    throw this.error(`Missing balances for: ${missing.join(", ")}`);
  }
});

Then("the AMO001 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected validation error but got success");
  }
});
