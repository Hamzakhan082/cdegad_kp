class YouthWomenNurseryModel {
  final dynamic id;
  final String nurseryName;
  final String district;
  final String division;
  final String tehsil;
  final String province;
  final String totalPlants;
  final String species;
  final String description;
  final String? imageUrl;
  final String? documentUrl;
  final String? createdAt;
  final String? updatedAt;

  const YouthWomenNurseryModel({
    this.id,
    this.nurseryName = '',
    this.district = '',
    this.division = '',
    this.tehsil = '',
    this.province = '',
    this.totalPlants = '',
    this.species = '',
    this.description = '',
    this.imageUrl,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory YouthWomenNurseryModel.fromJson(Map<String, dynamic> json) {
    return YouthWomenNurseryModel(
      id: json['id'],
      nurseryName:
          json['nurseryName'] as String? ??
          json['nursery_name'] as String? ??
          '',
      district: json['district'] as String? ?? '',
      division: json['division'] as String? ?? '',
      tehsil: json['tehsil'] as String? ?? '',
      province: json['province'] as String? ?? '',
      totalPlants:
          json['totalPlants'] as String? ??
          json['total_plants'] as String? ??
          '',
      species: json['species'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      documentUrl:
          json['documentUrl'] as String? ?? json['document_url'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nurseryName': nurseryName,
      'district': district,
      'division': division,
      'tehsil': tehsil,
      'province': province,
      'totalPlants': totalPlants,
      'species': species,
      'description': description,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  YouthWomenNurseryModel copyWith({
    dynamic id,
    String? nurseryName,
    String? district,
    String? division,
    String? tehsil,
    String? province,
    String? totalPlants,
    String? species,
    String? description,
    String? imageUrl,
    String? documentUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return YouthWomenNurseryModel(
      id: id ?? this.id,
      nurseryName: nurseryName ?? this.nurseryName,
      district: district ?? this.district,
      division: division ?? this.division,
      tehsil: tehsil ?? this.tehsil,
      province: province ?? this.province,
      totalPlants: totalPlants ?? this.totalPlants,
      species: species ?? this.species,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YouthWomenNurseryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
