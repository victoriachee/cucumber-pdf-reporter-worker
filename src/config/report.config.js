const path = require("path");

module.exports = {
  baseDir: path.join(process.cwd(), "reports"),
  runsDir: path.join(process.cwd(), "reports", "runs"),
  jsonDir: path.join(process.cwd(), "reports", "json"),
  maxReports: 10,
  serenityOutput: (timestamp) =>
    path.join(process.cwd(), "reports", "runs", timestamp),
  timestampFolder: () => new Date().toISOString().replace(/[:.]/g, "-"),
};
