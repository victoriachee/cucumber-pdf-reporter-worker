const crypto = require("crypto");

function desEncrypt(secret, text) {
  const key = Buffer.from(secret.substring(0, 8));
  const iv = crypto.randomBytes(8);

  const cipher = crypto.createCipheriv("des-cbc", key, iv);

  let encrypted = cipher.update(text, "utf8", "base64");
  encrypted += cipher.final("base64");

  return {
    encryptedData: encrypted,
    iv: iv.toString("base64"),
  };
}

function generateSignature(payload) {
  return crypto.createHash("sha256").update(payload).digest("hex");
}

function constructSignaturePayload(method, body, headers, secret) {
  return [
    method,
    JSON.stringify(body),
    headers["x-client-id"],
    headers["x-timestamp"],
    secret,
  ].join("|");
}

function stringifyDecimalJSONByKeys(body) {
  return JSON.stringify(body);
}

function generateEncryptedApiRequestDetails(client, method, body, apiEndpoint) {
  const timestamp = Date.now();

  const clientSecret = client.client_secret;
  const clientId = client.client_id;

  const bodyString =
    typeof body === "object" ? stringifyDecimalJSONByKeys(body) : body;

  const { encryptedData, iv } = desEncrypt(clientSecret, bodyString);

  const encryptedBody = {
    iv,
    payload: encryptedData,
  };

  const signPayload = constructSignaturePayload(
    method,
    encryptedBody,
    {
      "x-client-id": clientId,
      "x-timestamp": timestamp,
    },
    clientSecret,
  );

  const sign = generateSignature(signPayload);

  return {
    headers: {
      "X-CLIENT-ID": clientId,
      "X-TIMESTAMP": timestamp,
      "X-SIGN": sign,
    },
    encryptedBody,
  };
}

module.exports = {
  generateEncryptedApiRequestDetails,
};
