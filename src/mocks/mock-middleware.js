const crypto = require("crypto");
const Joi = require("joi");
const { logger } = require("../utils/logger");

/*
------------------------------------------------
CONFIG
------------------------------------------------
*/

const CLIENTS = {
  "demo-client": "demo-secret",
};

/*
------------------------------------------------
HELPERS
------------------------------------------------
*/

function constructSign(secret, method, payload, headers) {
  const timestamp = headers["x-timestamp"];

  const data =
    method === "GET"
      ? JSON.stringify(payload || {})
      : JSON.stringify(payload || {});

  const raw = `${method}|${timestamp}|${data}`;

  return crypto.createHmac("sha256", secret).update(raw).digest("hex");
}

function decryptPayload(secret, payload, iv) {
  const decipher = crypto.createDecipheriv(
    "aes-256-cbc",
    crypto.createHash("sha256").update(secret).digest(),
    Buffer.from(iv, "hex"),
  );

  let decrypted = decipher.update(payload, "hex", "utf8");
  decrypted += decipher.final("utf8");

  return JSON.parse(decrypted);
}

/*
------------------------------------------------
HEADER VALIDATION
------------------------------------------------
*/

const validateHeaders =
  (options = {}) =>
  async (req, res, next) => {
    try {
      const { validateSign = true, validateTimestamp = true } = options;

      const clientId = req.headers["x-client-id"];
      const timestamp = req.headers["x-timestamp"];
      const providedSign = req.headers["x-sign"];

      const data = req.method === "GET" ? req.query : req.body;

      const errors = [];

      if (!clientId) {
        errors.push({ message: "Missing header", key: "X-CLIENT-ID" });
      }

      const clientSecret = CLIENTS[clientId];

      if (!clientSecret) {
        errors.push({
          message: "Client not found",
          key: "client_id",
        });
      }

      if (validateTimestamp && !timestamp) {
        errors.push({ message: "Missing header", key: "X-TIMESTAMP" });
      }

      if (validateSign && !providedSign) {
        errors.push({ message: "Missing header", key: "X-SIGN" });
      }

      if (validateSign && clientSecret && providedSign) {
        const generatedSign = constructSign(
          clientSecret,
          req.method,
          data,
          req.headers,
        );

        if (generatedSign !== providedSign) {
          errors.push({ message: "Invalid sign", key: "X-SIGN" });
        }
      }

      if (errors.length) {
        return res.json({
          error: errors,
          code: 400,
          message: "Validation Error",
        });
      }

      req.client_secret = clientSecret;

      next();
    } catch (err) {
      logger.error("HEADER_VALIDATION_ERROR", { error: err.message });

      return res.status(500).json({
        code: 500,
        message: err.message,
      });
    }
  };

/*
------------------------------------------------
PAYLOAD DECRYPTION
------------------------------------------------
*/

const decryptPayloadMiddleware = async (req, res, next) => {
  try {
    const { payload, iv } = req.method === "GET" ? req.query : req.body;

    if (!payload || !iv) {
      return res.json({
        code: 400,
        message: "Payload and iv required",
      });
    }

    const decrypted = decryptPayload(req.client_secret, payload, iv);

    req.payload = decrypted;

    logger.debug("PAYLOAD_DECRYPTED", { payload: decrypted });

    next();
  } catch (err) {
    logger.error("DECRYPT_FAILED", { error: err.message });

    return res.status(400).json({
      code: 400,
      message: "Invalid encrypted payload",
    });
  }
};

/*
------------------------------------------------
SCHEMAS
------------------------------------------------
*/

const walletSchema = Joi.object({
  platform_username: Joi.string().required(),
  currencies: Joi.array().items(Joi.string()).required(),
  game_key: Joi.string().allow(null),
});

const requestPaymentSchema = Joi.object({
  platform_username: Joi.string().required(),
  amount: Joi.number().required(),
});

const settleSchema = Joi.object({
  platform_username: Joi.string().required(),
  wagers: Joi.array().required(),
});

/*
------------------------------------------------
VALIDATION MIDDLEWARE
------------------------------------------------
*/

function validateSchema(schema) {
  return (req, res, next) => {
    const { error } = schema.validate(req.payload);

    if (error) {
      return res.json({
        code: 400,
        message: "Validation Error",
        error: error.details.map((d) => ({
          message: d.message,
          key: d.path.join("."),
        })),
      });
    }

    next();
  };
}

/*
------------------------------------------------
EXPORTS
------------------------------------------------
*/

module.exports = {
  validateHeaders,
  decryptPayload: decryptPayloadMiddleware,

  validateOpenapiGetUserWalletBalanceReqPayload: validateSchema(walletSchema),

  validateOpenapiRequestPaymentReqPayload: validateSchema(requestPaymentSchema),

  validateOpenapiBulkSettleWagersReqPayload: validateSchema(settleSchema),

  validateOpenapiBulkCancelWagersReqPayload: validateSchema(Joi.object({})),

  validateOpenapiBulkResettleWagersReqPayload: validateSchema(Joi.object({})),

  validateOpenapiBulkUndoWagersReqPayload: validateSchema(Joi.object({})),

  validateOpenapiTransferInReqPayload: validateSchema(Joi.object({})),

  validateOpenapiTransferOutReqPayload: validateSchema(Joi.object({})),

  validateOpenapiCancelTransferOutReqPayload: validateSchema(Joi.object({})),

  validateOpenapiNotifyPaymentFailedReqPayload: validateSchema(Joi.object({})),

  validateOpenapiNotifyWagersReqPayload: validateSchema(Joi.object({})),
};
