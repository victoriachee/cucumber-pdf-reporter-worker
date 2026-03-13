const express = require("express");
const path = require("path");

const routes = require("./routes/test.routes");

const app = express();

app.use(express.json());

/* API routes */
app.use("/api/tests", routes);

/* serve generated reports */
app.use("/reports", express.static(path.join(process.cwd(), "reports")));

/* serve frontend */
const frontendPath = path.join(__dirname, "../frontend");
app.use(express.static(frontendPath));

app.get("/", (req, res) => {
  res.sendFile(path.join(frontendPath, "index.html"));
});

module.exports = app;
