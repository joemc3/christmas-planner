class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  const ServerException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  final dynamic error;

  const CacheException({
    required this.message,
    this.error,
  });

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  final dynamic error;

  const NetworkException({
    required this.message,
    this.error,
  });

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  const ValidationException({
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  const AuthenticationException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() => 'AuthenticationException: $message';
}

class AuthorizationException implements Exception {
  final String message;
  final int? statusCode;

  const AuthorizationException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'AuthorizationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  final String? resourceType;
  final String? resourceId;

  const NotFoundException({
    required this.message,
    this.resourceType,
    this.resourceId,
  });

  @override
  String toString() => 'NotFoundException: $message ($resourceType: $resourceId)';
}

class DatabaseException implements Exception {
  final String message;
  final dynamic error;

  const DatabaseException({
    required this.message,
    this.error,
  });

  @override
  String toString() => 'DatabaseException: $message';
}
