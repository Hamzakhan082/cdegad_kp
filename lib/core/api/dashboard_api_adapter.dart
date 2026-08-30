/// Compatibility helpers for the existing dashboard API on port 5000.
///
/// The Flutter UI was originally written against a newer, generic schema,
/// while the client dashboard uses the field names in the legacy MySQL
/// tables.  These helpers keep the UI models stable and translate at the API
/// boundary so both applications read and write the same database.
class DashboardApiAdapter {
  DashboardApiAdapter._();

  static List<Map<String, dynamic>> list(dynamic responseData) {
    final raw = responseData is List
        ? responseData
        : responseData is Map && responseData['data'] is List
        ? responseData['data'] as List
        : const <dynamic>[];
    return raw
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  static Map<String, dynamic> record(
    dynamic responseData, {
    Map<String, dynamic> fallback = const {},
  }) {
    final result = <String, dynamic>{...fallback};
    if (responseData is Map) {
      final root = Map<String, dynamic>.from(responseData);
      if (root['data'] is Map) {
        result.addAll(Map<String, dynamic>.from(root['data'] as Map));
      }
      final id = root['id'] ?? root['insertId'] ?? result['insertId'];
      if (id != null) result['id'] = id;
    }
    return result;
  }

  static Map<String, dynamic> vdcRequest(Map<String, dynamic> value) => {
    ...value,
    'employee_name': _first(value, ['employee_name'], 'Mobile App Submission'),
    'forest_region': _first(value, ['forest_region', 'province', 'district']),
    'forest_circle': _first(value, ['forest_circle', 'division']),
    'sub_division_region': _first(value, ['sub_division_region', 'tehsil']),
    'village_pu': _first(value, ['village_pu', 'villageName']),
    'vdc_name': _first(value, ['vdc_name', 'villageName']),
    'name_of_project_establishment': _first(value, [
      'name_of_project_establishment',
      'province',
    ]),
    'main_intervention': _first(value, ['main_intervention', 'description']),
  };

  static Map<String, dynamic> vdcRow(Map<String, dynamic> value) => {
    ...value,
    'villageName': _first(value, ['villageName', 'vdc_name', 'village_pu']),
    'district': _first(value, ['district', 'forest_region']),
    'division': _first(value, ['division', 'forest_circle']),
    'tehsil': _first(value, ['tehsil', 'sub_division_region']),
    'province': _first(value, ['province', 'name_of_project_establishment']),
    'description': _first(value, ['description', 'main_intervention']),
    'imageUrl': _first(value, ['imageUrl', 'upload_image'], null),
    'documentUrl': _first(value, ['documentUrl', 'upload_document'], null),
  };

  static Map<String, dynamic> jfmcRequest(Map<String, dynamic> value) => {
    ...value,
    'employee_name': _first(value, ['employee_name'], 'Mobile App Submission'),
    'forest_region': _first(value, ['forest_region', 'province', 'district']),
    'forest_circle': _first(value, ['forest_circle', 'division']),
    'forest_division': _first(value, ['forest_division', 'division']),
    'sub_division_range': _first(value, ['sub_division_range', 'tehsil']),
    'village_vdc': _first(value, ['village_vdc', 'committeeName']),
    'forest_type': _first(value, ['forest_type', 'province']),
    'jfmc_name': _first(value, ['jfmc_name', 'committeeName']),
    'main_intervention': _first(value, ['main_intervention', 'description']),
  };

  static Map<String, dynamic> jfmcRow(Map<String, dynamic> value) => {
    ...value,
    'committeeName': _first(value, ['committeeName', 'jfmc_name']),
    'district': _first(value, ['district', 'forest_region']),
    'division': _first(value, ['division', 'forest_division', 'forest_circle']),
    'tehsil': _first(value, ['tehsil', 'sub_division_range']),
    'province': _first(value, ['province', 'forest_type']),
    'description': _first(value, ['description', 'main_intervention']),
    'imageUrl': _first(value, ['imageUrl', 'upload_image'], null),
    'documentUrl': _first(value, ['documentUrl', 'upload_document'], null),
  };

  static Map<String, dynamic> massRequest(Map<String, dynamic> value) => {
    ...value,
    'employee_name': _first(value, ['employee_name'], 'Mobile App Submission'),
    'forest_regions': _first(value, ['forest_regions', 'province', 'district']),
    'forest_circle': _first(value, ['forest_circle', 'division']),
    'name_division': _first(value, ['name_division', 'division']),
    'sub_division_range': _first(value, ['sub_division_range', 'tehsil']),
    'projects_name': _first(value, ['projects_name', 'plantationName']),
    'institution_name': _first(value, ['institution_name', 'plantationName']),
    'location_venue': _first(value, ['location_venue', 'area', 'district']),
    'chief_guests': _first(value, ['chief_guests', 'description']),
    'total_no_plants': _first(value, ['total_no_plants', 'totalPlants']),
    'plants_name': _first(value, ['plants_name', 'species']),
    'plants_number': _first(value, ['plants_number', 'totalPlants']),
  };

  static Map<String, dynamic> massRow(Map<String, dynamic> value) => {
    ...value,
    'plantationName': _first(value, [
      'plantationName',
      'projects_name',
      'institution_name',
    ]),
    'district': _first(value, ['district', 'forest_regions']),
    'division': _first(value, ['division', 'name_division']),
    'tehsil': _first(value, ['tehsil', 'sub_division_range']),
    'province': _first(value, ['province', 'forest_circle']),
    'totalPlants': _first(value, ['totalPlants', 'total_no_plants']),
    'species': _first(value, ['species', 'plants_name']),
    'area': _first(value, ['area', 'location_venue']),
    'description': _first(value, ['description', 'chief_guests']),
    'imageUrl': _first(value, ['imageUrl', 'upload_image'], null),
    'documentUrl': _first(value, ['documentUrl', 'upload_documents'], null),
  };

  static Map<String, dynamic> awarenessRequest(Map<String, dynamic> value) => {
    ...value,
    'employee_name': _first(value, ['employee_name'], 'Mobile App Submission'),
    'forest_regions': _first(value, ['forest_regions', 'district']),
    'forest_circle': _first(value, ['forest_circle', 'division']),
    'division_name': _first(value, ['division_name', 'division']),
    'sub_division_name': _first(value, ['sub_division_name', 'tehsil']),
    'project_name': _first(value, ['project_name', 'title']),
    'types_events': _first(value, ['types_events', 'title']),
    'institution_name': _first(value, ['institution_name', 'topic']),
    'venue': _first(value, ['venue', 'district']),
    'description': _awarenessDescription(value),
  };

  static Map<String, dynamic> awarenessRow(Map<String, dynamic> value) => {
    ...value,
    'title': _first(value, ['title', 'types_events', 'project_name']),
    'topic': _first(value, ['topic', 'institution_name']),
    'district': _first(value, ['district', 'forest_regions']),
    'division': _first(value, ['division', 'division_name']),
    'tehsil': _first(value, ['tehsil', 'sub_division_name']),
    'description': _first(value, ['description']),
    'imageUrl': _first(value, ['imageUrl', 'upload_image'], null),
    'documentUrl': _first(value, ['documentUrl', 'upload_documents'], null),
    'sessionDate': _first(value, ['sessionDate', 'created_at'], null),
  };

  static Map<String, dynamic> youthRequest(Map<String, dynamic> value) => {
    ...value,
    'Employee_Name': _first(value, ['Employee_Name'], 'Mobile App Submission'),
    'Project_Name': _first(value, ['Project_Name', 'nurseryName']),
    'Division_Name': _first(value, ['Division_Name', 'division']),
    'Sub_Division_Range': _first(value, ['Sub_Division_Range', 'tehsil']),
    'VDC_WO': _first(value, ['VDC_WO', 'species']),
    'Nursery_Owner_Name': _first(value, ['Nursery_Owner_Name', 'nurseryName']),
    'Village_Name': _first(value, ['Village_Name', 'district']),
    'Limits': _first(value, ['Limits', 'totalPlants']),
    'Nursery_Owner_Full_Name': _first(value, [
      'Nursery_Owner_Full_Name',
      'description',
    ]),
    'Forest_Region': _first(value, ['Forest_Region', 'district']),
    'Forest_Circle_Name': _first(value, ['Forest_Circle_Name', 'province']),
  };

  static Map<String, dynamic> youthRow(Map<String, dynamic> value) => {
    ...value,
    'nurseryName': _first(value, [
      'nurseryName',
      'nursery_owner_name',
      'project_name',
    ]),
    'district': _first(value, ['district', 'village_name', 'forest_region']),
    'division': _first(value, ['division', 'division_name']),
    'tehsil': _first(value, ['tehsil', 'sub_division_range']),
    'province': _first(value, ['province', 'forest_circle_name']),
    'totalPlants': _first(value, ['totalPlants', 'limits_plants']),
    'species': _first(value, ['species', 'vdc_wo']),
    'description': _first(value, ['description', 'nursery_owner_full_name']),
    'imageUrl': _first(value, ['imageUrl', 'upload_image'], null),
    'documentUrl': _first(value, ['documentUrl', 'upload_file'], null),
  };

  static Map<String, dynamic> farmRequest(Map<String, dynamic> value) => {
    ...value,
    'employee_name': _first(value, [
      'employee_name',
      'ownerName',
    ], 'Mobile App Submission'),
    'forest_division': _first(value, [
      'forest_division',
      'division',
      'district',
    ]),
    'sub_division': _first(value, ['sub_division', 'tehsil']),
    'plants_distributed_today': _first(value, [
      'plants_distributed_today',
      'totalArea',
    ]),
    'major_species': _first(value, ['major_species', 'crops']),
    'total_plants_distributed': _first(value, [
      'total_plants_distributed',
      'description',
    ]),
  };

  static Map<String, dynamic> farmRow(Map<String, dynamic> value) => {
    ...value,
    'farmName': _first(value, ['farmName', 'employee_name']),
    'ownerName': _first(value, ['ownerName', 'employee_name']),
    'district': _first(value, ['district', 'forest_division']),
    'division': _first(value, ['division', 'forest_division']),
    'tehsil': _first(value, ['tehsil', 'sub_division']),
    'totalArea': _first(value, ['totalArea', 'plants_distributed_today']),
    'crops': _first(value, ['crops', 'major_species']),
    'description': _first(value, ['description', 'total_plants_distributed']),
    'imageUrl': _first(value, ['imageUrl', 'upload_image'], null),
    'documentUrl': _first(value, ['documentUrl', 'upload_file'], null),
  };

  static Map<String, dynamic> womenRequest(Map<String, dynamic> value) => {
    ...value,
    'employee_name': _first(value, ['employee_name'], 'Mobile App Submission'),
    'forest_division_name': _first(value, ['forest_division_name', 'district']),
    'forest_range': _first(value, ['forest_range', 'division']),
    'forest_region': _first(value, ['forest_region', 'province']),
    'sub_division_range': _first(value, ['sub_division_range', 'tehsil']),
    'village_name': _first(value, ['village_name', 'district']),
    'project_under_establishment': _first(value, [
      'project_under_establishment',
      'organizationName',
    ]),
    'total_members': _first(value, ['total_members', 'membersCount'], 0),
    'name_of_wo': _first(value, ['name_of_wo', 'organizationName']),
    'main_intervention': _first(value, ['main_intervention', 'description']),
  };

  static Map<String, dynamic> womenRow(Map<String, dynamic> value) => {
    ...value,
    'organizationName': _first(value, ['organizationName', 'name_of_wo']),
    'district': _first(value, ['district', 'forest_division_name']),
    'division': _first(value, ['division', 'forest_range']),
    'tehsil': _first(value, ['tehsil', 'sub_division_range']),
    'province': _first(value, ['province', 'forest_region']),
    'membersCount': _toInt(_first(value, ['membersCount', 'total_members'], 0)),
    'description': _first(value, ['description', 'main_intervention']),
    'imageUrl': _first(value, ['imageUrl', 'upload_image'], null),
    'documentUrl': _first(value, ['documentUrl', 'upload_documents'], null),
  };

  static Map<String, dynamic> otherRequest(Map<String, dynamic> value) => {
    ...value,
    'employee_name': _first(value, ['employee_name'], 'Mobile App Submission'),
    'activity_title': _first(value, ['activity_title', 'activityName']),
    'forest_division': _first(value, ['forest_division', 'district']),
    'forest_circle_name': _first(value, ['forest_circle_name', 'division']),
    'division_name': _first(value, ['division_name', 'division']),
    'subdivision_name': _first(value, ['subdivision_name', 'tehsil']),
    'project_name': _first(value, ['project_name', 'activityType']),
    'name_of_wo': _first(value, ['name_of_wo', 'activityType']),
    'village_name': _first(value, ['village_name', 'district']),
  };

  static Map<String, dynamic> otherRow(Map<String, dynamic> value) => {
    ...value,
    'activityName': _first(value, ['activityName', 'activity_title']),
    'activityType': _first(value, ['activityType', 'project_name']),
    'district': _first(value, ['district', 'forest_division']),
    'division': _first(value, ['division', 'division_name']),
    'tehsil': _first(value, ['tehsil', 'subdivision_name']),
    'imageUrl': _first(value, ['imageUrl', 'upload_image_text'], null),
    'documentUrl': _first(value, ['documentUrl', 'upload_file_text'], null),
  };

  static dynamic _first(
    Map<String, dynamic> value,
    List<String> keys, [
    dynamic fallback = '',
  ]) {
    for (final key in keys) {
      final candidate = value[key];
      if (candidate != null && candidate.toString().trim().isNotEmpty) {
        return candidate;
      }
    }
    return fallback;
  }

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  static String _awarenessDescription(Map<String, dynamic> value) {
    final description = _first(value, ['description']).toString();
    final participants = _first(value, ['participantsCount'], null);
    if (participants == null) return description;
    return '$description\nParticipants: $participants';
  }
}
