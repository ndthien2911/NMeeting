class VersionOutput {
  final String appVersion;
  final String url;

  VersionOutput({required this.appVersion, required this.url});
  Map toJson() => {'appVersion': appVersion, 'url': url};
}
