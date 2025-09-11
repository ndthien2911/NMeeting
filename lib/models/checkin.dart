class StartEndMeetingInput {
  final String personalID;
  final String meetingID;

  StartEndMeetingInput({required this.personalID, required this.meetingID});

  Map toJson() => {'personalID': personalID, 'meetingID': meetingID};
}

class CheckinMember {
  final String qrCode;
  final String personalID;

  CheckinMember({required this.qrCode, required this.personalID});

  Map toJson() => {
        'qrCode': qrCode,
        'personalID': personalID,
      };
}
