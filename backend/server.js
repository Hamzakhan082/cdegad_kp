require("dotenv").config();
const path = require("path");
const fs = require("fs");
const express = require("express");
const cors = require("cors");
const multer = require("multer");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { query, ping } = require("./db");
const { runInit } = require("./init_runner");

const app = express();
const PORT = Number(process.env.PORT) || 3000;
const JWT_SECRET = process.env.JWT_SECRET || "cdegad-kp-dev-secret-change-me";

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files so the app can view/download them later.
const uploadsDir = path.join(__dirname, "uploads");
fs.mkdirSync(uploadsDir, { recursive: true });
app.use("/uploads", express.static(uploadsDir));

// ------------------------- Upload setup -------------------------
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadsDir),
  filename: (req, file, cb) => {
    const unique = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, unique + "-" + file.originalname.replace(/[^a-zA-Z0-9._-]/g, "_"));
  },
});
const upload = multer({ storage, limits: { fileSize: 25 * 1024 * 1024 } });

// Accept every field name the app historically used so no attachment is dropped.
const formFields = [
  { name: "upload_file", maxCount: 1 },
  { name: "upload_image", maxCount: 1 },
  { name: "Upload_File", maxCount: 1 },
  { name: "Upload_Image", maxCount: 1 },
  { name: "file", maxCount: 1 },
];

// ------------------------- Helpers -------------------------
function ok(res, data, message, status = 200) {
  res.status(status).json({ success: true, data, message });
}

function fail(res, status, message, error) {
  res.status(status).json({ success: false, message, error: error ? String(error) : undefined });
}

// First value found among the given body keys (camelCase + snake_case tolerant).
function val(body, keys) {
  for (const k of keys) {
    if (body[k] !== undefined && body[k] !== null && String(body[k]).trim() !== "") {
      return body[k];
    }
  }
  return null;
}

function getFile(files, keys) {
  if (!files) return null;
  for (const k of keys) {
    if (files[k] && files[k][0]) return files[k][0].filename;
  }
  return null;
}

const FILE_COL_KEYS = ["upload_file", "Upload_File", "file"];
const IMAGE_COL_KEYS = ["upload_image", "Upload_Image"];

// ------------------------- Auth helpers -------------------------
function signToken(user) {
  return jwt.sign({ id: user.id, email: user.email, role: user.role || "user" }, JWT_SECRET, {
    expiresIn: "7d",
  });
}

function publicUser(u) {
  return {
    id: u.id,
    full_name: u.full_name,
    email: u.email,
    designation: u.designation,
    phone: u.phone,
    role: u.role || "user",
  };
}

async function signupHandler(req, res) {
  const { full_name, email, password, designation, phone, name } = req.body;
  const normEmail = String(email || name || "").trim().toLowerCase();
  if (!normEmail || !password) return fail(res, 400, "Email and password are required");
  if (String(password).length < 6) return fail(res, 400, "Password must be at least 6 characters");

  try {
    const [existing] = await query("SELECT id FROM users WHERE email = ?", [normEmail]);
    if (existing) return fail(res, 409, "An account with this email already exists");

    const hash = await bcrypt.hash(String(password), 10);
    const result = await query(
      "INSERT INTO users (full_name, email, password_hash, designation, phone) VALUES (?,?,?,?,?)",
      [full_name || null, normEmail, hash, designation || null, phone || null]
    );
    const user = { id: result.insertId, email: normEmail, designation, phone, full_name, role: "user" };
    ok(res, { user: publicUser(user), token: signToken(user) }, "Account created successfully", 201);
  } catch (err) {
    console.error("[signup]", err);
    fail(res, 500, "Signup failed", err);
  }
}

async function loginHandler(req, res) {
  const { email, password } = req.body;
  if (!email || !password) return fail(res, 400, "Email and password are required");
  const normEmail = String(email).trim().toLowerCase();

  try {
    const rows = await query("SELECT * FROM users WHERE email = ?", [normEmail]);
    const user = rows[0];
    if (!user || !(await bcrypt.compare(String(password), user.password_hash))) {
      return fail(res, 401, "Invalid email or password");
    }
    ok(res, { user: publicUser(user), token: signToken(user) }, "Login successful");
  } catch (err) {
    console.error("[login]", err);
    fail(res, 500, "Login failed", err);
  }
}

function requireAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = (header.startsWith("Bearer ") ? header.slice(7) : header) || req.query.token || (req.body && req.body.token);
  if (!token) return fail(res, 401, "Authentication required. Please log in.");
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (err) {
    fail(res, 401, "Invalid or expired token. Please log in again.");
  }
}

// ------------------------- Health -------------------------
app.get("/", (req, res) => {
  res.json({ name: "CDEGAD KP API", status: "running" });
});

app.get("/api/health", async (req, res) => {
  try {
    await ping();
    res.json({ success: true, message: "Database connection OK" });
  } catch (err) {
    fail(res, 500, "Database connection failed", err);
  }
});

// =================================================================
// AUTHENTICATION
// =================================================================
app.post("/api/signup", signupHandler);
app.post(["/APP_signup_api", "/api/dashboard-signup"], signupHandler);
app.post("/api/login", loginHandler);
app.post("/api/dashboard-login", loginHandler);

// =================================================================
// GENERIC CRUD FACTORY
// =================================================================
// colsMap: { columnName: [accepted request keys...] }
function insertRow(table, colsMap, body, files) {
  const cols = [];
  const vals = [];
  for (const [col, keys] of Object.entries(colsMap)) {
    let v;
    if (col === "upload_file") v = getFile(files, FILE_COL_KEYS);
    else if (col === "upload_image") v = getFile(files, IMAGE_COL_KEYS);
    else v = val(body, keys);
    cols.push(col);
    vals.push(v);
  }
  const placeholders = cols.map(() => "?").join(", ");
  return query(`INSERT INTO ${table} (${cols.join(", ")}) VALUES (${placeholders})`, vals);
}

async function updateRow(table, colsMap, body, files, id) {
  const sets = [];
  const vals = [];
  for (const [col, keys] of Object.entries(colsMap)) {
    let v;
    if (col === "upload_file") v = getFile(files, FILE_COL_KEYS);
    else if (col === "upload_image") v = getFile(files, IMAGE_COL_KEYS);
    else v = val(body, keys);
    if (v !== null && v !== undefined) {
      sets.push(`${col} = ?`);
      vals.push(v);
    }
  }
  if (sets.length === 0) return;
  vals.push(id);
  await query(`UPDATE ${table} SET ${sets.join(", ")} WHERE id = ?`, vals);
}

function crud(table, colsMap, required, opts = {}) {
  const route = opts.route || `/api/${table}`;
  const name = opts.name || table;

  app.post(route, requireAuth, upload.fields(formFields), async (req, res) => {
    try {
      for (const r of required) {
        if (val(req.body, r.keys) == null) {
          return fail(res, 400, r.message || `${r.name} is required`);
        }
      }
      const result = await insertRow(table, colsMap, req.body, req.files);
      const [rows] = await query(`SELECT * FROM ${table} WHERE id = ?`, [result.insertId]);
      ok(res, rows, `${name} record saved successfully!`, 201);
    } catch (err) {
      console.error(`[${name}] insert`, err);
      fail(res, 500, `Failed to save ${name} record`, err);
    }
  });

  app.get(route, async (req, res) => {
    try {
      const rows = await query(`SELECT * FROM ${table} ORDER BY id DESC`);
      ok(res, rows);
    } catch (err) {
      console.error(`[${name}] fetch`, err);
      fail(res, 500, "Fetch failed", err);
    }
  });

  app.get(`${route}/:id`, async (req, res) => {
    try {
      const [rows] = await query(`SELECT * FROM ${table} WHERE id = ?`, [req.params.id]);
      if (!rows) return fail(res, 404, `${name} record not found`);
      ok(res, rows);
    } catch (err) {
      fail(res, 500, "Fetch failed", err);
    }
  });

  app.put(`${route}/:id`, requireAuth, upload.fields(formFields), async (req, res) => {
    try {
      await updateRow(table, colsMap, req.body, req.files, req.params.id);
      const [rows] = await query(`SELECT * FROM ${table} WHERE id = ?`, [req.params.id]);
      ok(res, rows || null, `${name} record updated successfully!`);
    } catch (err) {
      console.error(`[${name}] update`, err);
      fail(res, 500, `Failed to update ${name} record`, err);
    }
  });

  app.delete(`${route}/:id`, requireAuth, async (req, res) => {
    try {
      await query(`DELETE FROM ${table} WHERE id = ?`, [req.params.id]);
      ok(res, { message: "Record deleted successfully" }, `${name} record deleted successfully`);
    } catch (err) {
      fail(res, 500, "Delete failed", err);
    }
  });
}

