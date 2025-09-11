import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/in-meeting/document.dart';
import 'package:nmeeting/models/in-meeting/in-meeting.dart';
import 'package:nmeeting/models/in-meeting/user-meeting.dart';
import 'package:nmeeting/models/meeting.dart';
import 'package:nmeeting/models/in-meeting/join-meeting.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/in-meeting/in-meeting-repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nmeeting/utilities/string-utils.dart';

class InMeetingBloc extends BaseBloc {
  // repository
  final _inMeetingRepository = new InMeetingRepository();
  List<String> stringListMain = [];

  // meeting Id
  final _meetingIdController = BehaviorSubject<String>();
  Stream<String> get meetingIdStream => _meetingIdController.stream;

  // meeting time
  final _meetingTimeController = BehaviorSubject<DateTime>();
  Stream<DateTime> get meetingTimeStream => _meetingTimeController.stream;

  // meeting name
  final _meetingNameController = BehaviorSubject<String>();
  Stream<String> get meetingNameStream => _meetingNameController.stream;

  // member role
  final _memberRoleController = BehaviorSubject<int>();
  Stream<int> get memberRoleStream => _memberRoleController.stream;

  // meeting
  var _meetingController = StreamController<InMeetingOutput?>();
  Stream<InMeetingOutput?> get meetingStream => _meetingController.stream;

  // join meeting
  var _joinMeetingController = StreamController<JoinMeetingOutput?>();
  Stream<JoinMeetingOutput?> get joinMeetingStream =>
      _joinMeetingController.stream;

  // is loading
  final _isLoadingController = BehaviorSubject<bool>();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  // is permissionReady
  final _isPermissionReadyController = BehaviorSubject<bool>();
  Stream<bool> get isPermissionReadyStream =>
      _isPermissionReadyController.stream;

  // is joined
  final _isJoinedController = BehaviorSubject<bool>();
  Stream<bool> get isJoinedStream => _isJoinedController.stream;

  // keep alive if only change inmeeting tap, otherwise not keep
  final _keepAliveForAdminWebViewTabController = BehaviorSubject<bool>();
  Stream<bool> get keepAliveForAdminWebViewTabControllerStream =>
      _keepAliveForAdminWebViewTabController.stream;

  // is meeting ended
  final _isMeetingEndedController = BehaviorSubject<bool>();
  Stream<bool> get isMeetingEndedStream => _isMeetingEndedController.stream;

  // list user assign
  var _assignListMeetingController =
      StreamController<List<UserMeetingOutput>>.broadcast();
  Stream<List<UserMeetingOutput>> get assignListMeetingStream =>
      _assignListMeetingController.stream.asBroadcastStream();

  List<UserMeetingOutput> _assignListMeetingOrigin = [];
  List<UserMeetingOutput> _assignListMeetingMain = [];

  String documentByProgressId = '';

  // _meetingReadyController
  final _meetingReadyController = BehaviorSubject<MeetingReadyOutput>();
  Stream<MeetingReadyOutput> get meetingReadyStream =>
      _meetingReadyController.stream;

  // get approved Flg
  final _actionGetApprovedFlgController = BehaviorSubject<bool>();
  Stream<bool> get actionGetApprovedFlgStream =>
      _actionGetApprovedFlgController.stream;

  // get Persional Flg
  final _actionGetPersionalFlgController = BehaviorSubject<bool>();
  Stream<bool> get actionGetPersionalFlgStream =>
      _actionGetPersionalFlgController.stream;

  onSetMeetingId(String _id) {
    _meetingIdController.sink.add(_id);
  }

  onSetMeetingTime(DateTime time) {
    _meetingTimeController.sink.add(time);
  }

  String onGetMeetingId() {
    return _meetingIdController.value;
  }

  DateTime onGetMeetingTime() {
    return _meetingTimeController.value;
  }

  onSetMeetingName(String _name) {
    _meetingNameController.sink.add(_name);
  }

  onSetMemberRole(int _value) {
    _memberRoleController.sink.add(_value);
  }

  onSetIsLoading(bool _value) {
    _isLoadingController.sink.add(_value);
  }

  onSetIsPermissionReady(bool _value) {
    _isPermissionReadyController.sink.add(_value);
  }

  onSetjoinMeeting(JoinMeetingOutput data) {
    _joinMeetingController.sink.add(data);
  }

