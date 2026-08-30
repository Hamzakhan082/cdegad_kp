class WomenOrganizationModel {
  static final Set<String> _knownKeys = {
    'id',
    'organizationName',
    'organization_name',
    'district',
    'division',
    'tehsil',
    'province',
    'membersCount',
    'members_count',
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
  final String organizationName;
  final String district;
  final String division;
  final String tehsil;
  final String province;
  final int membersCount;
  final String description;
  final String? imageUrl;
  final String? documentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> extraFields;

  const WomenOrganizationModel({
    this.id,
    required this.organizationName,
    required this.district,
    required this.division,
    required this.tehsil,
    required this.province,
    required this.membersCount,
    required this.description,
    this.imageUrl,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
    this.extraFields = const {},
  });

  factory WomenOrganizationModel.fromJson(Map<String, dynamic> json) {
    final extra = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!_knownKeys.contains(entry.key)) {
        extra[entry.key] = entry.value;
      }
    }

    return WomenOrganizationModel(
      id: json['id']?.toString(),
      organizationName:
          json['organizationName'] ?? json['organization_name'] ?? '',
      district: json['district'] ?? '',
      division: json['division'] ?? '',
      tehsil: json['tehsil'] ?? '',
      province: json['province'] ?? '',
      membersCount: json['membersCount'] ?? json['members_count'] ?? 0,
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
      'organizationName': organizationName,
      'district': district,
      'division': division,
      'tehsil': tehsil,
      'province': province,
      'membersCount': membersCount,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (documentUrl != null) 'documentUrl': documentUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      ...extraFields,
    };
  }

  WomenOrganizationModel copyWith({
    String? id,
    String? organizationName,
    String? district,
    String? division,
    String? tehsil,
    String? province,
    int? membersCount,
    String? description,
    String? imageUrl,
    String? documentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? extraFields,
  }) {
    return WomenOrganizationModel(
      id: id ?? this.id,
      organizationName: organizationName ?? this.organizationName,
      district: district ?? this.district,
      division: division ?? this.division,
      tehsil: tehsil ?? this.tehsil,
      province: province ?? this.province,
      membersCount: membersCount ?? this.membersCount,
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
    return other is WomenOrganizationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