// =================================================================
// AWARENESS RAISING
// =================================================================
crud("awareness_raising", {
  employee_name: ["employee_name", "employeeName", "title"],
  forest_region: ["forest_region", "forestRegion"],
  forest_circle_name: ["forest_circle_name", "circle", "forestCircleName"],
  division_name: ["division_name", "division", "divisionName"],
  sub_division_range: ["sub_division_range", "tehsil", "subDivisionRange"],
  project_name: ["project_name", "projectName"],
  type_of_event: ["type_of_event", "typeOfEvent", "topic"],
  institution_name: ["institution_name", "institutionName"],
  venue: ["venue"],
  chief_guest: ["chief_guest", "chiefGuest"],
  description: ["description"],
  upload_file: FILE_COL_KEYS,
  upload_image: IMAGE_COL_KEYS,
}, [{ name: "Employee Name", keys: ["employee_name", "employeeName", "title"] }], { route: "/api/awareness", name: "Awareness Raising" });

// =================================================================
// YOUTH / WOMEN NURSERY
// =================================================================
const YOUTH_WOMEN_COLS = {
  employee_name: ["employee_name", "Employee_Name", "employeeName"],
  project_name: ["project_name", "Project_Name", "projectName"],
  division_name: ["division_name", "Division_Name", "divisionName"],
  sub_division_range: ["sub_division_range", "Sub_Division_Range", "subDivisionRange"],
  vdc_wo: ["vdc_wo", "VDC_WO"],
  nursery_owner_name: ["nursery_owner_name", "Nursery_Owner_Name"],
  village_name: ["village_name", "Village_Name", "villageName", "district"],
  limits_plants: ["limits_plants", "Limits"],
  nursery_owner_full_name: ["nursery_owner_full_name", "Nursery_Owner_Full_Name"],
  contact_number: ["contact_number", "Contact_Number", "contactNumber"],
  cnic_nursery_owner: ["cnic_nursery_owner", "CNIC_Nursery_Owner"],
  date_of_agreement: ["date_of_agreement", "Date_of_Agreement"],
  reference_coordinates: ["reference_coordinates", "Reference_Coordinates", "coordinates"],
  forest_region: ["forest_region", "Forest_Region", "forestRegion"],
  forest_circle_name: ["forest_circle_name", "Forest_Circle_Name"],
  date_establishment: ["date_establishment", "Date", "dateEstablishment"],
  upload_file: FILE_COL_KEYS,
  upload_image: IMAGE_COL_KEYS,
};

crud("youth_women_nursery", YOUTH_WOMEN_COLS, [
  { name: "Employee Name", keys: ["employee_name", "Employee_Name", "employeeName"] },
  { name: "Project Name", keys: ["project_name", "Project_Name", "projectName"] },
], { route: "/api/youthwomen", name: "Youth / Women Nursery" });

// =================================================================
// FARM / AGRO FORESTRY
// =================================================================
const FARM_AGRO_COLS = {
  employee_name: ["employee_name", "ownerName", "employeeName"],
  forest_division: ["forest_division", "division", "forestDivision"],
  sub_division: ["sub_division", "tehsil", "subDivision"],
  plants_distributed_today: ["plants_distributed_today", "totalArea", "plantsDistributedToday"],
  major_species: ["major_species", "crops", "majorSpecies"],
  total_plants_distributed: ["total_plants_distributed", "description", "totalPlantsDistributed"],
  upload_file: FILE_COL_KEYS,
  upload_image: IMAGE_COL_KEYS,
};

crud("farm_agro_forestry", FARM_AGRO_COLS,
  [{ name: "Employee Name", keys: ["employee_name", "ownerName", "employeeName"] }],
  { route: "/api/farm-agro", name: "Farm / Agro Forestry" });