  onSetIsJoinedMeeting(bool value) {
    _isJoinedController.sink.add(value);
  }

  onSetDocumentByProgressId(String _id) {
    this.documentByProgressId = _id;
  }

  onSetKeepAliveForAdminWebViewTabController(bool value) {
    _keepAliveForAdminWebViewTabController.sink.add(value);
  }

  bool onGetKeepAliveForAdminWebViewTabController() {
    return _keepAliveForAdminWebViewTabController.value;
  }

  onSetActionGetApprovedFlgController(bool value) {
    _actionGetApprovedFlgController.sink.add(value);
  }

  bool onGetActionGetApprovedFlgController() {
    return _actionGetApprovedFlgController.value;
  }

  onSetActionGetPersionalFlgController(bool value) {
    _actionGetPersionalFlgController.sink.add(value);
  }

  bool onGetActionGetPersionalFlgController() {
    return _actionGetPersionalFlgController.value;
  }

  Future<TResult> checkIsInMeeting() async {
    final prefs = await SharedPreferences.getInstance();
    final _inMeetingInput =
        InMeetingInput(personalID: prefs.getString('personalID'));

    final res = await _inMeetingRepository.checkIsInMeeting(_inMeetingInput);
    return res;
  }

  Future<bool> isMeetingEnd() async {
    final _meetingEndInput =
        MeetingEndInput(meetingID: _meetingIdController.value);
    // final _meetingEndInput =
    //     MeetingEndInput(meetingID: MeetingIdTest);
    final _response = await _inMeetingRepository.isMeetingEnd(_meetingEndInput);
    _isMeetingEndedController.sink.add(_response.data);
    return _response.data;
  }

  bool onGetIsMeetingEnded() {
    return _isMeetingEndedController.value;
  }

  onGetMeetingDetailById() async {
    _meetingController = StreamController<InMeetingOutput>();
    _meetingController.sink.add(null);
    _joinMeetingController = StreamController<JoinMeetingOutput>();
    _joinMeetingController.sink.add(null);

    final prefs = await SharedPreferences.getInstance();
    final _inMeetingInput = InMeetingInput(
        unitID: prefs.getString('unitid'),
        personalID: prefs.getString('personalID'),
        meetingID: _meetingIdController.value);
    final res =
        await _inMeetingRepository.getMeetingDetailById(_inMeetingInput);
    if (res.status == 1 && res.data != null) {
      _meetingController.sink.add(res.data);
      _memberRoleController.sink.add(res.data.memberRole);
      _isJoinedController.sink.add(res.data.joinedFlg);
      _meetingTimeController.sink.add(DateTime.parse(res.data.startAt));
      _actionGetApprovedFlgController.sink.add(res.data.approveFlg);
      _actionGetPersionalFlgController.sink.add(res.data.personalFlg);
    }
  }

  Future<TResult> onJoinMeeting() async {
    final prefs = await SharedPreferences.getInstance();
    final _inMeetingInput = InMeetingInput(
        personalID: prefs.getString('personalID'),
        meetingID: _meetingIdController.value);
    final res = await _inMeetingRepository.joinMeeting(_inMeetingInput);
    _joinMeetingController.sink.add(res.data);
    if (res.status == 1 && res.data.code == 1) {
      _isJoinedController.sink.add(true);
    } else {
      _isJoinedController.sink.add(false);
    }

    return res;
  }

  Future<TResult> onSubmitAbsent() async {
    final prefs = await SharedPreferences.getInstance();
    final _inMeetingInput = InMeetingInput(
        personalID: prefs.getString('personalID'),
        meetingID: _meetingIdController.value);
    final res = await _inMeetingRepository.submitAbsent(_inMeetingInput);
    return res;
  }

  Future<TResult> onAddOrRemovePersonal() async {
    final prefs = await SharedPreferences.getInstance();
    final _inMeetingInput = InMeetingInput(
        personalID: prefs.getString('personalID'),
        meetingID: _meetingIdController.value);
    final res = await _inMeetingRepository.addOrRemovePersonal(_inMeetingInput);
    return res;
  }

  Future<TResult> getDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final _documentInput = DocumentMeetingDetailInput(
      meetingID: _meetingIdController.value,
      personalID: prefs.getString('personalID') ?? '',
      accountName: prefs.getString('username') ?? '',
    );

