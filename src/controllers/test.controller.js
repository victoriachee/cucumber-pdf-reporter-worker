const queue = require("../queues/test.queue");
const { v4: uuid } = require("uuid");
const config = require("../config/client.config");

exports.runTests = async (req, res) => {
  const {
    format = "html",
    platform_username = "supermerchant1user",
    currency = "CNY",
  } = req.body;

  if (!platform_username) {
    return res.status(400).json({
      message: "platform_username is required",
    });
  }

  const domain = config.baseURL;
  const mockApiDomain = config.mockApiDomain;

  const merchantSettings = {
    request_payment_api: `${domain}/api/v1/transfer-wallet/request-payment`,
    notify_payment_failed_api: `${domain}/api/v1/transfer-wallet/notify-payment-failed`,
    settle_order_api: `${domain}/api/v1/transfer-wallet/settle-wager`,
    cancel_order_api: `${domain}/api/v1/transfer-wallet/cancel-wager`,
    resettle_wager_api: `${domain}/api/v1/transfer-wallet/resettle-wager`,
    undo_wager_api: `${domain}/api/v1/transfer-wallet/undo-wager`,
    get_payment_api: `${domain}/api/v1/transfer-wallet/balance`,
    withdraw_payment_api: `${domain}/api/v1/transfer-wallet/request-transfer-out`,
    deposit_payment_api: `${domain}/api/v1/transfer-wallet/request-transfer-in`,
    cancel_transfer_api: `${domain}/api/v1/transfer-wallet/cancel-transfer`,
    notify_wager_api: `${mockApiDomain}/wager/notify`,
  };

  const world = {
    user: {
      platform_username,
    },
    merchant_settings: merchantSettings,
    defaults: { currency },
  };

  const job = await queue.add(
    "run-tests",
    {
      runId: uuid(),
      format,
      world,
    },
    {
      removeOnComplete: 20,
      removeOnFail: 50,
    },
  );

  return res.json({
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