crud("farm_agro_forestry", FARM_AGRO_COLS, [
  { name: "Employee Name", keys: ["employee_name", "ownerName", "employeeName"] },
  { name: "Farm Name", keys: ["farmName", "ownerName", "employee_name"] },
], { route: "/api/farm-agro-forestry", name: "Farm Agro Forestry" });

// =================================================================
// OTHER ACTIVITY
// =================================================================
crud("other_activity", {
  employee_name: ["employee_name", "ownerName", "employeeName"],
  activity_title: ["activity_title", "activityTitle", "activityName"],
  forest_division: ["forest_division", "division", "forestDivision"],
  forest_circle_name: ["forest_circle_name", "forestCircleName"],
  division_name: ["division_name", "divisionName"],
  subdivision_name: ["subdivision_name", "tehsil", "subdivisionName"],
  project_name: ["project_name", "projectName"],
  name_of_wo: ["name_of_wo", "nameOfWo", "name_of_wo"],
  village_name: ["village_name", "villageName", "district"],
  description: ["description"],
  upload_file: FILE_COL_KEYS,
  upload_image: IMAGE_COL_KEYS,
}, [
  { name: "Employee Name", keys: ["employee_name", "ownerName", "employeeName"] },
  { name: "Activity Title", keys: ["activity_title", "activityTitle", "activityName"] },
], { route: "/api/other-activity", name: "Other Activity" });

// =================================================================
// VDC
// =================================================================
crud("vdc", {
  employee_name: ["employee_name", "employeeName"],
  forest_region: ["forest_region", "forestRegion"],
  forest_circle_name: ["forest_circle_name", "circle", "forestCircleName"],
  forest_division: ["forest_division", "division", "forestDivision"],
  sub_division_range: ["sub_division_range", "tehsil", "subDivisionRange"],
  village_pu: ["village_pu", "villageName", "village", "villagePu"],
  reference_coordinates: ["reference_coordinates", "coordinates", "referenceCoordinates"],
  vdc_name: ["vdc_name", "vdcName", "name"],
  date_of_registration: ["date_of_registration", "dateOfRegistration", "registrationDate"],
  project_name: ["project_name", "projectName"],
  president_name: ["president_name", "chairmanName", "presidentName", "chairman_name"],
  secretary_treasurer: ["secretary_treasurer", "secretaryName", "secretaryTreasurer"],
  members_count: ["members_count", "membersCount"],
  contact_number: ["contact_number", "contactNumber", "contact"],
  interventions: ["interventions"],
  upload_file: FILE_COL_KEYS,
  upload_image: IMAGE_COL_KEYS,
}, [{ name: "Employee Name", keys: ["employee_name", "employeeName"] }], { route: "/API/VDC", name: "VDC" });

// =================================================================
// JFMC
// =================================================================
crud("jfmc", {
  employee_name: ["employee_name", "employeeName"],
  forest_region: ["forest_region", "forestRegion"],
  forest_circle_name: ["forest_circle_name", "circle", "forestCircleName"],
  forest_division: ["forest_division", "division", "forestDivision"],
  sub_division_range: ["sub_division_range", "tehsil", "subDivisionRange"],
  village_pu: ["village_pu", "villageName", "village", "villagePu"],
  reference_coordinates: ["reference_coordinates", "coordinates", "referenceCoordinates"],
  committee_name: ["committee_name", "committeeName", "name"],
  date_of_registration: ["date_of_registration", "dateOfRegistration", "registrationDate"],
  project_name: ["project_name", "projectName"],
  president_name: ["president_name", "presidentName", "chairman_name", "chairmanName"],
  secretary_treasurer: ["secretary_treasurer", "secretaryName", "secretaryTreasurer"],
  members_count: ["members_count", "membersCount"],
  contact_number: ["contact_number", "contactNumber", "contact"],
  interventions: ["interventions"],
  upload_file: FILE_COL_KEYS,
  upload_image: IMAGE_COL_KEYS,
}, [{ name: "Employee Name", keys: ["employee_name", "employeeName"] }], { route: "/api/jfmc", name: "JFMC" });

