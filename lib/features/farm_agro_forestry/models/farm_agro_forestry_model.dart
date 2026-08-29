class FarmAgroForestryModel {
  static final Set<String> _knownKeys = {
    'id', 'farmName', 'farm_name', 'ownerName', 'owner_name', 'district',
    'division', 'tehsil', 'province', 'totalArea', 'total_area', 'crops',
    'description', 'imageUrl', 'image_url', 'documentUrl', 'document_url',
    'createdAt', 'created_at', 'updatedAt', 'updated_at',
  };

  final dynamic id;
  final String farmName;
  final String ownerName;
  final String district;
  final String division;
  final String tehsil;
  final String province;
  final String totalArea;
  final String crops;
  final String description;
  final String? imageUrl;
  final String? documentUrl;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic> extraFields;

  const FarmAgroForestryModel({
    this.id,
    this.farmName = '',
    this.ownerName = '',
    this.district = '',
    this.division = '',
    this.tehsil = '',
    this.province = '',
    this.totalArea = '',
    this.crops = '',
    this.description = '',
    this.imageUrl,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
    this.extraFields = const {},
  });

  factory FarmAgroForestryModel.fromJson(Map<String, dynamic> json) {
    final extra = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!_knownKeys.contains(entry.key)) {
        extra[entry.key] = entry.value;
      }
    }

    return FarmAgroForestryModel(
      id: json['id'],
      farmName: json['farmName'] as String? ??
          json['farm_name'] as String? ??
          '',
      ownerName: json['ownerName'] as String? ??
          json['owner_name'] as String? ??
          '',
      district: json['district'] as String? ?? '',
      division: json['division'] as String? ?? '',
      tehsil: json['tehsil'] as String? ?? '',
      province: json['province'] as String? ?? '',
      totalArea: json['totalArea'] as String? ??
          json['total_area'] as String? ??
          '',
      crops: json['crops'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      documentUrl:
          json['documentUrl'] as String? ?? json['document_url'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
      extraFields: extra,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmName': farmName,
      'ownerName': ownerName,
      'district': district,
      'division': division,
      'tehsil': tehsil,
      'province': province,
      'totalArea': totalArea,
      'crops': crops,
      'description': description,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      ...extraFields,
    };
  }

  FarmAgroForestryModel copyWith({
    dynamic id,
    String? farmName,
    String? ownerName,
    String? district,
    String? division,
    String? tehsil,
    String? province,
    String? totalArea,
    String? crops,
    String? description,
    String? imageUrl,
    String? documentUrl,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? extraFields,
  }) {
    return FarmAgroForestryModel(
      id: id ?? this.id,
      farmName: farmName ?? this.farmName,
      ownerName: ownerName ?? this.ownerName,
      district: district ?? this.district,
      division: division ?? this.division,
      tehsil: tehsil ?? this.tehsil,
      province: province ?? this.province,
      totalArea: totalArea ?? this.totalArea,
      crops: crops ?? this.crops,
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
    return other is FarmAgroForestryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
