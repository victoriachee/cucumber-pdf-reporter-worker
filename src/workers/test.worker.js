const { Worker } = require("bullmq");
const connection = require("../config/redis");

const cucumberService = require("../services/cucumber.service");
const reportService = require("../services/report.service");
const logger = require("../utils/logger");

const worker = new Worker(
  "test",

  async (job) => {
    try {
      logger.info("JOB_STARTED", { jobId: job.id, format: job.data.format });
      await job.updateProgress(5);

      logger.info("CUCUMBER_START", { jobId: job.id });
      const cucumberResult = await cucumberService.run(job.data);
      await job.updateProgress(50);
      logger.info("CUCUMBER_COMPLETED", {
        jobId: job.id,
        result: cucumberResult,
      });

      logger.info("REPORT_GENERATION_START", { jobId: job.id });
      const reportFile = await reportService.generate(
        job.data.format,
        cucumberResult,
      );
      await job.updateProgress(100);

      logger.info("JOB_COMPLETED", { jobId: job.id, reportFile });
      return { reportFile };
    } catch (err) {
      logger.error("JOB_FAILED", {
        jobId: job.id,
        error: err.message,
        stack: err.stack,
      });
      throw err; // ensures BullMQ marks job as failed
    }
  },

  { connection },
);

// Event listeners
worker.on("failed", (job, err) => {
  logger.error("WORKER_JOB_FAILED", { jobId: job?.id, error: err.message });
});

worker.on("completed", (job, returnvalue) => {
  logger.info("WORKER_JOB_SUCCESS", {
    jobId: job.id,
    reportFile: returnvalue?.reportFile,
  });
});

worker.on("progress", (job, progress) => {
  logger.info("WORKER_JOB_PROGRESS", { jobId: job.id, progress });
});

module.exports = worker;
