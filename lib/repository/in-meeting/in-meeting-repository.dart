import 'dart:convert';

import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/models/in-meeting/document.dart';
import 'package:nmeeting/models/in-meeting/in-meeting.dart';
import 'package:nmeeting/models/in-meeting/join-meeting.dart';
import 'package:nmeeting/models/in-meeting/user-meeting.dart';
import 'package:nmeeting/models/meeting.dart';
import 'package:nmeeting/models/t-result.dart';

class InMeetingRepository {
  final _provider = ApiProvider();

  Future<TResult> checkIsInMeeting(InMeetingInput data) async {
    final response =
        await _provider.post(api.URL_MEETING_IS_INMEETING, jsonEncode(data));

    InMeetingOutput _inMeetingOutput;
    final _data = response['Data'].cast<String, dynamic>();
    _inMeetingOutput = InMeetingOutput(
        meetingID: _data['MeetingID'],
        meetingName: _data['MeetingName'],
        memberRole: _data['MemberRole'],
        errorType: _data['ErrorType']);

    final r = TResult(
        status: response['Status'],
        data: _inMeetingOutput,
        msg: response['Msg']);
    return r;
  }

  Future<TResult> getMeetingDetailById(InMeetingInput data) async {
    final response =
        await _provider.post(api.URL_MEETING_DETAIL, jsonEncode(data));
    // MeetingID, PersonalID
    var dataJson = response['Data'];
    InMeetingOutput? _inMeetingOutput;
    if (response['Status'] == 1 && dataJson != null) {
      final _data = response['Data'].cast<String, dynamic>();
      final _files = dataJson['FileAtract'] != null
          ? dataJson['FileAtract'].cast<Map<String, dynamic>>()
          : null;
      List<FileOutput> fileOutputs = [];
      for (var item in _files) {
        FileOutput element = FileOutput(
            name: item['Name'],
            id: item['ID'],
            documentUrl: item['DocumentUrl'],
            dirDocumentUrl: item['DirDocumentUrl'],
            downloadFlg: item['DownloadFlg']);
        fileOutputs.add(element);
      }
      _inMeetingOutput = InMeetingOutput(
        name: _data['Name'],
        content: _data['Content'],
        adminID: _data['AdminID'],
        adminNm: _data['AdminNm'],
        qrCode: _data['QRCode'],
        address: _data['Address'],
        meetingDate: _data['MeetingDate'],
        seatPosition: _data['SeatPosition'],
        member: _data['Member'],
        memberJoin: _data['MemberJoin'],
        meetingID: _data['MeetingID'],
        meetingName: _data['MeetingName'],
        startAt: _data['StartAt'],
        endAt: _data['EndAt'],
        joinedFlg: _data['JoinedFlg'],
        memberRole: _data['MemberRole'],
        files: fileOutputs,
        approveFlg: _data['ApproveFlg'] == 1,
        personalFlg: _data['PersonalFlg'],
        element: _data['Element'],
        note: _data['Note'],
        equipment: _data['Equipment'],
        guest: _data['Guest'],
        meetingEndDate: _data['MeetingEndDate'],
        cancelApproved: _data['CancelApproved'],
        groupID: _data['GroupID'],
      );
    }

    return TResult(
        status: response['Status'],
        data: _inMeetingOutput,
        msg: response['Msg']);
  }

  Future<TResult> getMenuCalender(String personalID) async {
    final response = await _provider
        .get(api.URL_GET_MENU_CALENDER + '?personalID=' + personalID);

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
  }

  Future<TResult> joinMeeting(InMeetingInput data) async {
    final response =
        await _provider.post(api.URL_JOIN_MEETING, jsonEncode(data));
    JoinMeetingOutput _joinMeetingOutput;
    if (response['Status'] == 1) {
      var dataMeeting = null;
      var dataJson = response['Data'];
      final _data = response['Data'].cast<String, dynamic>();
      var inMeetingJson = (dataJson != null && dataJson['Data'] != null)
          ? dataJson['Data']
          : null;

      if (inMeetingJson != null && inMeetingJson != []) {
        final _inMeetingData = dataJson['Data'] != null
            ? dataJson['Data'].cast<String, dynamic>()
            : null;
        final _files =
            (inMeetingJson != null && inMeetingJson['FileAtract'] != null)
                ? inMeetingJson['FileAtract'].cast<Map<String, dynamic>>()
                : null;
        List<FileOutput> fileOutputs = [];
        if (_files != null) {
          for (var item in _files) {
            FileOutput element = FileOutput(
                name: item['Name'],
                id: item['ID'],
                documentUrl: item['DocumentUrl'],
                dirDocumentUrl: item['DirDocumentUrl'],
                downloadFlg: item['DownloadFlg']);
            fileOutputs.add(element);
          }
        }

        if (_inMeetingData != null) {
          dataMeeting = InMeetingOutput(
              name: _inMeetingData['Name'],
              content: _inMeetingData['Content'],
              adminID: _inMeetingData['AdminID'],
              adminNm: _inMeetingData['AdminNm'],
              qrCode: _inMeetingData['QRCode'],
              address: _inMeetingData['Address'],
              meetingDate: _inMeetingData['MeetingDate'],
              seatPosition: _inMeetingData['SeatPosition'],
              member: _inMeetingData['Member'],
              memberJoin: _inMeetingData['MemberJoin'],
              meetingID: _inMeetingData['MeetingID'],
              meetingName: _inMeetingData['MeetingName'],
              startAt: _inMeetingData['StartAt'],
              endAt: _inMeetingData['EndAt'],
              joinedFlg: _inMeetingData['JoinedFlg'],
              files: fileOutputs);
        }
      }

      _joinMeetingOutput = JoinMeetingOutput(
          status: 1,
          code: _data['Code'],
          title: _data['Title'],
          msg: _data['Msg'],
          data: dataMeeting);
    } else {
      _joinMeetingOutput =
          JoinMeetingOutput(status: 0, code: 0, title: '', data: null);
    }

    return TResult(
        status: response['Status'],
        data: _joinMeetingOutput,
        msg: response['Msg']);
  }

