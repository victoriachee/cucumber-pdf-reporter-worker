const { QueueEvents } = require("bullmq");
const redis = require("../config/redis.config");
const { logger } = require("../utils/logger");

const queueEvents = new QueueEvents("api-test-runner", { connection: redis });

queueEvents.on("progress", ({ jobId, data }) => {
  logger.info("JOB_PROGRESS", { jobId, progress: data });
});

queueEvents.on("completed", ({ jobId, returnvalue }) => {
  logger.info("JOB_COMPLETED", { jobId, report: returnvalue });
});

queueEvents.on("failed", ({ jobId, failedReason }) => {
  logger.error("JOB_FAILED", { jobId, reason: failedReason });
});

module.exports = queueEvents;
