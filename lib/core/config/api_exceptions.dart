class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'No internet connection'});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Unauthorized access'})
      : super(statusCode: 401);
}

class ValidationException extends ApiException {
  ValidationException({required super.message})
      : super(statusCode: 400);
}