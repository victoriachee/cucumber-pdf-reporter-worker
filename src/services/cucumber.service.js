const { spawn } = require("child_process");
const path = require("path");
const fs = require("fs");
const { logger } = require("../utils/logger");
const { jsonDir } = require("../config/report.config");

exports.run = async (timestamp, ctx = {}) => {
  const runDir = path.join(jsonDir, String(timestamp));
  fs.mkdirSync(runDir, { recursive: true });

  const features = ctx.featurePaths?.length
    ? ctx.featurePaths
    : ["src/features/**/*.feature"];

  const worldParams = JSON.stringify(ctx.worldParams ?? {});

  const jsonFile = path.join(runDir, "report.json");

  const args = [
    "cucumber-js",
    ...features,
    "--require",
    "src/features/steps/**/*.js",
    "--require",
    "src/features/support/**/*.js",
    "--format",
    "progress",
    "--format",
    `json:${jsonFile}`,
    "--world-parameters",
    worldParams,
  ];

  return new Promise((resolve, reject) => {
    const proc = spawn("npx", args, {
      stdio: "pipe",
      env: process.env,
    });

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
