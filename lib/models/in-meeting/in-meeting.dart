class InMeetingInput {
  final String? unitID;
  final String? personalID;
  final String? meetingID;
  final String? assignList;

  InMeetingInput({
    this.unitID,
    this.personalID,
    this.meetingID,
    this.assignList,
  });

  Map<String, dynamic> toJson() => {
        'UnitID': unitID,
        'PersonalID': personalID,
        'MeetingID': meetingID,
        'AssignList': assignList,
      };
}

class AssignMeetingInput {
  final String? personalID;
  final String? meetingID;
  final String? assignList;

  AssignMeetingInput({
    this.personalID,
    this.meetingID,
    this.assignList,
  });

  Map<String, dynamic> toJson() => {
        'PersonalID': personalID,
        'MeetingID': meetingID,
        'AssignList': assignList,
      };
}

class UserMeetingInput {
  final String? personalID;
  final String? unitID;
  final String? searchTxt;
  final String? meetingID;
  final String? adminList;

  UserMeetingInput({
    this.personalID,
    this.unitID,
    this.searchTxt,
    this.meetingID,
    this.adminList,
  });

  Map<String, dynamic> toJson() => {
        'PersonalID': personalID,
        'UnitID': unitID,
        'SearchTxt': searchTxt,
        'MeetingID': meetingID,
        'AdminList': adminList,
      };
}

class InMeetingOutput {
  String? name;
  String? content;
  String? adminID;
  String? adminNm;
  String? qrCode;
  String? meetingDate;
  String? address;
  String? seatPosition;
  String? member;
  String? memberJoin;
  String? meetingID;
  String? meetingName;
  int? memberRole;
  String? startAt;
  String? endAt;
  bool? joinedFlg;
  List<FileOutput>? files;
  int? errorType;
  bool? approveFlg;
  String? element;
  String? note;
  String? equipment;
  String? guest;
  bool? personalFlg;
  String? meetingEndDate;
  bool? cancelApproved;
  int? groupID;

  InMeetingOutput({
    this.name,
    this.content,
    this.adminID,
    this.adminNm,
    this.qrCode,
    this.meetingDate,
    this.address,
    this.seatPosition,
    this.member,
    this.memberJoin,
    this.meetingID,
    this.meetingName,
    this.memberRole,
    this.startAt,
    this.endAt,
    this.joinedFlg,
    this.files,
    this.errorType,
    this.approveFlg,
    this.element,
    this.guest,
    this.note,
    this.equipment,
    this.personalFlg,
    this.meetingEndDate,
    this.cancelApproved,
    this.groupID,
  });

