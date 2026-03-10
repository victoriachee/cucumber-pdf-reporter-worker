const axios = require("axios");
const config = require("../config/client.config");
const { generateEncryptedApiRequestDetails } = require("./encryption.service");

exports.call = async (method, path, body = {}) => {
  const { headers, encryptedBody } = generateEncryptedApiRequestDetails(
    config.client,
    method,
    body,
    path,
  );

  const res = await axios({
    method,
    url: `${config.baseURL}${path}`,
    headers,
    data: encryptedBody,
  });

  return res.data;
};
