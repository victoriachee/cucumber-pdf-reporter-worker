const express = require("express");
const path = require("path");

const routes = require("./routes/test.routes");

const app = express();

app.use(express.json());

app.use("/api/tests", routes);

/* serve reports */
app.use("/reports", express.static(path.join(__dirname, "../reports")));

const frontendPath = path.join(__dirname, "../frontend");

/* serve frontend */
app.use(express.static(frontendPath));

app.get("/", (req, res) => {
  res.sendFile(path.join(frontendPath, "index.html"));
});

module.exports = app;
