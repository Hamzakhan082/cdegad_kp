import 'dart:convert';

class JfmcModel {
  static final Set<String> _knownKeys = {
    'id',
    'committeeName',
    'committee_name',
    'district',
    'division',
    'tehsil',
    'province',
    'description',
    'membersCount',
    'members_count',
    'imageUrl',
    'image_url',
    'documentUrl',
    'document_url',
    'createdAt',
    'created_at',
    'updatedAt',
    'updated_at',
  };

  final dynamic id;
  final String committeeName;
  final String district;
  final String division;
  final String tehsil;
  final String province;
  final String description;
  final int? membersCount;
  final String? imageUrl;
  final String? documentUrl;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic> extraFields;

  const JfmcModel({
    this.id,
    this.committeeName = '',
    this.district = '',
    this.division = '',
    this.tehsil = '',
    this.province = '',
    this.description = '',
    this.membersCount,
    this.imageUrl,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
    this.extraFields = const {},
  });

  factory JfmcModel.fromJson(Map<String, dynamic> json) {
    final extra = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!_knownKeys.contains(entry.key)) {
        extra[entry.key] = entry.value;
      }
    }

    return JfmcModel(
      id: json['id'],
      committeeName:
          json['committeeName'] as String? ??
          json['committee_name'] as String? ??
          '',
      district: json['district'] as String? ?? '',
      division: json['division'] as String? ?? '',
      tehsil: json['tehsil'] as String? ?? '',
      province: json['province'] as String? ?? '',
      description: json['description'] as String? ?? '',
      membersCount:
          json['membersCount'] as int? ?? json['members_count'] as int?,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      documentUrl:
          json['documentUrl'] as String? ?? json['document_url'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
      extraFields: extra,
    );
  }

  static JfmcModel fromJsonString(String jsonString) {
    return JfmcModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'committeeName': committeeName,
      'district': district,
      'division': division,
      'tehsil': tehsil,
      'province': province,
      'description': description,
      'membersCount': membersCount,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      ...extraFields,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  JfmcModel copyWith({
    dynamic id,
    String? committeeName,
    String? district,
    String? division,
    String? tehsil,
    String? province,
    String? description,
    int? membersCount,
    String? imageUrl,
    String? documentUrl,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? extraFields,
  }) {
    return JfmcModel(
      id: id ?? this.id,
      committeeName: committeeName ?? this.committeeName,
      district: district ?? this.district,
      division: division ?? this.division,
      tehsil: tehsil ?? this.tehsil,
      province: province ?? this.province,
      description: description ?? this.description,
      membersCount: membersCount ?? this.membersCount,
      imageUrl: imageUrl ?? this.imageUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      extraFields: extraFields ?? this.extraFields,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JfmcModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
