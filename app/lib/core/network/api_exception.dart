/// Normalized error surfaced to the UI from the STEMWISE error envelope (spec §60).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final List<String> fieldErrors;

  ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.fieldErrors = const [],
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isNetwork => statusCode == null;

  @override
  String toString() => message;
}