    final res = await _inMeetingRepository.getDocuments(_documentInput);
    return res;
  }

  // getMemberRole() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final _memberRoleInput = MemberRoleInput(
  //       personalID: prefs.getString('personalID'),
  //       meetingID: _meetingIdController.value);
  //   final res = await _inMeetingRepository.getMemberRole(_memberRoleInput);
  //   if (res.status == 1) {
  //     _memberRoleController.sink.add(res.data);
  //   }
  // }

  // Future<IOWebSocketChannel> openStartEndMeetingWebSocketChannel() {
  //   return _inMeetingRepository.openStartEndMeetingWebSocketChannel();
  // }

  // Future<IOWebSocketChannel> openVotingStartWebSocketChannel() {
  //   return _inMeetingRepository.openVotingStartWebSocketChannel();
  // }

  Future<List<String>> getListUserAssign(String _searchTxt) async {
    List<String> stringList = [];
    final prefs = await SharedPreferences.getInstance();
    final _userMeetingInput = UserMeetingInput(
        personalID: prefs.getString('personalID'),
        unitID: prefs.getString('unitid'),
        searchTxt: _searchTxt,
        meetingID: _meetingIdController.value);
    final res = await _inMeetingRepository.getAssignList(_userMeetingInput);
    final _data = List<UserMeetingOutput>.from(res.data);
    _data.sort((a, b) =>
        a.selected.toString().length.compareTo(b.selected.toString().length));
    _assignListMeetingController.sink.add(_data);

    _assignListMeetingOrigin =
        _data.map((item) => new UserMeetingOutput.clone(item)).toList();
    _assignListMeetingMain = _assignListMeetingOrigin;
    if (_data != null && _data.length > 0) {
      for (var i = 0; i < _data.length; i++) {
        if (_data[i].disable == false && _data[i].selected == true) {
          stringList.add(_data[i].id);
        }
      }
    }

    stringListMain = new List<String>.from(stringList);
    return stringList;
  }

  bool isChanged(List<String> stringList) {
    if (stringList.length != stringListMain.length) {
      return true;
    } else {
      stringList
          .sort((a, b) => a.toString().length.compareTo(b.toString().length));
      stringListMain
          .sort((a, b) => a.toString().length.compareTo(b.toString().length));
      if (StringUtils.convertListToString(stringList) !=
          StringUtils.convertListToString(stringListMain)) {
        return true;
      }
    }

    return false;
  }

  updateAssignListMeetingOrigin(List<UserMeetingOutput> listUser) {
    _assignListMeetingOrigin =
        listUser.map((item) => new UserMeetingOutput.clone(item)).toList();
  }

  assignUsers(String userIds) async {
    final prefs = await SharedPreferences.getInstance();
    final _inMeetingInput = InMeetingInput(
        personalID: prefs.getString('personalID'),
        meetingID: _meetingIdController.value,
        assignList: userIds);
    final res = await _inMeetingRepository.assignUsers(_inMeetingInput);
    return res;
  }

  searchUser(String _searchText) {
    if (StringUtils.isNullOrEmpty(_searchText)) {
      _assignListMeetingController.sink.add(_assignListMeetingOrigin);
      return;
    }

    var _result = _assignListMeetingOrigin
        .where((test) =>
            test.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    _assignListMeetingController.sink.add(_result);
  }

  getMeetingReady() async {
    final prefs = await SharedPreferences.getInstance();
    final res = await _inMeetingRepository.getMeetingReady(
        prefs.getString('username') ?? '',
        '00000000-0000-0000-0000-000000000000');
    if (res.status == 1) {
      _meetingReadyController.sink.add(res.data);
    }
  }

  getMenuCalender() async {
    final prefs = await SharedPreferences.getInstance();
    final res = await _inMeetingRepository
        .getMenuCalender(prefs.getString('personalID') ?? '');

    return res.data;
  }

  @override
  void dispose() {
    _meetingIdController?.close();
    _meetingTimeController?.close();
    _meetingNameController?.close();
    _memberRoleController?.close();
    _meetingController?.close();
    _joinMeetingController?.close();
    _actionGetApprovedFlgController?.close();
    _isLoadingController?.close();
    _isPermissionReadyController?.close();
    _isJoinedController?.close();
    _keepAliveForAdminWebViewTabController?.close();
    _isMeetingEndedController?.close();
    _assignListMeetingController?.close();
    _meetingReadyController?.close();
    _actionGetPersionalFlgController?.close();
  }
}
