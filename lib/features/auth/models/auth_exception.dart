class AuthException implements Exception {
  final String message;
  final bool isOffline;
  final int? statusCode;

  const AuthException(
    this.message, {
    this.isOffline = false,
    this.statusCode,
  });

  @override
  String toString() => message;
}