// =================================================================
// MASS PLANTING (CD & Extension)
// =================================================================
crud("mass_planting", {
  employee_name: ["employee_name", "employeeName"],
  forest_region: ["forest_region", "forestRegion"],
  forest_circle_name: ["forest_circle_name", "circle", "forestCircleName"],
  division_name: ["division_name", "division", "divisionName"],
  sub_division_range: ["sub_division_range", "tehsil", "subDivisionRange"],
  project_name: ["project_name", "projectName"],
  institute_org: ["institute_org", "institutionName", "instituteOrg", "institute"],
  venue: ["venue"],
  chief_guest: ["chief_guest", "chiefGuest"],
  date_of_event: ["date_of_event", "date"],
  total_plants: ["total_plants", "totalPlants"],
  plant_details: ["plant_details", "plantDetails"],
  upload_file: FILE_COL_KEYS,
  upload_image: IMAGE_COL_KEYS,
}, [{ name: "Employee Name", keys: ["employee_name", "employeeName"] }], { route: "/API/mass-plants", name: "Mass Planting" });

// =================================================================
// WOMEN ORGANIZATION (GAD)
// =================================================================
crud("women_organization", {
  employee_name: ["employee_name", "employeeName"],
  forest_region: ["forest_region", "forestRegion"],
  forest_circle_name: ["forest_circle_name", "circle", "forestCircleName"],
  division_name: ["division_name", "division", "divisionName"],
  sub_division_range: ["sub_division_range", "tehsil", "subDivisionRange"],
  village_pu: ["village_pu", "villageName", "village", "villagePu"],
  reference_coordinates: ["reference_coordinates", "coordinates", "referenceCoordinates"],
  name_of_wo: ["name_of_wo", "organizationName", "nameOfWo", "woName"],
  project_name: ["project_name", "projectName"],
  date_established: ["date_established", "dateEstablished", "date"],
  chairperson_name: ["chairperson_name", "chairpersonName", "presidentName"],
  secretary_treasurer: ["secretary_treasurer", "secretaryName", "secretaryTreasurer"],
  contact_number: ["contact_number", "contactNumber", "contact"],
  interventions: ["interventions"],
  upload_file: FILE_COL_KEYS,
  upload_image: IMAGE_COL_KEYS,
}, [{ name: "Employee Name", keys: ["employee_name", "employeeName"] }], { route: "/api/women-organization", name: "Women Organization" });

// =================================================================
// DOWNLOADS (department files)
// =================================================================
app.post("/api/upload", requireAuth, upload.single("file"), async (req, res) => {
  try {
    if (!req.file) return fail(res, 400, "No file uploaded");
    const { category, description } = req.body;
    const result = await query(
      "INSERT INTO department_files (filename, original_name, category, size, description, uploaded_by) VALUES (?,?,?,?,?,?)",
      [req.file.filename, req.file.originalname, category || null, req.file.size, description || null, req.user.email || null]
    );
    ok(res, {
      id: result.insertId,
      filename: req.file.filename,
      original_name: req.file.originalname,
    }, "File uploaded successfully", 201);
  } catch (err) {
    console.error("[upload]", err);
    fail(res, 500, "Upload failed", err);
  }
});

app.get("/api/downloads", async (req, res) => {
  try {
    const rows = await query("SELECT * FROM department_files ORDER BY id DESC");
    ok(res, rows);
  } catch (err) {
    fail(res, 500, "Fetch failed", err);
  }
});

app.delete("/api/downloads/:id", requireAuth, async (req, res) => {
  try {
    const rows = await query("SELECT * FROM department_files WHERE id = ?", [req.params.id]);
    if (rows[0] && rows[0].filename) {
      const f = path.join(uploadsDir, rows[0].filename);
      try {
        if (fs.existsSync(f)) fs.unlinkSync(f);
      } catch (e) { /* ignore */ }
    }
    await query("DELETE FROM department_files WHERE id = ?", [req.params.id]);
    ok(res, { message: "File deleted successfully" }, "File deleted successfully");
  } catch (err) {
    fail(res, 500, "Delete failed", err);
  }
});

// ------------------------- Start -------------------------
runInit()
  .then(() => {
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`CDEGAD KP API listening on http://0.0.0.0:${PORT}`);
    });
  })
  .catch((err) => {
    console.error("[server] Database init failed, starting anyway...", err.message);
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`CDEGAD KP API listening on http://0.0.0.0:${PORT} (DB init skipped)`);
    });
  });