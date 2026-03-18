const { setWorldConstructor } = require("@cucumber/cucumber");
const apiService = require("../../services/api.service");
const WorldError = require("./world.error");
const createWalletContext = require("./context/wallet.context");
const {
  DEFAULT_CURRENCY,
  decodeCtx,
  normalizeResponse,
  normalizeError,
  normalizePayload,
  createUUIDVars,
  indent,
} = require("./utils");

class World {
  constructor({ attach }) {
    const ctx = decodeCtx();

    this.attach = attach;
    this.lastRequest = null;
    this.lastResponse = null;

    this.config = {
      merchant_settings: ctx.world?.merchant_settings ?? {},
    };

    this.vars = {
      platform_username: ctx.world?.user?.platform_username,
      currency: ctx.world?.defaults?.currency ?? DEFAULT_CURRENCY,
      ...createUUIDVars("transaction_uuid_"),
      ...createUUIDVars("transfer_no_"),
    };
    /** @type {ReturnType<typeof createWalletContext>} */
    this.wallet = createWalletContext(this);
  }

  isApiSuccess(response = this.lastResponse) {
    const status = response?.status ?? response?.code;
    return typeof status === "number" && status < 400;
  }

  responseData(response = this.lastResponse) {
    return response?.body?.data ?? response;
  }

  tablePayload(table) {
    return Object.fromEntries(
      table
        .raw()
        .slice(1) // skip header row: ["field", "value"]
        .map(([key, value]) => [key, this.resolve(value)]),
    );
  }

  error(message, context = {}) {
    return new WorldError(message, {
      request: this.lastRequest,
      response: this.lastResponse,
      ...context,
    });
  }

  async attachInfo(...parts) {
    const lines = [];

    for (const part of parts) {
      if (part == null) continue;

      if (typeof part === "string") {
        lines.push(indent(part, 1));
        continue;
      }

      for (const [key, value] of Object.entries(part)) {
        if (value == null) continue;

        lines.push(indent(`${key}:`, 1));
        lines.push(indent(value, 2));
      }
    }

    await this.attach(lines.join("\n"), "text/plain");
  }

  resolve(value) {
    if (typeof value === "string") {
      return value.replace(
        /<([^>]+)>/g,
        (_, key) => this.vars[key] ?? `<${key}>`,
      );
    }

    if (Array.isArray(value)) {
      return value.map((item) => this.resolve(item));
    }

    if (value && typeof value === "object") {
      return Object.fromEntries(
        Object.entries(value).map(([key, item]) => [key, this.resolve(item)]),
      );
    }

    return value;
  }

  async request(method, url, payload = {}) {
    if (!url) {
      throw this.error("API not set in merchant settings");
    }

    const requestBody = normalizePayload(this.resolve(payload));
    this.lastRequest = requestBody;

    try {
      const response = await apiService.call(method, url, requestBody);
      this.lastResponse = normalizeResponse(response);
    } catch (error) {
      this.lastResponse = normalizeError(error);
    }

    await this.attachInfo({
      API: `${method} ${url}`,
      Request: this.lastRequest,
      Response: this.lastResponse,
    });

    return this.lastResponse;
  }
}

setWorldConstructor(World);

module.exports = World;
