class MeetingInput {
  final String personalID;
  final String meetingDate;

  MeetingInput({required this.personalID, required this.meetingDate});

  Map toJson() => {
        'personalID': personalID,
        'meetingDate': meetingDate,
      };
}

class MeetingOutput {
  String id;
  String name;
  String admin;
  String adminName;
  String address;
  String meetingDate;
  String startAt;
  String endAt;
  bool startFlg;
  bool endFlg;

  MeetingOutput(
      {required this.id,
      required this.name,
      required this.admin,
      required this.adminName,
      required this.address,
      required this.meetingDate,
      required this.startAt,
      required this.endAt,
      required this.startFlg,
      required this.endFlg});

  factory MeetingOutput.fromJson(Map<String, dynamic> json) {
    return MeetingOutput(
      id: json['ID'],
      name: json['Name'],
      admin: json['Admin'],
      adminName: json['AdminName'],
      address: json['Address'],
      meetingDate: json['MeetingDate'],
      startAt: json['StartAt'],
      endAt: json['EndAt'],
      startFlg: json['StartFlg'],
      endFlg: json['EndFlg'],
    );
  }
  Map toJson() => {
        'id': id,
        'name': name,
        'admin': admin,
        'adminName': adminName,
        'address': address,
        'meetingDate': meetingDate,
        'startAt': startAt,
        'endAt': endAt,
        'startFlg': startFlg,
        'endFlg': endFlg,
      };
}

class MeetingEventOutput {
  String meetingDate;
  List<String> meetingIds;

  MeetingEventOutput({required this.meetingDate, required this.meetingIds});

  factory MeetingEventOutput.fromJson(Map<String, dynamic> json) {
    return MeetingEventOutput(
        meetingDate: json['MeetingDate'],
        meetingIds: json["MeetingIds"].cast<String>());
  }
  Map toJson() => {'meetingDate': meetingDate, 'meetingIds': meetingIds};
}

class QRScanInput {
  final String qrCode;
  final String personalID;

  QRScanInput({required this.qrCode, required this.personalID});

  Map toJson() => {
        'qrCode': qrCode,
        'personalID': personalID,
      };
}

class QRCheckedInput {
  final String qrCode;

  QRCheckedInput({required this.qrCode});

  Map toJson() => {'qrCode': qrCode};
}

class CheckInInput {
  final String meetingID;
  final String personalID;

  CheckInInput({required this.meetingID, required this.personalID});

  Map toJson() => {
        'meetingID': meetingID,
        'personalID': personalID,
      };
}

class MeetingEndInput {
  final String meetingID;
  MeetingEndInput({required this.meetingID});

  Map toJson() => {
        'meetingID': meetingID,
      };
}

class AccountOut {
  String id;
  String personalID;
  String name;
  String avatar;
  int type;
  bool selected;

  AccountOut(
      {required this.id,
      required this.personalID,
      required this.name,
      required this.avatar,
      required this.type,
      required this.selected});

  factory AccountOut.fromJson(Map<String, dynamic> json) {
    return AccountOut(
        id: json['ID'],
        personalID: json['PersonalID'],
        name: json['Name'],
        avatar: json['AvatarUrl'],
        type: json['Type'],
        selected: json['Selected']);
  }

  AccountOut.clone(AccountOut source)
      : this.id = source.id,
        this.personalID = source.personalID,
        this.name = source.name,
        this.avatar = source.avatar,
        this.type = source.type,
        this.selected = source.selected;

  Map toJson() => {
        'ID': id,
        'PersonalID': personalID,
        'Name': name,
        'AvatarUrl': avatar,
        'Type': type,
        'Selected': selected
      };
}

class RoleInput {
  String? roleID;
  String pageID;
  String? pageNm;
  String? controlStr;

  RoleInput({this.roleID, required this.pageID, this.pageNm, this.controlStr});

  Map toJson() => {
        'RoleID': roleID,
        'PageID': pageID,
        'PageNm': pageNm,
        'ControlStr': controlStr,
      };
}

class MeetingObjInput {
  String? id;
  String name;
  String unitList;
  String admin;
  String? adminList;
  String adminListObj;
  String roomMeetingList;
  String memberList;
  String memberListObj;
  String meetingDate;
  String startAt;
  String endAt;
  String address;
  String centralContent;
  String fileUrl;
  String unitNmList;
  String adminNmList;
  String roomNmList;
  String memberNmList;
  String fileNmList;
  bool publicFlg;
  String element;
  String note;
  String guest;
  String meetingEndDate;

  MeetingObjInput(
      {this.id,
      required this.name,
      required this.unitList,
      required this.admin,
      this.adminList,
      required this.adminListObj,
      required this.roomMeetingList,
      required this.memberList,
      required this.memberListObj,
      required this.meetingDate,
      required this.startAt,
      required this.endAt,
      required this.address,
      required this.centralContent,
      required this.fileUrl,
      required this.unitNmList,
      required this.adminNmList,
      required this.roomNmList,
      required this.memberNmList,
      required this.fileNmList,
      required this.publicFlg,
      required this.element,
      required this.note,
      required this.guest,
      required this.meetingEndDate});

  factory MeetingObjInput.fromJson(Map<String, dynamic> json) {
    return MeetingObjInput(
        id: json['ID'],
        name: json['Name'],
        unitList: json['UnitList'],
        admin: json['Admin'],
        adminList: json['AdminList'],
        adminListObj: json['AdminListObj'],
        roomMeetingList: json['RoomMeetingList'],
        memberList: json['MemberList'],
        memberListObj: json['MemberListObj'],
        meetingDate: json['MeetingDate'],
        startAt: json['StartAt'],
        endAt: json['EndAt'],
        address: json['Address'],
        centralContent: json['CentralContent'],
        fileUrl: json['FileUrl'],
        unitNmList: json['UnitNmList'],
        adminNmList: json['AdminNmList'],
        roomNmList: json['RoomNmList'],
        memberNmList: json['MemberNmList'],
        fileNmList: json['FileNmList'],
        publicFlg: json['PublicFlg'],
        element: json['Element'],
        note: json['Note'],
        guest: json['Guest'],
        meetingEndDate: json['MeetingEndDate']);
  }

  Map toJson() => {
        'Id': id,
        'Name': name,
        'UnitList': unitList,
        'Admin': admin,
        'AdminList': adminList,
        'AdminListObj': adminListObj,
        'RoomMeetingList': roomMeetingList,
        'MemberList': memberList,
        'MemberListObj': memberListObj,
        'MeetingDate': meetingDate,
        'StartAt': startAt,
        'EndAt': endAt,
        'Address': address,
        'CentralContent': centralContent,
        'FileUrl': fileUrl,
        'UnitNmList': unitNmList,
        'AdminNmList': adminNmList,
        'RoomNmList': roomNmList,
        'MemberNmList': memberNmList,
        'FileNmList': fileNmList,
        'PublicFlg': publicFlg,
        'Element': element,
        'Note': note,
        'Guest': guest,
        'MeetingEndDate': meetingEndDate
      };
}

class MeetingObjRequest {
  MeetingObjInput meeting;
  String typeRequest;

  MeetingObjRequest({required this.meeting, required this.typeRequest});

  factory MeetingObjRequest.fromJson(Map<String, dynamic> json) {
    return MeetingObjRequest(
        meeting: json['Meeting'], typeRequest: json["TypeRequest"]);
  }
  Map toJson() => {'Meeting': meeting, 'TypeRequest': typeRequest};
}
