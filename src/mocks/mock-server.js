const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const math = require("mathjs");

const mockMiddleware = require("./mock-middleware");
const {
  respondSuccess,
  respondError,
  seamlessCaseResponseGenerator,
} = require("./mock-response");
const { generateUUID } = require("../utils/uuid");
const { logger } = require("../utils/logger");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// --- Example currencies ---
const CURRENCIES = { CNY: true, USD: true, EUR: true };

// --- Helper to log requests ---
app.use((req, res, next) => {
  logger.info(`Incoming request ${req.method} ${req.path}`, {
    body: req.body,
    params: req.params,
  });
  next();
});

// --- Wallet balance ---
app.get(
  "/payment/wallet",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiGetUserWalletBalanceReqPayload,
  async (req, res) => {
    try {
      const { currencies, platform_username: platformUsername } = req.payload;
      const caseType = req.params.case;

      if (
        !(Array.isArray(currencies) && currencies.every((c) => CURRENCIES[c]))
      ) {
        return respondError(
          res,
          `Invalid currencies, only accept ${Object.keys(CURRENCIES).join(", ")}.`,
          400,
        );
      }
      if (!platformUsername || platformUsername !== "demo_user") {
        return respondError(res, "User not found", 404);
      }

      const balances = {};
      currencies.forEach((currency) => {
        let integerDigits;
        switch (caseType) {
          case "large":
            integerDigits = Math.floor(Math.random() * 1e7);
            break;
          case "small":
            integerDigits = Math.floor(Math.random() * 1e4);
            break;
          case "mini":
            integerDigits = Math.floor(Math.random() * 1e2);
            break;
          default:
            integerDigits = Math.floor(Math.random() * 1e5);
        }
        const fractionalDigits = Math.floor(Math.random() * 1e4);
        balances[currency] = math.evaluate(
          `${integerDigits}.${fractionalDigits}`,
        );
      });

      return respondSuccess(res, {
        platform_username: platformUsername,
        balances,
      });
    } catch (err) {
      logger.error("Wallet balance endpoint failed", {
        error: err.message,
      });
      return res.status(500).json({ code: 500, message: err.message });
    }
  },
);

// --- Request Payment ---
app.post(
  "/payment/request",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiRequestPaymentReqPayload,
  (req, res) => {
    const caseType = req.params.case;
    return seamlessCaseResponseGenerator(caseType, res, {
      reference_id: generateUUID(),
      status: 1,
    });
  },
);

// --- Notify Payment Failed ---
app.post(
  "/payment/notifyFailed",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiNotifyPaymentFailedReqPayload,
  (req, res) =>
    seamlessCaseResponseGenerator(req.params.case, res, {
      reference_id: generateUUID(),
    }),
);

// --- Settle Wager ---
app.post(
  "/order/settle",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiBulkSettleWagersReqPayload,
  (req, res) =>
    seamlessCaseResponseGenerator(req.params.case, res, {
      reference_id: generateUUID(),
    }),
);

// --- Cancel Wager ---
app.post(
  "/wager/cancel",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiBulkCancelWagersReqPayload,
  (req, res) =>
    seamlessCaseResponseGenerator(req.params.case, res, {
      reference_id: generateUUID(),
    }),
);

// --- Resettle Wager ---
app.post(
  "/order/resettle",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiBulkResettleWagersReqPayload,
  (req, res) =>
    seamlessCaseResponseGenerator(req.params.case, res, {
      reference_id: generateUUID(),
    }),
);

// --- Deposit (Transfer In) ---
app.post(
  "/payment/deposit",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiTransferInReqPayload,
  (req, res) =>
    seamlessCaseResponseGenerator(req.params.case, res, {
      reference_id: generateUUID(),
      status: 1,
    }),
);

// --- Withdraw (Transfer Out) ---
app.post(
  "/payment/withdraw",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiTransferOutReqPayload,
  (req, res) =>
    seamlessCaseResponseGenerator(req.params.case, res, {
      reference_id: generateUUID(),
      amount: req.body.amount || 100,
      status: 1,
    }),
);

// --- Undo Wager ---
app.post(
  "/wager/undo",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiBulkUndoWagersReqPayload,
  (req, res) =>
    seamlessCaseResponseGenerator(req.params.case, res, {
      reference_id: generateUUID(),
    }),
);

// --- Notify Wager Update ---
app.post(
  "/wager/notify",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiNotifyWagersReqPayload,
  (req, res) => seamlessCaseResponseGenerator(req.params.case, res),
);

// --- Cancel Transfer ---
app.post(
  "/transfer/cancel",
  mockMiddleware.validateHeaders(),
  mockMiddleware.decryptPayload,
  mockMiddleware.validateOpenapiCancelTransferOutReqPayload,
  (req, res) =>
    seamlessCaseResponseGenerator(req.params.case, res, {
      reference_id: generateUUID(),
    }),
);

app.get("/health", (req, res) => {
  res.status(200).send("ok");
});

// --- Start server ---
const PORT = 8082;
app.listen(PORT, () => {
  logger.info("Mock server running", { port: PORT });
});

module.exports = app;