  Future<TResult> submitAbsent(InMeetingInput data) async {
    final response =
        await _provider.post(api.URL_SUBMIT_ABSENT, jsonEncode(data));

    return TResult(
        status: response['Status'], data: null, msg: response['Msg']);
  }

  Future<TResult> addOrRemovePersonal(InMeetingInput data) async {
    final response =
        await _provider.post(api.URL_ADDREMOVE_PERSONAL, jsonEncode(data));

    return TResult(
        status: response['Status'], data: null, msg: response['Msg']);
  }

  Future<TResult> getDocuments(DocumentMeetingDetailInput data) async {
    final response =
        await _provider.post(api.URL_MEETING_DETAIL_DOCUMENT, jsonEncode(data));

    List<DocumentOutput> _documents = [];
    if (response['Status'] == 1) {
      final _documentsData = response['Data'].cast<Map<String, dynamic>>();
      _documents = _documentsData.map<DocumentOutput>((event) {
        return DocumentOutput.fromJson(event);
      }).toList();
    }

    return TResult(
        status: response['Status'], data: _documents, msg: response['Msg']);
  }

  // Future<TResult> getMemberRole(MemberRoleInput data) async {
  //   final response =
  //       await _provider.post(api.URL_MEETING_MEMBER_ROLE, jsonEncode(data));

  //   return TResult(
  //       status: response['Status'],
  //       data: response['Data'],
  //       msg: response['Msg']);
  // }

  // Future<IOWebSocketChannel> openStartEndMeetingWebSocketChannel() async {
  //   return _provider.openWebSocket(api.WS_URL_ADMIN_START_END_MEETING);
  // }

  // Future<IOWebSocketChannel> openVotingStartWebSocketChannel() async {
  //   return _provider.openWebSocket(api.WS_URL_VOTING_START);
  // }

  Future<TResult> isMeetingEnd(MeetingEndInput data) async {
    final response =
        await _provider.post(api.URL_MEETING_END, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
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
        status: response['Status'], data: _meetingUser, msg: response['Msg']);
    return r;
  }

  Future<TResult> assignUsers(InMeetingInput data) async {
    final response =
        await _provider.post(api.URL_ASSIGN_USER_MEETING, jsonEncode(data));

    final r = TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
    return r;
  }

  Future<TResult> getMeetingReady(String userName, String meetingID) async {
    final response = await _provider.get(api.URL_MEETING_READY +
        '?userName=' +
        userName +
        '&meetingID=' +
        meetingID);
    MeetingReadyOutput? _meetingReady;
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      _meetingReady = new MeetingReadyOutput(
        id: _data['ID'],
        name: _data['Name'],
        admin: _data['Admin'],
        address: _data['Address'],
        meetingDate: _data['MeetingDate'],
        meetingEndDate: _data['MeetingEndDate'],
        startAt: _data['StartAt'],
        endAt: _data['EndAt'],
        approveFlg: _data['ApproveFlg'],
        approveBy: _data['ApproveBy'],
        approveAt: _data['ApproveAt'],
        createAt: _data['CreateAt'],
        createBy: _data['CreateBy'],
        delFlg: _data['DelFlg'],
        delAt: _data['DelAt'],
        delBy: _data['DelBy'],
        endFlg: _data['EndFlg'],
        startFlg: _data['StartFlg'],
        startAtByQRScan: _data['StartAtByQRScan'],
        endAtByQRScan: _data['EndAtByQRScan'],
        element: _data['Element'],
        type: _data['Type'],
        publicFlg: _data['PublicFlg'],
        memberList: _data['MemberList'],
        adminList: _data['AdminList'],
      );
    }
    return TResult(
        status: response['Status'], data: _meetingReady, msg: response['Msg']);
  }
}
