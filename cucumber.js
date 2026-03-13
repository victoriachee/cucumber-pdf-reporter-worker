module.exports = {
  default: [
    "src/features/**/*.feature",
    "--require src/features/step-definitions/**/*.js",
    "--format progress",
  ].join(" "),
};
