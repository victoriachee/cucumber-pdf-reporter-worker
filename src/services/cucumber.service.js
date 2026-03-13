const { spawn } = require("child_process");
const path = require("path");
const fs = require("fs");
const { logger } = require("../utils/logger");
const { jsonDir } = require("../config/report.config");

exports.run = async (timestamp) => {
  const runDir = path.join(jsonDir, String(timestamp));
  fs.mkdirSync(runDir, { recursive: true });

  const jsonFile = path.join(runDir, "report.json");

  const args = [
    "cucumber-js",
    "src/features/**/*.feature",
    "--require",
    "src/features/step-definitions/**/*.js",
    "--format",
    "progress",
    "--format",
    `json:${jsonFile}`,
  ];

  return new Promise((resolve, reject) => {
    const proc = spawn("npx", args, { stdio: "pipe" });

    logger.info("CUCUMBER_CMD", { command: "npx", args });

    proc.stdout.on("data", (d) => logger.info(d.toString()));
    proc.stderr.on("data", (d) => logger.error(d.toString()));

    proc.on("close", (code) => {
      if (code !== 0) {
        logger.warn("CUCUMBER_EXIT_NON_ZERO", { code });
      }
      resolve(jsonFile);
    });

    proc.on("error", reject);
  });
};
