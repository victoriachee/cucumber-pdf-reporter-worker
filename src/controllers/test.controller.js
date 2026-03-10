const testQueue = require("../queues/test.queue");
const { v4: uuid } = require("uuid");

exports.runTests = async (req, res) => {
  const { format } = req.body;

  const job = await testQueue.add("run-api-tests", {
    id: uuid(),
    format: format || "html",
  });

  res.json({
    jobId: job.id,
    status: "queued",
  });
};
