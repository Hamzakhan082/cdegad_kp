import 'package:cdegad_kp/core/config/app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => AppConfig.baseUrl;

  static const String uploads = '/uploads';

  // ── Auth ──────────────────────────────────────────────
  static const String signup = '/api/signup';
  static const String login = '/api/login';
  static const String dashboardSignup = '/api/dashboard-signup';
  static const String dashboardLogin = '/api/dashboard-login';
  static const String appSignup = '/APP_signup_api';

  // ── VDC ───────────────────────────────────────────────
  static const String vdc = '/API/VDC';
  static String vdcById(String id) => '/API/VDC/$id';

  // ── JFMC ──────────────────────────────────────────────
  static const String jfmc = '/api/jfmc';
  static String jfmcById(String id) => '/api/jfmc/$id';

  // ── Mass Plantation ──────────────────────────────────
  static const String massPlantation = '/API/mass-plants';
  static String massPlantationById(String id) => '/API/mass-plants/$id';

  // ── Awareness ────────────────────────────────────────
  static const String awareness = '/api/awareness';
  static String awarenessById(String id) => '/api/awareness/$id';

  // ── Youth Women Nursery ──────────────────────────────
  static const String youthWomen = '/api/youthwomen';
  static String youthWomenById(String id) => '/api/youthwomen/$id';

  // ── Farm Agro Forestry ───────────────────────────────
  static const String farmAgro = '/api/farm-agro';
  static const String farmAgroForestry = '/api/farm-agro-forestry';
  static String farmAgroForestryById(String id) => '/api/farm-agro-forestry/$id';

  // ── Women Organization ───────────────────────────────
  static const String womenOrganization = '/api/women-organization';
  static String womenOrganizationById(String id) =>
      '/api/women-organization/$id';

  // ── Other Activity ───────────────────────────────────
  static const String otherActivity = '/api/other-activity';
  static String otherActivityById(String id) => '/api/other-activity/$id';

  // ── Debug ────────────────────────────────────────────
  static const String debugUploadsStatus = '/debug/uploads-status';

  // ── Downloads (department files) ────────────────────
  static const String upload = '/api/upload';
  static const String downloads = '/api/downloads';
  static String downloadsById(String id) => '/api/downloads/$id';

  static String uploadFile(String filename) => '$uploads/$filename';
}
