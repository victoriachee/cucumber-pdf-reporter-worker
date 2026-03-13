const queue = require("../queues/test.queue");
const { v4: uuid } = require("uuid");

exports.runTests = async (req, res) => {
  const { format = "html" } = req.body;

  const job = await queue.add(
    "run-tests",
    {
      runId: uuid(),
      format,
    },
    {
      removeOnComplete: 20,
      removeOnFail: 50,
    },
  );

  res.json({
    jobId: job.id,
    status: "queued",
  });
};

exports.getStatus = async (req, res) => {
  const job = await queue.getJob(req.params.id);

  if (!job) {
    return res.status(404).json({ error: "job not found" });
  }

  const state = await job.getState();

  res.json({
    id: job.id,
    state,
    progress: job.progress || 0,
    result: job.returnvalue || null,
  });
};

exports.cancel = async (req, res) => {
  const job = await queue.getJob(req.params.id);

  if (!job) return res.status(404).json({ error: "job not found" });

  await job.remove();

  res.json({ status: "cancelled" });
};
