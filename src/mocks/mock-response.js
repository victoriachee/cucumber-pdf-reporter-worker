const { logger } = require("../utils/logger");

/*
------------------------------------------------
STANDARD SUCCESS RESPONSE
------------------------------------------------
*/

function respondSuccess(res, data = {}) {
  const response = {
    code: 200,
    message: "success",
    data,
  };

  logger.info("MOCK_RESPONSE_SUCCESS", { response });

  return res.json(response);
}

/*
------------------------------------------------
STANDARD ERROR RESPONSE
------------------------------------------------
*/

function respondError(res, message = "error", code = 400) {
  const response = {
    code,
    message,
  };

  logger.warn("MOCK_RESPONSE_ERROR", { response });

  return res.status(code).json(response);
}

/*
------------------------------------------------
CASE RESPONSE GENERATOR
Used for /:case endpoints
------------------------------------------------
*/

function seamlessCaseResponseGenerator(caseType, res, data = {}) {
  logger.debug("MOCK_CASE_EXECUTION", { caseType });

  switch (caseType) {
    case "error":
      return respondError(res, "Mock forced error", 500);

    case "timeout":
      return setTimeout(() => {
        respondSuccess(res, data);
      }, 10000);

    case "validation":
      return res.status(400).json({
        code: 400,
        message: "Validation Error",
        error: [
          {
            key: "amount",
            message: "Invalid amount",
          },
        ],
      });

    case "empty":
      return respondSuccess(res, {});

    default:
      return respondSuccess(res, data);
  }
}

module.exports = {
  respondSuccess,
  respondError,
  seamlessCaseResponseGenerator,
};