  factory InMeetingOutput.fromJson(Map<String, dynamic> json) {
    return InMeetingOutput(
      name: json['Name'] as String?,
      content: json['Content'] as String?,
      adminID: json['AdminID'] as String?,
      adminNm: json['AdminNm'] as String?,
      qrCode: json['QRCode'] as String?,
      address: json['Address'] as String?,
      meetingDate: json['MeetingDate'] as String?,
      seatPosition: json['SeatPosition'] as String?,
      member: json['Member'] as String?,
      memberJoin: json['MemberJoin'] as String?,
      meetingID: json['MeetingID'] as String?,
      meetingName: json['MeetingName'] as String?,
      memberRole: json['MemberRole'] as int?,
      startAt: json['StartAt'] as String?,
      endAt: json['EndAt'] as String?,
      joinedFlg: json['JoinedFlg'] as bool?,
      files: (json['FileAtract'] as List<dynamic>?)
          ?.map((e) => FileOutput.fromJson(e as Map<String, dynamic>))
          .toList(),
      errorType: json['ErrorType'] as int?,
      approveFlg: json['ApproveFlg'] as bool?,
      element: json['Element'] as String?,
      guest: json['Guest'] as String?,
      note: json['Note'] as String?,
      equipment: json['Equipment'] as String?,
      personalFlg: json['PersonalFlg'] as bool?,
      meetingEndDate: json['MeetingEndDate'] as String?,
      cancelApproved: json['CancelApproved'] as bool?,
      groupID: json['GroupID'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
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
        'files': files?.map((e) => e.toJson()).toList(),
        'errorType': errorType,
        'approveFlg': approveFlg,
        'element': element,
        'guest': guest,
        'note': note,
        'equipment': equipment,
        'personalFlg': personalFlg,
        'meetingEndDate': meetingEndDate,
        'cancelApproved': cancelApproved,
        'groupID': groupID,
      };
}

class FileOutput {
  String? name;
  String? id;
  String? documentUrl;
  String? dirDocumentUrl;
  bool? downloadFlg;

  FileOutput({
    this.name,
    this.id,
    this.documentUrl,
    this.dirDocumentUrl,
    this.downloadFlg,
  });

  factory FileOutput.fromJson(Map<String, dynamic> json) {
    return FileOutput(
      name: json['Name'] as String?,
      id: json['ID'] as String?,
      documentUrl: json['DocumentUrl'] as String?,
      dirDocumentUrl: json['DirDocumentUrl'] as String?,
      downloadFlg: json['DownloadFlg'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'documentUrl': documentUrl,
        'dirDocumentUrl': dirDocumentUrl,
        'downloadFlg': downloadFlg,
      };
}

class MemberRoleInput {
  final String? personalID;
  final String? meetingID;

  MemberRoleInput({
    this.personalID,
    this.meetingID,
  });

  Map<String, dynamic> toJson() =>
      {'PersonalID': personalID, 'MeetingID': meetingID};
}

class MeetingReadyOutput {
  final String? id;
  final String? name;
  final String? admin;
  final String? address;
  final String? meetingDate;
  final String? meetingEndDate;
  final String? startAt;
  final String? endAt;
  final int? approveFlg;
  final String? approveBy;
  final String? approveAt;
  final String? createAt;
  final String? createBy;
  final String? delFlg;
  final String? delAt;
  final String? delBy;
  final bool? endFlg;
  final bool? startFlg;
  final String? startAtByQRScan;
  final String? endAtByQRScan;
  final String? element;
  final int? type;
  final bool? publicFlg;
  final String? memberList;
  final String? adminList;

  MeetingReadyOutput({
    this.id,
    this.name,
    this.admin,
    this.address,
    this.meetingDate,
    this.meetingEndDate,
    this.startAt,
    this.endAt,
    this.approveFlg,
    this.approveBy,
    this.approveAt,
    this.createAt,
    this.createBy,
    this.delFlg,
    this.delAt,
    this.delBy,
    this.endFlg,
    this.startFlg,
    this.startAtByQRScan,
    this.endAtByQRScan,
    this.element,
    this.type,
    this.adminList,
    this.memberList,
    this.publicFlg,
  });

  factory MeetingReadyOutput.fromJson(Map<String, dynamic> json) {
    return MeetingReadyOutput(
      id: json['ID'] as String?,
      name: json['Name'] as String?,
      admin: json['Admin'] as String?,
      address: json['Address'] as String?,
      meetingDate: json['MeetingDate'] as String?,
      meetingEndDate: json['MeetingEndDate'] as String?,
      startAt: json['StartAt'] as String?,
      endAt: json['EndAt'] as String?,
      approveFlg: json['ApproveFlg'] as int?,
      approveBy: json['ApproveBy'] as String?,
      approveAt: json['ApproveAt'] as String?,
      createAt: json['CreateAt'] as String?,
      createBy: json['CreateBy'] as String?,
      delFlg: json['DelFlg'] as String?,
      delAt: json['DelAt'] as String?,
      delBy: json['DelBy'] as String?,
      endFlg: json['EndFlg'] as bool?,
      startFlg: json['StartFlg'] as bool?,
      startAtByQRScan: json['StartAtByQRScan'] as String?,
      endAtByQRScan: json['EndAtByQRScan'] as String?,
      element: json['Element'] as String?,
      type: json['Type'] as int?,
      publicFlg: json['PublicFlg'] as bool?,
      memberList: json['MemberList'] as String?,
      adminList: json['AdminList'] as String?,
    );
  }
}
