import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic error;

  const Failure({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  List<Object?> get props => [message, statusCode, error];
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.error,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.error,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.error,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.error,
  });
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required super.message,
    super.statusCode,
    super.error,
  });
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    required super.message,
    super.statusCode,
    super.error,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.error,
  });
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.error,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.error,
  });
}
