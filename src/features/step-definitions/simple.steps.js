const { Given, When, Then } = require("@cucumber/cucumber");
const assert = require("assert");

let result;
let items = [];
let user = { loggedIn: false };

// ----------------------------
// Scenario 1: Basic addition
// ----------------------------
Given("the system is ready", function () {
  result = 0;
});

When("I add {int} and {int}", function (a, b) {
  result = a + b;
});

Then("the result should be {int}", function (expected) {
  assert.strictEqual(result, expected);
});

// ----------------------------
// Scenario 2: Working with a list
// ----------------------------
Given("an empty list", function () {
  items = [];
});

When("I push {int} into the list", function (value) {
  items.push(value);
});

Then("the list length should be {int}", function (expectedLength) {
  assert.strictEqual(items.length, expectedLength);
});

Then("the list should contain {int}", function (expectedValue) {
  assert.ok(items.includes(expectedValue));
});

// ----------------------------
// Scenario 3: User login simulation
// ----------------------------
Given("a user who is not logged in", function () {
  user.loggedIn = false;
});

When("the user attempts to login with password {string}", function (password) {
  // simulate login logic
  user.loggedIn = password === "secret";
});

Then("the user should be logged in", function () {
  assert.strictEqual(user.loggedIn, true);
});

Then("the user should not be logged in", function () {
  assert.strictEqual(user.loggedIn, false);
});

// ----------------------------
// Scenario 4: Simple string manipulation
// ----------------------------
let text;

Given("a string {string}", function (input) {
  text = input;
});

When("I append {string} to it", function (suffix) {
  text += suffix;
});

Then("the string should be {string}", function (expected) {
  assert.strictEqual(text, expected);
});
