class ServiceResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  ServiceResult({
    required this.success,
    this.data,
    this.errorMessage,
  });
}
