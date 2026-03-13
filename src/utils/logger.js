const format = (level, message, meta = {}) =>
  JSON.stringify({
    level,
    time: new Date().toISOString(),
    message,
    ...meta,
  });

const logger = {
  info: (msg, meta) => console.log(format("INFO", msg, meta)),
  warn: (msg, meta) => console.warn(format("WARN", msg, meta)),
  error: (msg, meta) => console.error(format("ERROR", msg, meta)),
  debug: (msg, meta) => console.debug(format("DEBUG", msg, meta)),
};

module.exports = { logger };
