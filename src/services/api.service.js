const axios = require("axios");
const config = require("../config/client.config");
const { generateEncryptedApiRequestDetails } = require("./encryption.service");
const { logger } = require("../utils/logger");

exports.call = async (method, path, body = {}) => {
  const { headers, encryptedBody } = generateEncryptedApiRequestDetails(
    config.client,
    method,
    body,
    path,
  );

  const url = `${config.baseURL}${path}`;

  logger.debug("API_REQUEST", {
    method,
    url,
    headers,
    body,
  });

  try {
    const res = await axios({
      method,
      url,
      headers,
      data: encryptedBody,
      timeout: 10000,
    });

    logger.debug("API_RESPONSE", {
      method,
      url,
      status: res.status,
      data: res.data,
    });

    return res.data;
  } catch (err) {
    logger.error("API_ERROR", {
      method,
      url,
      message: err.message,
      status: err.response?.status,
      response: err.response?.data,
    });

    throw err;
  }
};
