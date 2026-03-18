const { Queue } = require("bullmq");
const connection = require("../config/redis.config");

const testQueue = new Queue("api-test-runner", { connection });

module.exports = testQueue;
