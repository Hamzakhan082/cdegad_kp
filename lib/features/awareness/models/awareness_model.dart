import 'dart:convert';

class AwarenessModel {
  static final Set<String> _knownKeys = {
    'id', 'title', 'topic', 'district', 'division', 'tehsil',
    'participantsCount', 'participants_count', 'description', 'imageUrl',
    'image_url', 'documentUrl', 'document_url', 'sessionDate',
    'session_date', 'createdAt', 'created_at', 'updatedAt', 'updated_at',
  };

  final dynamic id;
  final String title;
  final String topic;
  final String district;
  final String division;
  final String tehsil;
  final String participantsCount;
  final String description;
  final String? imageUrl;
  final String? documentUrl;
  final String? sessionDate;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic> extraFields;

  const AwarenessModel({
    this.id,
    this.title = '',
    this.topic = '',
    this.district = '',
    this.division = '',
    this.tehsil = '',
    this.participantsCount = '',
    this.description = '',
    this.imageUrl,
    this.documentUrl,
    this.sessionDate,
    this.createdAt,
    this.updatedAt,
    this.extraFields = const {},
  });

  factory AwarenessModel.fromJson(Map<String, dynamic> json) {
    final extra = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!_knownKeys.contains(entry.key)) {
        extra[entry.key] = entry.value;
      }
    }

    return AwarenessModel(
      id: json['id'],
      title: json['title'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      district: json['district'] as String? ?? '',
      division: json['division'] as String? ?? '',
      tehsil: json['tehsil'] as String? ?? '',
      participantsCount: json['participantsCount'] as String? ??
          json['participants_count'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      documentUrl:
          json['documentUrl'] as String? ?? json['document_url'] as String?,
      sessionDate: json['sessionDate'] as String? ??
          json['session_date'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
      extraFields: extra,
    );
  }

  static AwarenessModel fromJsonString(String jsonString) {
    return AwarenessModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'district': district,
      'division': division,
      'tehsil': tehsil,
      'participantsCount': participantsCount,
      'description': description,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'sessionDate': sessionDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      ...extraFields,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  AwarenessModel copyWith({
    dynamic id,
    String? title,
    String? topic,
    String? district,
    String? division,
    String? tehsil,
    String? participantsCount,
    String? description,
    String? imageUrl,
    String? documentUrl,
    String? sessionDate,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? extraFields,
  }) {
    return AwarenessModel(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      district: district ?? this.district,
      division: division ?? this.division,
      tehsil: tehsil ?? this.tehsil,
      participantsCount: participantsCount ?? this.participantsCount,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      sessionDate: sessionDate ?? this.sessionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      extraFields: extraFields ?? this.extraFields,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AwarenessModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
