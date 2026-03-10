const format = (level, message, meta = {}) => {
  return JSON.stringify({
    level,
    time: new Date().toISOString(),
    message,
    ...meta,
  });
};

exports.info = (msg, meta) => console.log(format("INFO", msg, meta));
exports.error = (msg, meta) => console.error(format("ERROR", msg, meta));
exports.warn = (msg, meta) => console.warn(format("WARN", msg, meta));
exports.debug = (msg, meta) => console.debug(format("DEBUG", msg, meta));
