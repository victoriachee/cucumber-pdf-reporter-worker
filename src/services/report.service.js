const path = require("path");
const fs = require("fs");
const puppeteer = require("puppeteer");
const config = require("../config/report.config");

class SerenityReportService {
  constructor() {
    this.baseDir = config.baseDir;
    this.runsDir = config.runsDir;
    this.maxReports = config.maxReports;
  }

  ensureDir(dir) {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  }

  cleanupReports() {
    this.ensureDir(this.runsDir);

    const folders = fs
      .readdirSync(this.runsDir)
      .map((name) => ({
        name,
        path: path.join(this.runsDir, name),
        time: fs.statSync(path.join(this.runsDir, name)).mtime.getTime(),
      }))
      .filter((f) => fs.statSync(f.path).isDirectory())
      .sort((a, b) => a.time - b.time);

    while (folders.length >= this.maxReports) {
      const oldest = folders.shift();
      fs.rmSync(oldest.path, { recursive: true, force: true });
    }
  }

  async generatePdf(htmlPath, reportDir) {
    const browser = await puppeteer.launch({
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    });

    const page = await browser.newPage();
    await page.goto(`file://${htmlPath}`, { waitUntil: "networkidle0" });

    const pdfPath = path.join(reportDir, "report.pdf");
    await page.pdf({ path: pdfPath, format: "A4", printBackground: true });

    await browser.close();
    return this.toPublicPath(pdfPath);
  }

  toPublicPath(absPath) {
    return `/reports${absPath.replace(this.baseDir, "")}`.replace(/\\/g, "/");
  }

  async generateHtmlReport() {
    this.ensureDir(this.runsDir);
    this.cleanupReports();

    // Serenity output: the latest timestamped run folder
    const folders = fs
      .readdirSync(this.runsDir)
      .map((name) => path.join(this.runsDir, name))
      .filter((p) => fs.statSync(p).isDirectory())
      .sort(
        (a, b) =>
          fs.statSync(b).mtime.getTime() - fs.statSync(a).mtime.getTime(),
      );

    if (!folders.length) throw new Error("No Serenity/JS reports found.");

    const latestFolder = folders[0];
    const htmlPath = path.join(latestFolder, "index.html");

    if (!fs.existsSync(htmlPath)) {
      console.warn("Serenity/JS index.html not found in latest folder.");
    }

    return { htmlPath, reportDir: latestFolder };
  }

  async generate(format = "html") {
    const { htmlPath, reportDir } = await this.generateHtmlReport();

    if (format === "pdf") return await this.generatePdf(htmlPath, reportDir);
    return this.toPublicPath(htmlPath);
  }
}

module.exports = new SerenityReportService();
