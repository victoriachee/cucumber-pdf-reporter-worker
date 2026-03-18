const crypto = require("crypto");

/**
 * AES-CBC encryption
 */
function aesEncrypt(secret, data) {
  const cleanSecret = secret.replace(/-/g, "");

  const key = Buffer.from(cleanSecret, "utf8");

  // 16 byte IV
  const iv = crypto.randomBytes(16);

  const cipher = crypto.createCipheriv("aes-256-cbc", key, iv);

  let encrypted = cipher.update(data, "utf8", "hex");
  encrypted += cipher.final("hex");

  return {
    iv: iv.toString("hex"),
    payload: encrypted,
  };
}

function generateHash(payload) {
  return crypto.createHash("md5").update(payload).digest("hex");
}

function constructSignaturePayload(
  method,
  encryptedData,
  headers,
  clientSecret,
) {
  const clientId = headers["x-client-id"];
  const timestamp = headers["x-timestamp"];

  let payload;

  if (method === "GET") {
    payload = `iv=${encryptedData.iv}&payload=${encryptedData.payload}`;
  } else {
    payload = JSON.stringify(encryptedData);
  }

  const headerPayload = `X-CLIENT-ID=${clientId}&X-TIMESTAMP=${timestamp}`;

  const combinedPayload = `${payload}&${headerPayload}&${clientSecret.replace(
    /-/g,
    "",
  )}`;

  return combinedPayload;
}

/**
 * Main generator used by api.service
 */
exports.generateEncryptedApiRequestDetails = function (client, method, body) {
  const timestamp = Math.floor(Date.now() / 1000).toString();

  const headers = {
    "x-client-id": client.client_id,
    "x-timestamp": timestamp,
  };

  const encryptedData = aesEncrypt(client.client_secret, JSON.stringify(body));

  const signaturePayload = constructSignaturePayload(
    method,
    encryptedData,
    headers,
    client.client_secret,
  );

  const signature = generateHash(signaturePayload);

  headers["x-sign"] = signature;

  return {
    headers,
    encryptedBody: encryptedData,
  };
};
