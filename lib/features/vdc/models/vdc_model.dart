import 'dart:convert';

class VdcModel {
  static final Set<String> _knownKeys = {
    'id',
    'villageName',
    'village_name',
    'district',
    'division',
    'tehsil',
    'province',
    'description',
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
  final String villageName;
  final String district;
  final String division;
  final String tehsil;
  final String province;
  final String description;
  final String? imageUrl;
  final String? documentUrl;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic> extraFields;

  const VdcModel({
    this.id,
    this.villageName = '',
    this.district = '',
    this.division = '',
    this.tehsil = '',
    this.province = '',
    this.description = '',
    this.imageUrl,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
    this.extraFields = const {},
  });

  factory VdcModel.fromJson(Map<String, dynamic> json) {
    final extra = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!_knownKeys.contains(entry.key)) {
        extra[entry.key] = entry.value;
      }
    }

    return VdcModel(
      id: json['id'],
      villageName:
          json['villageName'] as String? ??
          json['village_name'] as String? ??
          '',
      district: json['district'] as String? ?? '',
      division: json['division'] as String? ?? '',
      tehsil: json['tehsil'] as String? ?? '',
      province: json['province'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      documentUrl:
          json['documentUrl'] as String? ?? json['document_url'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
      extraFields: extra,
    );
  }

  static VdcModel fromJsonString(String jsonString) {
    return VdcModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'villageName': villageName,
      'district': district,
      'division': division,
      'tehsil': tehsil,
      'province': province,
      'description': description,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      ...extraFields,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  VdcModel copyWith({
    dynamic id,
    String? villageName,
    String? district,
    String? division,
    String? tehsil,
    String? province,
    String? description,
    String? imageUrl,
    String? documentUrl,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? extraFields,
  }) {
    return VdcModel(
      id: id ?? this.id,
      villageName: villageName ?? this.villageName,
      district: district ?? this.district,
      division: division ?? this.division,
      tehsil: tehsil ?? this.tehsil,
      province: province ?? this.province,
      description: description ?? this.description,
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
    return other is VdcModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
