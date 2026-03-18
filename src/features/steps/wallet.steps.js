const { Given, Then } = require("@cucumber/cucumber");

// AMO001 - Get one specific member wallet balance
async function getWalletBalance(world, currency) {
  const res = await world.request(
    "GET",
    world.config.merchant_settings.get_payment_api,
    {
      platform_username: world.vars.platform_username,
      currencies: [currency],
    },
  );

  const data = world.responseData(res);

  return Number(data?.balances?.[currency] ?? 0);
}

Given(
  "the member has positive wallet balance in {string}",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const balance = await getWalletBalance(this, currency);

    if (balance <= 0) {
      throw this.error("Wallet balance must be positive for this scenario", {
        currency,
        balance,
      });
    }

    await this.attachInfo(`Balance (${currency}): ${balance}`);
  },
);

Given(
  "I record the current wallet balance in {string}",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const balance = await getWalletBalance(this, currency);
    this.vars[`wallet_${currency}_before`] = balance;

    await this.attachInfo(`Balance (${currency}): ${balance}`);
  },
);

Then(
  "the wallet balance in {string} should decrease by {float}",
  async function (currencyPlaceholder, amount) {
    const currency = this.resolve(currencyPlaceholder);
    const before = this.vars[`wallet_${currency}_before`] ?? 0;
    const balance = await getWalletBalance(this, currency);

    assert.strictEqual(
      after,
      before - amount,
      `Expected wallet ${currency} to decrease by ${amount}, before=${before}, after=${after}`,
    );

    await this.attachInfo(
      "Wallet balance check:",
      `Currency: ${currency}`,
      `Before: ${before}`,
      `After: ${after}`,
      `Expected decrease: ${amount}`,
    );
  },
);

Then(
  "the wallet balance in {string} should increase by {float}",
  async function (currencyPlaceholder, amount) {
    const currency = this.resolve(currencyPlaceholder);
    const before = this.vars[`wallet_${currency}_before`] ?? 0;
    const balance = await getWalletBalance(this, currency);

    assert.strictEqual(
      after,
      before + amount,
      `Expected wallet ${currency} to increase by ${amount}, before=${before}, after=${after}`,
    );

    await this.attachInfo(
      "Wallet balance check:",
      `Currency: ${currency}`,
      `Before: ${before}`,
      `After: ${after}`,
      `Expected increase: ${amount}`,
    );
  },
);

Then(
  "the wallet balance in {string} should remain unchanged",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const before = this.vars[`wallet_${currency}_before`] ?? 0;
    const balance = await getWalletBalance(this, currency);

    assert.strictEqual(
      after,
      before,
      `Expected wallet ${currency} to remain unchanged, before=${before}, after=${after}`,
    );

    await this.attachInfo(
      "Wallet balance check (unchanged):",
      `Currency: ${currency}`,
      `Before: ${before}`,
      `After: ${after}`,
    );
  },
);
