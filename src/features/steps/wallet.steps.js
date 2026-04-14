const { Given, Then } = require("@cucumber/cucumber");
const assert = require("assert");
const Decimal = require("decimal.js");

// AMO001 - Get one specific member wallet balance
async function getWalletBalance(world) {
  const currency = world.vars.currency;
  const platformUsername = world.vars.platform_username;
  const apiDetails = world.apiMap["AMO001"];
  await world.request(apiDetails.method, apiDetails.url, {
    platform_username: platformUsername,
    currencies: [currency],
  });

  const data = world.responseData();
  const balance = data?.balances?.[currency];

  if (balance !== 0 && !balance) {
    throw world.error("Failed to get wallet balance", {
      response: world.responseData(),
    });
  }

  return new Decimal(balance);
}

/**
 * Given the "<currency>" wallet has at least "1" balance
 * Given the "<currency>" wallet has at least "10" balance and I prepare "deduction_amount"
 */
Given(
  /^the "([^"]+)" wallet has at least "([^"]+)" balance(?: and I prepare "([^"]+)")?$/,
  async function (currencyKey, minimumKey, amountKey) {
    const currency = this.resolve(currencyKey);
    const minimum = new Decimal(this.resolve(minimumKey));
    const balance = await getWalletBalance(this);

    if (balance.lt(minimum)) {
      throw this.error("Wallet balance is below required minimum", {
        currency,
        balance: balance.toString(),
        minimum: minimum.toString(),
      });
    }

    this.vars.currency = currency;
    this.vars.beforeBalances ??= {};
    this.vars.beforeBalances[currency] = balance;

    if (amountKey) {
      const amount = minimum;

      if (amount.lte(0)) {
        throw this.error("Prepared amount must be positive", {
          amount: preparedAmount.toString(),
        });
      }

      if (amount.gt(balance)) {
        throw this.error("Prepared amount exceeds available balance", {
          currency,
          balance: balance.toString(),
          amount: preparedAmount.toString(),
        });
      }

      this.vars[amountKey] = amount.toString();

      await this.attachInfo("Amount prepared", {
        Context: currency,
        Balance: `Before ${balance}`,
        StoredAs: amountKey,
      });

      return;
    }

    await this.attachInfo("Balance checked", {
      Context: currency,
      Balance: `Current ${balance}`,
      MinimumRequired: minimum.toString(),
    });
  },
);

Given(
  "I record the current balance in {string} wallet",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const balance = await getWalletBalance(this);

    this.vars.beforeBalances ??= {};
    this.vars.beforeBalances[currency] = balance;

    await this.attachInfo("Balance recorded", {
      Context: currency,
      Balance: `Before ${balance}`,
    });
  },
);

Given(
  "I prepare an amount exceeding the balance by {float}",
  async function (extra) {
    const currency = this.vars.currency;

    const balance =
      this.vars.beforeBalances?.[currency] ?? (await getWalletBalance(this));

    const available = balance.greaterThan(0) ? balance : balance.constructor(0);
    const amount = available.plus(extra);

    this.vars.amount_exceeding_balance = amount.toString();

    await this.attachInfo("Amount prepared (exceeding)", {
      Context: currency,
      Balance: `Before ${balance} → After ${available}`,
      Delta: `Actual +${extra} / Expected ${amount}`,
    });
  },
);

async function assertWalletBalance(
  world,
  currencyPlaceholder,
  amountPlaceholder,
  operation,
) {
  const currency = world.resolve(currencyPlaceholder);
  const before = world.vars.beforeBalances?.[currency];
  const after = await getWalletBalance(world);

  const amount =
    operation === "unchanged"
      ? new Decimal(0)
      : new Decimal(world.resolve(amountPlaceholder));

  const expectedChange =
    operation === "increase"
      ? amount
      : operation === "decrease"
        ? amount.negated()
        : new Decimal(0);

  const expected = before.plus(expectedChange);
  const actualChange = after.minus(before);

  assert(
    after.equals(expected),
    [
      `Wallet balance assertion failed`,
      `  Context         : ${operation} | ${currency}`,
      `  Balance     : Before ${before} → After ${after}`,
      `  Delta           : Actual ${actualChange} / Expected ${expectedChange}`,
      `  ExpectedBalance : ${expected}`,
    ].join("\n"),
  );

  await world.attachInfo("Wallet balance check", {
    Context: `${operation} | ${currency}`,
    Balance: `Before ${before} → After ${after}`,
    Delta: `Actual ${actualChange} / Expected ${expectedChange}`,
    Expected: expected.toString(),
  });
}

Then(
  /^the balance in "([^"]+)" wallet should (increase|decrease) by "?([^"]+)"?$/,
  async function (currencyPlaceholder, operation, amountPlaceholder) {
    await assertWalletBalance(
      this,
      currencyPlaceholder,
      amountPlaceholder,
      operation,
    );
  },
);

Then(
  "the balance in {string} wallet should remain unchanged",
  async function (currencyPlaceholder) {
    await assertWalletBalance(this, currencyPlaceholder, 0, "unchanged");
  },
);

Then("I save the transferred integer amount as {string}", function (varName) {
  const currency = this.vars.currency;
  const beforeBalance = this.vars.beforeBalances?.[currency];

  if (!beforeBalance) {
    throw this.error("Current balance was not recorded", { currency });
  }

  const transferredAmount = new Decimal(beforeBalance).floor().toString();

  this.vars[varName] = transferredAmount;

  this.attachInfo("Stored", {
    [varName]: transferredAmount,
  });
});

Then(
  "the balance in {string} wallet should equal the remaining decimal balance",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);

    const before = this.vars.beforeBalances?.[currency];
    const after = await getWalletBalance(this);

    if (!before) {
      throw this.error("No recorded balance found for comparison", {
        currency,
      });
    }

    const expected = new Decimal(before).minus(new Decimal(before).floor());

    if (!after.equals(expected)) {
      throw this.error(
        [
          `Remaining decimal assertion failed`,
          `  Context     : ${currency}`,
          `  Balance : Before ${before} → After ${after}`,
          `  Delta       : Actual ${after.minus(before)} / Expected ${expected}`,
        ].join("\n"),
      );
    }

    await this.attachInfo("Remaining decimal check", {
      Context: currency,
      Balance: `Before ${before} → After ${after}`,
      Delta: `Actual ${after.minus(before)} / Expected ${expected}`,
    });
  },
);
// amo001 - verify balances in response
Then("the response should contain balances for {string}", function (input) {
  const data = this.responseData(this.lastResponse);
  const balances = data?.balances;

  if (!balances || typeof balances !== "object") {
    throw this.error("No balances object in response");
  }

  const resolved = this.resolve(input);
  const currencies = Array.isArray(resolved) ? resolved : [resolved];

  const missing = currencies.filter((c) => !(c in balances));

  if (missing.length) {
    throw this.error("Missing balances", {
      Context: Object.keys(balances).join(", "),
      Missing: missing.join(", "),
    });
  }

  this.attachInfo("Balances check", {
    Context: Object.keys(balances).join(", "),
    Result: "All present",
  });
});
