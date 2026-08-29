import 'package:cdegad_kp/core/error/exceptions.dart';

sealed class Failure {
  const Failure();
}

class ServerFailure extends Failure {
  final String message;
  final int? statusCode;

  const ServerFailure({required this.message, this.statusCode});
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure({this.message = 'Cache error occurred'});
}

class AuthFailure extends Failure {
  final String message;

  const AuthFailure({this.message = 'Authentication error occurred'});
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure({this.message = 'Network error occurred'});
}

class FailureMapper {
  FailureMapper._();

  static Failure fromException(Exception exception) {
    return switch (exception) {
      ServerException e =>
        ServerFailure(message: e.message, statusCode: e.statusCode),
      CacheException e => CacheFailure(message: e.message),
      AuthException e => AuthFailure(message: e.message),
      NetworkException e => NetworkFailure(message: e.message),
      _ => ServerFailure(message: exception.toString()),
    };
  }
}
