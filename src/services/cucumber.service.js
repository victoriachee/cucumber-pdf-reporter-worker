const { exec } = require("child_process");

exports.run = () => {
  return new Promise((resolve, reject) => {
    exec(
      "npx cucumber-js --format json:reports/report.json",
      (err, stdout, stderr) => {
        if (err) return reject(err);

        resolve(stdout);
      },
    );
  });
};
