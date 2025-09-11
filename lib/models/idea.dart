class IdeaInput {
  final String? meetingID;
  final String? personalID;
  final String? ideaID;

  IdeaInput({this.meetingID, this.personalID, this.ideaID});

  Map toJson() => {
        'meetingID': meetingID,
        'personalID': personalID,
        'ideaID': ideaID,
      };
}

class StartCheckResp {
  final bool startFlg;
  final String ideaID;
  final bool accountHasRegist;

  StartCheckResp(
      {required this.startFlg,
      required this.ideaID,
      required this.accountHasRegist});

  factory StartCheckResp.fromJson(Map<String, dynamic> json) {
    return StartCheckResp(
      startFlg: json['StartFlg'],
      ideaID: json['IdeaID'],
      accountHasRegist: json['AccountHasRegist'],
    );
  }

  Map toJson() => {
        'startFlg': startFlg,
        'ideaID': ideaID,
        'accountHasRegist': accountHasRegist,
      };
}

class SendRegistResp {
  final String id;
  final String ideaID;
  final String personalID;
  final bool approveFlg;
  final String approveAt;
  final bool endFlg;
  final String createAt;

  SendRegistResp({
    required this.id,
    required this.ideaID,
    required this.personalID,
    required this.approveFlg,
    required this.approveAt,
    required this.endFlg,
    required this.createAt,
  });

  factory SendRegistResp.fromJson(Map<String, dynamic> json) {
    return SendRegistResp(
      id: json['ID'],
      ideaID: json['IdeaID'],
      personalID: json['PersonalID'],
      approveFlg: json['ApproveFlg'],
      approveAt: json['ApproveAt'],
      endFlg: json['EndFlg'],
      createAt: json['CreateAt'],
    );
  }

  Map toJson() => {
        'id': id,
        'ideaID': ideaID,
        'personalID': personalID,
        'approveFlg': approveFlg,
        'approveAt': approveAt,
        'endFlg': endFlg,
        'createAt': createAt
      };
}

class RegistCheckResp {
  final String id;

  RegistCheckResp({required this.id});

  factory RegistCheckResp.fromJson(Map<String, dynamic> json) {
    return RegistCheckResp(id: json['ID']);
  }

  Map toJson() => {'id': id};
}
