import 'dart:convert';
import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/in-meeting/in-meeting.dart';
import 'package:nmeeting/models/in-meeting/user-meeting.dart';
import 'package:nmeeting/models/meeting.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:web_socket_channel/io.dart';

class MeetingRepository {
  final _provider = ApiProvider();

  Future<TResult> qrCheckedFlg(QRCheckedInput data) async {
    final response =
        await _provider.post(api.URL_MEETING_QR_CHECKED_FLG, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> checkUserHasCheckIn(CheckInInput data) async {
    final response = await _provider.post(
        api.URL_MEETING_MEMBER_HAS_CHECKIN, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> isMeetingEnd(MeetingEndInput data) async {
    final response =
        await _provider.post(api.URL_MEETING_END, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<IOWebSocketChannel> wsCheckin() async {
    return _provider.openWebSocket(api.WS_URL_CHECKIN);
  }

  Future<IOWebSocketChannel> wsJoinAbsent() async {
    return _provider.openWebSocket(api.WS_URL_JOIN_ABSENT);
  }

  Future<TResult> getAssignList(UserMeetingInput data) async {
    final response =
        await _provider.post(api.URL_GET_ASSIGN_LIST_USER, jsonEncode(data));
    List<UserMeetingOutput> _meetingUser = [];
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<Map<String, dynamic>>();
      _meetingUser = _data.map<UserMeetingOutput>((event) {
        return UserMeetingOutput.fromJson(event);
      }).toList();
    }

    final r = TResult(
        status: response['Status'],
        data: _meetingUser,
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> assignUsers(InMeetingInput data) async {
    final response =
        await _provider.post(api.URL_ASSIGN_USER_MEETING, jsonEncode(data));

    final r = TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> getRolePage(RoleInput data) async {
    final response =
        await _provider.post(api.URL_GET_ROLE_PAGE, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> checkRolePage(RoleInput data) async {
    final response =
        await _provider.post(api.URL_CHECK_ROLE_PAGE, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> createMeeting(MeetingObjRequest data) async {
    final response =
        await _provider.post(api.URL_CREATE_PAGE_METTING, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> updateMeeting(MeetingObjRequest data) async {
    final response =
        await _provider.post(api.URL_UPDATE_PAGE_METTING, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> getMeetingById(String id) async {
    final response =
        await _provider.get(api.URL_GET_DETAIL_PAGE_METTING + "?id=$id");

    MeetingObjInput? _meetingObjInput;
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      _meetingObjInput = MeetingObjInput(
        name: _data['Name'],
        unitList: _data['UnitList'],
        admin: _data['Admin'],
        adminListObj: _data['AdminListObj'],
        roomMeetingList: _data['RoomMeetingList'],
        memberList: _data['MemberList'],
        memberListObj: _data['MemberListObj'],
        meetingDate: _data['MeetingDate'],
        startAt: _data['StartAt'],
        endAt: _data['EndAt'],
        address: _data['Address'],
        centralContent: _data['CentralContent'],
        fileUrl: _data['FileUrl'],
        unitNmList: _data['UnitNmList'],
        adminNmList: _data['AdminNmList'],
        roomNmList: _data['RoomNmList'],
        memberNmList: _data['MemberNmList'],
        fileNmList: _data['FileNmList'],
        publicFlg: _data['PublicFlg'],
        element: _data['Element'],
        note: _data['Note'],
        guest: _data['Guest'],
        meetingEndDate: _data['MeetingEndDate'],
      );
    }

    final r = TResult(
        status: response['Status'],
        data: _meetingObjInput,
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> getAccount() async {
    final response = await _provider.get(api.URL_GET_ACCOUNT_LIST);
    List<AccountOut> _accs = [];
    if (response['Status'] == 1) {
      final _roomsData = response['Data'].cast<Map<String, dynamic>>();
      _accs = _roomsData.map<AccountOut>((acc) {
        return AccountOut.fromJson(acc);
      }).toList();
    }

    return TResult(
        status: response['Status'], data: _accs, msg: response['Msg'] ?? '');
  }

  Future<TResult> getUserList(UserMeetingInput data) async {
    final response =
        await _provider.post(api.URL_GET_USER_LIST, jsonEncode(data));
    List<UserMeetingOutput> _meetingUser = [];
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<Map<String, dynamic>>();
      _meetingUser = _data.map<UserMeetingOutput>((event) {
        return UserMeetingOutput.fromJson(event);
      }).toList();
    }

    final r = TResult(
        status: response['Status'],
        data: _meetingUser,
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> onStartEndMeetingByQRCode(String _meetingID) async {
    final response = await _provider
        .get(api.URL_MEETING_START_END_MEETING + '/?meetingID=' + _meetingID);

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> checkinByQRCode(QRScanInput data) async {
    final response =
        await _provider.post(api.URL_MEETING_QRSCAN, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }
}
