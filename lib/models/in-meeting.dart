class InMeetingInput {
  final String personalID;
  final String meetingID;
  final String assignList;

  InMeetingInput(
      {required this.personalID,
      required this.meetingID,
      required this.assignList});

  Map toJson() => {
        'PersonalID': personalID,
        'MeetingID': meetingID,
        'AssignList': assignList
      };
}

class InMeetingOutput {
  String name;
  String adminID;
  String adminNm;
  String qrCode;
  String meetingDate;
  String address;
  String seatPosition;
  String member;
  String memberJoin;
  String meetingID;
  String meetingName;
  int memberRole;
  String startAt;
  String endAt;
  bool joinedFlg;
  int errorType;

  InMeetingOutput(
      {required this.name,
      required this.adminID,
      required this.adminNm,
      required this.qrCode,
      required this.meetingDate,
      required this.address,
      required this.seatPosition,
      required this.member,
      required this.memberJoin,
      required this.meetingID,
      required this.meetingName,
      required this.memberRole,
      required this.startAt,
      required this.endAt,
      required this.joinedFlg,
      required this.errorType});

  factory InMeetingOutput.fromJson(Map<String, dynamic> json) {
    return InMeetingOutput(
      name: json['Name'],
      adminID: json['AdminID'],
      adminNm: json['AdminNm'],
      qrCode: json['QRCode'],
      address: json['Address'],
      meetingDate: json['MeetingDate'],
      seatPosition: json['SeatPosition'],
      member: json['Member'],
      memberJoin: json['MemberJoin'],
      meetingID: json['MeetingID'],
      meetingName: json['MeetingName'],
      memberRole: json['MemberRole'],
      startAt: json['StartAt'],
      endAt: json['EndAt'],
      joinedFlg: json['JoinedFlg'],
      errorType: json['ErrorType'],
    );
  }

  Map toJson() => {
        'name': name,
        'adminID': adminID,
        'adminNm': adminNm,
        'qrCode': qrCode,
        'address': address,
        'meetingDate': meetingDate,
        'seatPosition': seatPosition,
        'member': member,
        'memberJoin': memberJoin,
        'meetingID': meetingID,
        'meetingName': meetingName,
        'memberRole': memberRole,
        'startAt': startAt,
        'endAt': endAt,
        'joinedFlg': joinedFlg,
        'errorType': errorType
      };
}
