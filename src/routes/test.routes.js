const router = require("express").Router();
const controller = require("../controllers/test.controller");
const path = require("path");
const fs = require("fs");

router.post("/run", controller.runTests);
router.get("/status/:id", controller.getStatus);
router.delete("/cancel/:id", controller.cancel);
router.get("/reports", (req, res) => {
  const runsDir = path.join(process.cwd(), "reports/runs");

  if (!fs.existsSync(runsDir)) return res.json([]);

  const folders = fs
    .readdirSync(runsDir)
    .filter((f) => fs.statSync(path.join(runsDir, f)).isDirectory())
    .sort()
    .reverse();

  res.json(folders);
});

module.exports = router;
