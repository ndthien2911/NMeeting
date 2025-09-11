class DocumentInMeetingInput {
  final String meetingID;
  final String personalID;
  final String accountName;
  final String documentByProgressId;

  DocumentInMeetingInput(
      {required this.meetingID,
      required this.personalID,
      required this.accountName,
      required this.documentByProgressId});

  Map toJson() => {
        'meetingID': meetingID,
        'personalID': personalID,
        'accountName': accountName,
        'documentByProgressId': documentByProgressId,
      };
}

class DocumentMeetingDetailInput {
  final String meetingID;
  final String personalID;
  final String accountName;

  DocumentMeetingDetailInput(
      {required this.meetingID,
      required this.personalID,
      required this.accountName});

  Map toJson() => {
        'meetingID': meetingID,
        'personalID': personalID,
        'accountName': accountName,
      };
}

class DocumentOutput {
  String name;
  String link;
  String regionTitle;
  bool isDownload;

  DocumentOutput(
      {required this.name,
      required this.link,
      required this.regionTitle,
      required this.isDownload});

  factory DocumentOutput.fromJson(Map<String, dynamic> json) {
    return DocumentOutput(
        name: json['name'],
        link: json['link'],
        regionTitle: json['regionTitle'],
        isDownload: json['isDownload']);
  }
  Map toJson() => {
        'name': name,
        'link': link,
        'regionTitle': regionTitle,
        'isDownload': isDownload
      };
}
