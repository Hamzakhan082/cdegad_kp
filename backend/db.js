require("dotenv").config();

const mysql = require("mysql2");

// Credentials come from environment variables (see .env / .env.example).
// Never hard-code database credentials in source code.
const pool = mysql.createPool({
  host: process.env.DB_HOST || "127.0.0.1",
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  dateStrings: true,
});

// Promisified query helper so routes can use async/await.
function query(sql, params = []) {
  return new Promise((resolve, reject) => {
    pool.query(sql, params, (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
}

function ping() {
  return new Promise((resolve, reject) => {
    pool.query("SELECT 1", (err) => (err ? reject(err) : resolve()));
  });
}

module.exports = { pool, query, ping };
