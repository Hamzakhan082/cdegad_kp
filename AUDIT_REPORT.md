# CDEGAD KP Forest Department — Integration Audit Report

Date: 2026-08-30
Scope: Flutter app (`lib/`) ↔ Node.js/Express backend (`backend/`) integration.

## 1. Summary

All "All fixes" audit items are implemented and statically verified:

- `flutter analyze` — 0 errors (37 pre-existing lints/infos unrelated to this work).
- `flutter test` — 3/3 passing.
- `node --check` — `backend/server.js`, `backend/init_runner.js`, `backend/db.js` all pass.

Runtime DB endpoints could not be end-to-end tested locally because no MySQL/MariaDB
service is listening on this machine (server boots with "(DB init skipped)" after
`ECONNREFUSED 127.0.0.1:3306`). DB-dependent behavior must be verified once a MySQL
instance is reachable (`.env` present, schema auto-init via `init_runner.js`).

## 2. What was fixed

### Auth (real backend)
- `AuthRepositoryImpl` posts to `/api/signup`, `/api/login`, `/api/dashboard-signup`,
  `/api/dashboard-login`, `/APP_signup_api`; maps Dio errors to `AuthException` with
  `isOffline`/`statusCode`; `AuthResponseModel.fromJson` unwraps `data`/`data.user`/nested maps.
- `auth_provider.dart`, `login_screen.dart`, `signup_screen.dart` persist `auth_token`
  (JWT) + `user_data`, enforce a minimal loading delay, and navigate on success.
  Backend unreachable → offline-mode sign-in still opens Home.
- `home_screen.dart` drawer reads the persisted user (name + email).
- Widget tests updated to wrap `MyApp` in `ProviderScope` (matches `main()`).

### Data models
- `WomenOrganizationModel`, `FarmAgroForestryModel`, `OtherActivityModel` now preserve
  unknown/backend snake_case keys via `extraFields`, so record rows round-trip intact.

### Forms → live repos (multipart where the backend accepts files)
| Form | Endpoint | File fields |
|---|---|---|
| VDC (`vdc_form.dart`) | `/API/VDC` | `upload_file` |
| JFMC (`jfmc_form.dart`) | `/api/jfmc` | `upload_file` |
| Mass Planting (extension `mass_planting.dart`) | `/API/mass-plants` | `upload_file` |
| Awareness Raising | `/api/awareness` | image + file (already wired) |
| GAD Women Organization | `/api/women-organization` | image + file |
| GAD Women Nursery | `/api/youthwomen` | image + file |
| GAD Mass Planting Event | `/API/mass-plants` | image + file |
| GAD Farm / Agro Forestry | `/api/farm-agro` | image + file |
| GAD Other Activity | `/api/other-activity` | image + file |

Repos extended with `createMultipart`:
- `women_organization_repository.dart`
- `farm_agro_forestry_repository.dart`
- `other_activity_repository.dart`

`DioClient` gained `postFormData(...)` (explicit file-field names) and `downloadBytes(...)`.

### Records page
- Mock rows removed. Now pulls live data for VDC, JFMC, Mass Planting Event, Awareness,
  Women Organization, Women Nursery, Farm / Agro Forestry, Other Activity, and "All"
  (concatenation of all 8).
- Name/date normalization + per-type delete wired to the matching repo.

### Downloads screen
- Replaced mock file list with `GET /api/downloads`; real upload via `POST /api/upload`
  (`file` field), real download via `/uploads/<filename>` bytes, real delete via
  `DELETE /api/downloads/<id>`.

## 3. Key mappings (frontend → backend columns)

- Mass Planting: `division_name`, `institute_org`, `venue`, `chief_guest`,
  `date_of_event`, `total_plants`, `plant_details`.
- Women Organization: `name_of_wo`, `village_pu`, `reference_coordinates`,
  `date_established`, `chairperson_name`, `secretary_treasurer`, `interventions`.
- Farm / Agro: `employee_name`, `forest_division`, `sub_division`,
  `plants_distributed_today`, `major_species`, `total_plants_distributed`.
- Other Activity: `activity_title`, `subdivision_name`, `project_name`, `name_of_wo`,
  `village_name`, `description`.

## 4. Known environment-dependent items

1. No local MySQL — all DB endpoints (CRUD, auth against `users`, downloads) are
   **untested at runtime** on this machine. Verify after provisioning MySQL
   (`npm start` in `backend/`, tables auto-create, `users`/`vdc`/`jfmc`/`mass_planting`/etc.).
2. Base URL default `http://10.0.2.2:3000` (Android emulator → host). Override with
   `--dart-define=API_BASE_URL=...` for device/host testing.
3. `flutter analyze` still reports pre-existing warnings/infos (unused fields in
   `women_organization_form_screen.dart`, async-gap `context` usage, `resize_logo.dart`
   prints, `file_upload_util.dart` unused local) — none introduced by this work.

## 5. Files touched this session

- `backend/` — unchanged (already complete from prior pass).
- `lib/core/api/api_endpoints.dart` — added `upload`, `downloads`, `downloadsById`.
- `lib/core/api/dio_client.dart` — `postFormData`, `downloadBytes`.
- `lib/features/{women_organization,farm_agro_forestry,other_activity}/repositories/*`
  — `createMultipart`.
- `lib/features/{women_organization,farm_agro_forestry,other_activity}/models/*`
  — `extraFields` + snake_case fallbacks.
- `lib/screens/forms/cd_forms/vdc_form.dart`, `jfmc_form.dart` — real submit.
- `lib/screens/forms/extension_forms/mass_planting.dart` — real submit.
- `lib/screens/forms/gad_form/gad.dart` — 5-activity live submit.
- `lib/screens/records/records_view_page.dart` — live records + delete.
- `lib/screens/downloads/downloads_screen.dart` — live list/upload/download/delete.
- `test/widget_test.dart` — `ProviderScope` wrapper.