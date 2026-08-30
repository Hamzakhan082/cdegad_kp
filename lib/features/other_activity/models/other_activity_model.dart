class OtherActivityModel {
  static final Set<String> _knownKeys = {
    'id',
    'activityName',
    'activity_name',
    'activityType',
    'activity_type',
    'district',
    'division',
    'tehsil',
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

  final String? id;
  final String activityName;
  final String activityType;
  final String district;
  final String division;
  final String tehsil;
  final String description;
  final String? imageUrl;
  final String? documentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> extraFields;

  const OtherActivityModel({
    this.id,
    required this.activityName,
    required this.activityType,
    required this.district,
    required this.division,
    required this.tehsil,
    required this.description,
    this.imageUrl,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
    this.extraFields = const {},
  });

  factory OtherActivityModel.fromJson(Map<String, dynamic> json) {
    final extra = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!_knownKeys.contains(entry.key)) {
        extra[entry.key] = entry.value;
      }
    }

    return OtherActivityModel(
      id: json['id']?.toString(),
      activityName: json['activityName'] ?? json['activity_name'] ?? '',
      activityType: json['activityType'] ?? json['activity_type'] ?? '',
      district: json['district'] ?? '',
      division: json['division'] ?? '',
      tehsil: json['tehsil'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      documentUrl: json['documentUrl'] ?? json['document_url'],
      createdAt: (json['createdAt'] ?? json['created_at']) != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at'])
          : null,
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null
          ? DateTime.tryParse(json['updatedAt'] ?? json['updated_at'])
          : null,
      extraFields: extra,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'activityName': activityName,
      'activityType': activityType,
      'district': district,
      'division': division,
      'tehsil': tehsil,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (documentUrl != null) 'documentUrl': documentUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      ...extraFields,
    };
  }

  OtherActivityModel copyWith({
    String? id,
    String? activityName,
    String? activityType,
    String? district,
    String? division,
    String? tehsil,
    String? description,
    String? imageUrl,
    String? documentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? extraFields,
  }) {
    return OtherActivityModel(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      activityType: activityType ?? this.activityType,
      district: district ?? this.district,
      division: division ?? this.division,
      tehsil: tehsil ?? this.tehsil,
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
    return other is OtherActivityModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
