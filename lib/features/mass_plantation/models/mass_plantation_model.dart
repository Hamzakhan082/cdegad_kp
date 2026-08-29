import 'dart:convert';

class MassPlantationModel {
  static final Set<String> _knownKeys = {
    'id', 'plantationName', 'plantation_name', 'district', 'division',
    'tehsil', 'province', 'totalPlants', 'total_plants', 'species',
    'area', 'description', 'imageUrl', 'image_url', 'documentUrl',
    'document_url', 'createdAt', 'created_at', 'updatedAt', 'updated_at',
  };

  final dynamic id;
  final String plantationName;
  final String district;
  final String division;
  final String tehsil;
  final String province;
  final String totalPlants;
  final String species;
  final String area;
  final String description;
  final String? imageUrl;
  final String? documentUrl;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic> extraFields;

  const MassPlantationModel({
    this.id,
    this.plantationName = '',
    this.district = '',
    this.division = '',
    this.tehsil = '',
    this.province = '',
    this.totalPlants = '',
    this.species = '',
    this.area = '',
    this.description = '',
    this.imageUrl,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
    this.extraFields = const {},
  });

  factory MassPlantationModel.fromJson(Map<String, dynamic> json) {
    final extra = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!_knownKeys.contains(entry.key)) {
        extra[entry.key] = entry.value;
      }
    }

    return MassPlantationModel(
      id: json['id'],
      plantationName: json['plantationName'] as String? ??
          json['plantation_name'] as String? ?? '',
      district: json['district'] as String? ?? '',
      division: json['division'] as String? ?? '',
      tehsil: json['tehsil'] as String? ?? '',
      province: json['province'] as String? ?? '',
      totalPlants: json['totalPlants'] as String? ??
          json['total_plants'] as String? ?? '',
      species: json['species'] as String? ?? '',
      area: json['area'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      documentUrl:
          json['documentUrl'] as String? ?? json['document_url'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
      extraFields: extra,
    );
  }

  static MassPlantationModel fromJsonString(String jsonString) {
    return MassPlantationModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantationName': plantationName,
      'district': district,
      'division': division,
      'tehsil': tehsil,
      'province': province,
      'totalPlants': totalPlants,
      'species': species,
      'area': area,
      'description': description,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      ...extraFields,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  MassPlantationModel copyWith({
    dynamic id,
    String? plantationName,
    String? district,
    String? division,
    String? tehsil,
    String? province,
    String? totalPlants,
    String? species,
    String? area,
    String? description,
    String? imageUrl,
    String? documentUrl,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? extraFields,
  }) {
    return MassPlantationModel(
      id: id ?? this.id,
      plantationName: plantationName ?? this.plantationName,
      district: district ?? this.district,
      division: division ?? this.division,
      tehsil: tehsil ?? this.tehsil,
      province: province ?? this.province,
      totalPlants: totalPlants ?? this.totalPlants,
      species: species ?? this.species,
      area: area ?? this.area,
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
    return other is MassPlantationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
