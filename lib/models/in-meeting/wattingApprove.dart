import 'package:nmeeting/configs/constants.dart' as constants;

class DataInput {
  final int statusVal;
  final String pageID;
  final int weekSelectedValue;

  DataInput(
      {required this.statusVal,
      required this.pageID,
      required this.weekSelectedValue});

  Map toJson() => {
        'StatusVal': statusVal,
        'PageID': pageID,
        'WeekSelectedValue': weekSelectedValue
      };
}

class ChangeModeInput {
  final String idList;
  final int modeVal;
  final int statusVal;

  ChangeModeInput(
      {required this.idList, required this.modeVal, required this.statusVal});

  Map toJson() =>
      {'IDList': idList, 'ModeVal': modeVal, 'StatusVal': statusVal};
}

class ProgressActiveInput {
  final String id;
  final String personalID;
  final bool activeFlg;

  ProgressActiveInput(
      {required this.id, required this.personalID, required this.activeFlg});

  Map toJson() => {'ID': id, 'PersonalID': personalID, 'ActiveFlg': activeFlg};
}

class MeetingObj {
  String id;
  String name;
  String startAt;
  String endAt;
  String meetingDate;
  bool selectFlg;
  String approveAt;
  int approveFlg;
  bool createByMeFlg;
  String adminNmList;
  String memberNmList;
  String address;
  bool titleDtFlg;
  bool hiddenRejectFlg;
  bool modifyFlg;
  bool cancelApproved;
  bool insertFlg;
  String guest;
  String note;
  String meetingEndDate;

  MeetingObj(
      {required this.id,
      required this.name,
      required this.startAt,
      required this.endAt,
      required this.meetingDate,
      required this.selectFlg,
      required this.approveAt,
      required this.approveFlg,
      required this.createByMeFlg,
      required this.adminNmList,
      required this.memberNmList,
      required this.address,
      required this.titleDtFlg,
      required this.hiddenRejectFlg,
      required this.modifyFlg,
      required this.cancelApproved,
      required this.insertFlg,
      required this.guest,
      required this.note,
      required this.meetingEndDate});

  factory MeetingObj.fromJson(Map<String, dynamic> json) {
    var _cancelApproved = json['ApproveAt'] != null &&
        json['ApproveAt'] != "" &&
        json['ApproveFlg'] ==
            constants.STATUS_MEETING_WAITING; // || json['ApproveFlg'] == 1;

    var _createDate = DateTime.parse(json['CreateDate']);
    //T2 1
    var _insertFlg = _createDate.weekday == 1 ||
        _createDate.weekday == 2 ||
        _createDate.weekday == 3;

    return MeetingObj(
        id: json['ID'],
        name: json['Name'],
        startAt: json['StartAt'],
        endAt: json['EndAt'],
        meetingDate: json['MeetingDate'],
        selectFlg: json['SelectFlg'],
        approveAt: json['ApproveAt'],
        approveFlg: json['ApproveFlg'],
        createByMeFlg: json['CreateByMeFlg'],
        adminNmList: json['AdminNmList'],
        memberNmList: json['MemberNmList'],
        address: json['Address'],
        titleDtFlg: json['TitleDtFlg'],
        hiddenRejectFlg: json['HiddenRejectFlg'],
        modifyFlg: json['ModifyFlg'],
        cancelApproved: _cancelApproved,
        insertFlg: _insertFlg,
        guest: json['Guest'],
        note: json['Note'],
        meetingEndDate: json['MeetingEndDate']);
  }
  Map toJson() => {
        'id': id,
        'name': name,
        'startAt': startAt,
        'endAt': endAt,
        'meetingDate': meetingDate,
        'selectFlg': selectFlg,
        'approveAt': approveAt,
        'approveFlg': approveFlg,
        'createByMeFlg': createByMeFlg,
        'adminNmList': adminNmList,
        'memberNmList': memberNmList,
        'address': address,
        'titleDtFlg': titleDtFlg,
        'hiddenRejectFlg': hiddenRejectFlg,
        'modifyFlg': modifyFlg,
        'cancelApproved': cancelApproved,
        'insertFlg': insertFlg,
        'guest': guest,
        'note': note,
        'meetingEndDate': meetingEndDate
      };
}

class DeleteInput {
  final String idList;

  DeleteInput({required this.idList});

  Map toJson() => {'IDList': idList};
}

class RejectInput {
  final String idList;
  final String personalID;

  RejectInput({required this.idList, required this.personalID});

  Map toJson() => {'IDList': idList, 'PersonalID': personalID};
}
