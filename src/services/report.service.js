const path = require("path");
const fs = require("fs");
const puppeteer = require("puppeteer");
const reporter = require("cucumber-html-reporter");
const config = require("../config/report.config");

class ReportService {
  constructor() {
    this.baseDir = config.baseDir;
    this.runsDir = config.runsDir;
    this.jsonDir = config.jsonDir;
  }

  async generate(format = "html", timestamp) {
    const jsonFile = path.join(this.jsonDir, String(timestamp), "report.json");
    const reportDir = path.join(this.runsDir, String(timestamp));

    fs.mkdirSync(reportDir, { recursive: true });

    const htmlPath = path.join(reportDir, "index.html");

    reporter.generate({
      theme: "bootstrap",
      jsonFile,
      output: htmlPath,
      reportSuiteAsScenarios: true,
      launchReport: false,
      metadata: {
        "Test Environment": "API",
        Platform: process.platform,
        "Node Version": process.version,
      },
    });

    if (format === "pdf") {
      const pdfPath = await this.generatePdf(htmlPath, reportDir);
      return this.toPublicPath(pdfPath);
    }

    return this.toPublicPath(htmlPath);
  }

  toPublicPath(filePath) {
    const reportsRoot = path.join(process.cwd(), "reports");
    const relative = path.relative(reportsRoot, filePath);

    return `/reports/${relative.replace(/\\/g, "/")}`;
  }
  async generatePdf(htmlPath, reportDir) {
    const browser = await puppeteer.launch({
      args: ["--no-sandbox"],
    });

    const page = await browser.newPage();

    await page.goto(`file://${htmlPath}`, { waitUntil: "networkidle0" });

    /* expand all collapsed sections */
    await page.evaluate(() => {
      /* expand bootstrap collapse sections */
      document.querySelectorAll(".collapse").forEach((el) => {
        el.classList.add("show");
      });

      /* trigger click on collapsed feature/scenario headers */
      document.querySelectorAll('[data-toggle="collapse"]').forEach((btn) => {
        btn.click();
      });
    });

    /* allow UI to finish expanding */
    await new Promise((r) => setTimeout(r, 500));

    const pdfPath = path.join(reportDir, "report.pdf");

    await page.pdf({
      path: pdfPath,
      format: "A4",
      printBackground: true,
    });

    await browser.close();

    return pdfPath;
  }
}

module.exports = new ReportService();
