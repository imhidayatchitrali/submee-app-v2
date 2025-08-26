// Custom exceptions
class ApiException implements Exception {
  ApiException(this.message, this.code, this.statusCode);
  final String message;
  final String code;
  final int statusCode;

  @override
  String toString() => message;
}

class TimeoutException extends ApiException {
  TimeoutException(String message, String code) : super(message, code, 408);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, String code) : super(message, code, 401);
}

class BadRequestException extends ApiException {
  BadRequestException(String message, String code) : super(message, code, 400);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message, String code) : super(message, code, 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message, String code) : super(message, code, 404);
}

class ServerException extends ApiException {
  ServerException(String message, String code) : super(message, code, 500);
}

class NoInternetException extends ApiException {
  NoInternetException(String message, String code) : super(message, code, 0);
}

class UnknownException extends ApiException {
  UnknownException(String message, String code) : super(message, code, -1);
}

class RequestCancelledException extends ApiException {
  RequestCancelledException(String message, String code) : super(message, code, -2);
}
