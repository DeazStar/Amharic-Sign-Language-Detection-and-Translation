
// --- Assumed definition in core/error/exceptions.dart ---
/// Custom Exception for API errors.
class ServerException implements Exception {
  final String? message;
  final int? statusCode;

  const ServerException({this.message, this.statusCode});

  @override
  String toString() {
    return 'ServerException(statusCode: $statusCode, message: $message)';
  }
}