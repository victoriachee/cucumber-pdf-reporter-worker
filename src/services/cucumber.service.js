const { spawn } = require("child_process");
const path = require("path");
const fs = require("fs");
const { logger } = require("../utils/logger");
const { jsonDir } = require("../config/report.config");

fs.mkdirSync(jsonDir, { recursive: true });

/**
 * Runs Cucumber and returns the path to the JSON report
 */
exports.run = () =>
  new Promise((resolve, reject) => {
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const runDir = path.join(jsonDir, timestamp);
    fs.mkdirSync(runDir, { recursive: true });

    const jsonFile = path.join(runDir, "serenity-json.json");

    const args = [
      "cucumber-js",
      "--require-module",
      "@serenity-js/core",
      "--require",
      "src/features/step-definitions/**/*.js",
      "--format",
      `@serenity-js/cucumber:json:${jsonFile}`, // no extra quotes
      "src/features/**/*.feature",
    ];

    const cucumber = spawn("npx", args); // do not use { shell: true }

    logger.info("CUCUMBER_CMD", { command: "npx", args });

    cucumber.stdout.on("data", (data) => logger.info(data.toString()));
    cucumber.stderr.on("data", (data) => logger.error(data.toString()));

    cucumber.on("close", (code) => {
      if (code !== 0) {
        logger.warn("CUCUMBER_NON_ZERO_EXIT", { code });
      }
      resolve(jsonFile); // always resolve so report generation continues
    });

    cucumber.on("error", (err) => {
      logger.error("CUCUMBER_SPAWN_ERROR", err);
      reject(err);
    });
  });
