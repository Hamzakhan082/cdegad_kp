const { runInit } = require("./init_runner");

runInit()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("[init-db] Failed:", err.message);
    process.exit(1);
  });
