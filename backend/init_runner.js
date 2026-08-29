require("dotenv").config();
const fs = require("fs");
const path = require("path");
const { query, ping } = require("./db");

// Creates all tables defined in schema.sql (idempotent).
async function runInit() {
  await ping();
  const schema = fs.readFileSync(path.join(__dirname, "schema.sql"), "utf8");
  const statements = schema
    .split(";")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

  for (const statement of statements) {
    await query(statement);
  }
  console.log("[db] Tables are ready in database:", process.env.DB_NAME);
  return true;
}

module.exports = { runInit };
