module.exports = {
  default: [
    "--order defined",
    "src/features/**/*.feature",
    "--require src/features/steps/**/*.js",
    "--format progress",
  ].join(" "),
};
