const { Queue } = require("bullmq");
const redis = require("../config/redis");

const testQueue = new Queue("test", { connection: redis });

module.exports = testQueue;
