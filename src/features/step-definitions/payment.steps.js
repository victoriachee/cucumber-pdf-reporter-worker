const { Given, When, Then } = require("@cucumber/cucumber");
const assert = require("assert");
const api = require("../../services/api.service");
const logger = require("../../utils/logger");

let ctx = {};

Given("a user exists", async function () {
  ctx.username = "demo_user";
  logger.debug("User context set", { username: ctx.username });
});

When("I call wallet balance", async function () {
  try {
    ctx.balance = await api.call("GET", "/payment/wallet", {
      platform_username: ctx.username,
      currencies: ["CNY"],
    });
    logger.debug("Wallet balance response", { response: ctx.balance });
  } catch (err) {
    ctx.error = err.response?.data || err.message;
    logger.error("Wallet balance call failed", { error: ctx.error });
    throw new Error(`Wallet balance call failed: ${JSON.stringify(ctx.error)}`);
  }
});

Then("response should be success", function () {
  if (ctx.error) {
    logger.error("Previous API call failed", { error: ctx.error });
    throw new Error(`Previous API call failed: ${JSON.stringify(ctx.error)}`);
  }
  assert.equal(ctx.balance.code, 200, "Expected code 200");
  logger.debug("Wallet balance validated successfully");
});

When("I request payment", async function () {
  try {
    ctx.payment = await api.call("POST", "/payment/request", {
      platform_username: ctx.username,
      amount: 100,
    });
    logger.debug("Payment request response", { response: ctx.payment });
  } catch (err) {
    ctx.error = err.response?.data || err.message;
    logger.error("Request payment failed", { error: ctx.error });
    throw new Error(`Request payment failed: ${JSON.stringify(ctx.error)}`);
  }
});

Then("payment status should be success", function () {
  if (ctx.error) {
    logger.error("Payment failed", { error: ctx.error });
    throw new Error(`Payment failed: ${JSON.stringify(ctx.error)}`);
  }
  assert.equal(ctx.payment.data.status, 1, "Expected payment status 1");
  logger.debug("Payment validated successfully");
});

When("I settle wager", async function () {
  try {
    ctx.settle = await api.call("POST", "/order/settle", {
      platform_username: ctx.username,
      wagers: [], // fill with mock wager data if needed
    });
    logger.debug("Settle wager response", { response: ctx.settle });
  } catch (err) {
    ctx.error = err.response?.data || err.message;
    logger.error("Settle wager failed", { error: ctx.error });
    throw new Error(`Settle wager failed: ${JSON.stringify(ctx.error)}`);
  }
});

Then("settlement should succeed", function () {
  if (ctx.error) {
    logger.error("Settlement failed", { error: ctx.error });
    throw new Error(`Settlement failed: ${JSON.stringify(ctx.error)}`);
  }
  assert.equal(ctx.settle.code, 200, "Expected code 200 for settlement");
  logger.debug("Settlement validated successfully");
});
