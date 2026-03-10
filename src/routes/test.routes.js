const router = require("express").Router();
const controller = require("../controllers/test.controller");
const fs = require("fs");
const path = require("path");

router.get("/reports", (req, res) => {
  const reportsDir = path.join(__dirname, "../../reports");

  const files = fs.readdirSync(reportsDir);

  res.json(files);
});

router.post("/run", controller.runTests);

module.exports = router;
