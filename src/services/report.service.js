const reporter = require("multiple-cucumber-html-reporter");
const puppeteer = require("puppeteer");
const path = require("path");
const fs = require("fs");

const MAX_REPORTS = 10;

function cleanupReports(baseDir) {
  if (!fs.existsSync(baseDir)) return;

  const folders = fs
    .readdirSync(baseDir)
    .map((name) => ({
      name,
      path: path.join(baseDir, name),
      time: fs.statSync(path.join(baseDir, name)).mtime.getTime(),
    }))
    .filter((f) => fs.statSync(f.path).isDirectory())
    .sort((a, b) => a.time - b.time);

  while (folders.length >= MAX_REPORTS) {
    const oldest = folders.shift();
    fs.rmSync(oldest.path, { recursive: true, force: true });
  }
}

exports.generate = async (format) => {
  const baseDir = path.join(process.cwd(), "reports");

  if (!fs.existsSync(baseDir)) fs.mkdirSync(baseDir);

  cleanupReports(baseDir);

  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");

  const reportDir = path.join(baseDir, timestamp);

  fs.mkdirSync(reportDir);

  reporter.generate({
    jsonDir: baseDir,
    reportPath: reportDir,
  });

  if (format === "pdf") {
    const browser = await puppeteer.launch();

    const page = await browser.newPage();

    const file = `file://${reportDir}/index.html`;

    await page.goto(file, { waitUntil: "networkidle0" });

    await page.pdf({
      path: path.join(reportDir, "report.pdf"),
      format: "A4",
    });

    await browser.close();
  }
};
