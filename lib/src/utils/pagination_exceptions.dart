/// Custom exception for pagination errors.
class PaginationException implements Exception {
  final String message;

  PaginationException(this.message);

  @override
  String toString() => 'PaginationException: $message';
}
