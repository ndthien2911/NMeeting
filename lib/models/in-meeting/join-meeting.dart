import './in-meeting.dart';

class JoinMeetingOutput {
  int code;
  String? title;
  String? msg;
  int? status;
  InMeetingOutput? data;

  JoinMeetingOutput(
      {required this.code, this.title, this.msg, this.data, this.status});

  factory JoinMeetingOutput.fromJson(Map<String, dynamic> json) {
    return JoinMeetingOutput(
        code: json['Code'],
        title: json['Title'],
        msg: json['Msg'],
        data: json['Data'],
        status: json['Status']);
  }

  Map toJson() =>
      {'name': code, 'adminID': title, 'adminNm': data, 'status': status};
}
