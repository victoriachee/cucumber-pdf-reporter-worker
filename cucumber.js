module.exports = {
  default: {
    paths: ["src/features/**/*.feature"],
    require: ["src/features/step-definitions/**/*.js"],
    format: [
      "progress",
      "json:reports/cucumber-report.json", // raw JSON for HTML conversion
      "html:reports/cucumber-report.html", // optional
    ],
  },
};
