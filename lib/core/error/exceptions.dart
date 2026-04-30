class AppException implements Exception {
  final String message;
  const AppException([this.message = 'An unexpected error occurred']);
  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class NetworkTimeoutException extends AppException {
  const NetworkTimeoutException([super.message = 'Request timed out']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Internal server error']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Forbidden']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Bad request']);
}

class ConflictException extends AppException {
  const ConflictException([super.message = 'Conflict']);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;
  const ValidationException([
    super.message = 'Validation failed',
    this.errors,
  ]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Unknown error']);
}
