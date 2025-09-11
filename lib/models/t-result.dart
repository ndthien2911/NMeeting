class TResult {
  final int status;
  final dynamic data;
  final String msg;

  TResult({
    required this.status,
    this.data,
    required this.msg,
  });
}
