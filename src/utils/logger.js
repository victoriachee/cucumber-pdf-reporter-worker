const colors = {
  reset: "\x1b[0m",
  gray: "\x1b[90m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  red: "\x1b[31m",
  cyan: "\x1b[36m",
};

const format = (level, message, meta = {}) =>
  JSON.stringify({
    level,
    time: new Date().toISOString(),
    message,
    ...meta,
  });

function colorize(level, text) {
  switch (level) {
    case "INFO":
      return `${colors.green}${text}${colors.reset}`;
    case "WARN":
      return `${colors.yellow}${text}${colors.reset}`;
    case "ERROR":
      return `${colors.red}${text}${colors.reset}`;
    case "DEBUG":
      return `${colors.cyan}${text}${colors.reset}`;
    default:
      return text;
  }
}

const logger = {
  info: (msg, meta) => console.log(colorize("INFO", format("INFO", msg, meta))),

  warn: (msg, meta) =>
    console.warn(colorize("WARN", format("WARN", msg, meta))),

  error: (msg, meta) =>
    console.error(colorize("ERROR", format("ERROR", msg, meta))),

  debug: (msg, meta) =>
    console.debug(colorize("DEBUG", format("DEBUG", msg, meta))),
};

module.exports = { logger };
