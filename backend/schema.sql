-- CDEGAD KP database schema (MySQL / MariaDB)
-- Run automatically by `node init_db.js` on server start, or manually:
--   mysql -u cdegad -p cdegad_kp < schema.sql

CREATE TABLE IF NOT EXISTS awareness_raising (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(255) NULL,
  forest_region VARCHAR(100) NULL,
  forest_circle_name VARCHAR(255) NULL,
  division_name VARCHAR(255) NULL,
  sub_division_range VARCHAR(255) NULL,
  project_name VARCHAR(255) NULL,
  type_of_event VARCHAR(255) NULL,
  institution_name VARCHAR(255) NULL,
  venue VARCHAR(255) NULL,
  chief_guest VARCHAR(255) NULL,
  description TEXT NULL,
  upload_image VARCHAR(500) NULL,
  upload_file VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS youth_women_nursery (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(255) NULL,
  project_name VARCHAR(255) NULL,
  division_name VARCHAR(255) NULL,
  sub_division_range VARCHAR(255) NULL,
  vdc_wo VARCHAR(255) NULL,
  nursery_owner_name VARCHAR(255) NULL,
  village_name VARCHAR(255) NULL,
  limits_plants VARCHAR(255) NULL,
  nursery_owner_full_name VARCHAR(255) NULL,
  contact_number VARCHAR(100) NULL,
  cnic_nursery_owner VARCHAR(100) NULL,
  date_of_agreement VARCHAR(50) NULL,
  reference_coordinates VARCHAR(255) NULL,
  forest_region VARCHAR(100) NULL,
  forest_circle_name VARCHAR(255) NULL,
  date_establishment VARCHAR(50) NULL,
  upload_file VARCHAR(500) NULL,
  upload_image VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS farm_agro_forestry (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(255) NULL,
  forest_division VARCHAR(255) NULL,
  sub_division VARCHAR(255) NULL,
  plants_distributed_today VARCHAR(100) NULL,
  major_species VARCHAR(255) NULL,
  total_plants_distributed VARCHAR(100) NULL,
  upload_file VARCHAR(500) NULL,
  upload_image VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS other_activity (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(255) NULL,
  activity_title VARCHAR(255) NULL,
  forest_division VARCHAR(255) NULL,
  forest_circle_name VARCHAR(255) NULL,
  division_name VARCHAR(255) NULL,
  subdivision_name VARCHAR(255) NULL,
  project_name VARCHAR(255) NULL,
  name_of_wo VARCHAR(255) NULL,
  village_name VARCHAR(255) NULL,
  description TEXT NULL,
  upload_file VARCHAR(500) NULL,
  upload_image VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255) NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  designation VARCHAR(255) NULL,
  phone VARCHAR(50) NULL,
  role VARCHAR(50) DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS vdc (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(255) NULL,
  forest_region VARCHAR(100) NULL,
  forest_circle_name VARCHAR(255) NULL,
  forest_division VARCHAR(255) NULL,
  sub_division_range VARCHAR(255) NULL,
  village_pu VARCHAR(255) NULL,
  reference_coordinates VARCHAR(255) NULL,
  vdc_name VARCHAR(255) NULL,
  date_of_registration VARCHAR(50) NULL,
  project_name VARCHAR(255) NULL,
  president_name VARCHAR(255) NULL,
  secretary_treasurer VARCHAR(255) NULL,
  members_count VARCHAR(50) NULL,
  contact_number VARCHAR(100) NULL,
  interventions TEXT NULL,
  upload_file VARCHAR(500) NULL,
  upload_image VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS jfmc (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(255) NULL,
  forest_region VARCHAR(100) NULL,
  forest_circle_name VARCHAR(255) NULL,
  forest_division VARCHAR(255) NULL,
  sub_division_range VARCHAR(255) NULL,
  village_pu VARCHAR(255) NULL,
  reference_coordinates VARCHAR(255) NULL,
  committee_name VARCHAR(255) NULL,
  date_of_registration VARCHAR(50) NULL,
  project_name VARCHAR(255) NULL,
  president_name VARCHAR(255) NULL,
  secretary_treasurer VARCHAR(255) NULL,
  members_count VARCHAR(50) NULL,
  contact_number VARCHAR(100) NULL,
  interventions TEXT NULL,
  upload_file VARCHAR(500) NULL,
  upload_image VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mass_planting (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(255) NULL,
  forest_region VARCHAR(100) NULL,
  forest_circle_name VARCHAR(255) NULL,
  division_name VARCHAR(255) NULL,
  sub_division_range VARCHAR(255) NULL,
  project_name VARCHAR(255) NULL,
  institute_org VARCHAR(255) NULL,
  venue VARCHAR(255) NULL,
  chief_guest VARCHAR(255) NULL,
  date_of_event VARCHAR(50) NULL,
  total_plants VARCHAR(100) NULL,
  plant_details TEXT NULL,
  upload_file VARCHAR(500) NULL,
  upload_image VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS women_organization (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(255) NULL,
  forest_region VARCHAR(100) NULL,
  forest_circle_name VARCHAR(255) NULL,
  division_name VARCHAR(255) NULL,
  sub_division_range VARCHAR(255) NULL,
  village_pu VARCHAR(255) NULL,
  reference_coordinates VARCHAR(255) NULL,
  name_of_wo VARCHAR(255) NULL,
  project_name VARCHAR(255) NULL,
  date_established VARCHAR(50) NULL,
  chairperson_name VARCHAR(255) NULL,
  secretary_treasurer VARCHAR(255) NULL,
  contact_number VARCHAR(100) NULL,
  interventions TEXT NULL,
  upload_file VARCHAR(500) NULL,
  upload_image VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS department_files (
  id INT AUTO_INCREMENT PRIMARY KEY,
  filename VARCHAR(500) NOT NULL,
  original_name VARCHAR(500) NULL,
  category VARCHAR(100) NULL,
  size BIGINT NULL,
  description VARCHAR(1000) NULL,
  uploaded_by VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
