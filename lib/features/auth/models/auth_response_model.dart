class AuthResponseModel {
  final String? token;
  final String message;
  final Map<String, dynamic>? user;

  const AuthResponseModel({
    this.token,
    required this.message,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final data = dataRaw is Map<String, dynamic>
        ? dataRaw
        : dataRaw is Map
            ? Map<String, dynamic>.from(dataRaw)
            : null;
    final userRaw = json['user'] ?? data?['user'];
    final user = userRaw is Map ? Map<String, dynamic>.from(userRaw) : null;
    return AuthResponseModel(
      token: json['token']?.toString() ?? data?['token']?.toString(),
      message: json['message']?.toString() ?? '',
      user: user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponseModel && other.token == token;
  }

  @override
  int get hashCode => token.hashCode;
}
