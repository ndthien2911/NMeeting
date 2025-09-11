import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/in-meeting/in-meeting.dart';
import 'package:nmeeting/models/in-meeting/user-meeting.dart';
import 'package:nmeeting/models/meeting.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/meeting-respository.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:nmeeting/configs/constants.dart' as constants;

class MeetingBloc extends BaseBloc {
  // repository
  final _meetingRepository = new MeetingRepository();
  List<String> listSelected = [];

  // meeting ID
  final _meetingIdController = BehaviorSubject<String>();
  Stream<String> get meetingIdStream => _meetingIdController.stream;

  // network
  final _isHasNetworController = BehaviorSubject<bool>();
  Stream<bool> get isHasNetworkStream => _isHasNetworController.stream;

  // List
  final _meetingListStreamController = StreamController<List<MeetingOutput>>();
  // stream
  Stream<List<MeetingOutput>> get meetingListStream =>
      _meetingListStreamController.stream;

  // controller
  final _eventListStreamController =
      StreamController<Map<DateTime, List<String>>>();
  // stream
  Stream<Map<DateTime, List<String>>> get eventListStream =>
      _eventListStreamController.stream;

  // list user assign
  var _assignListMeetingController =
      StreamController<List<UserMeetingOutput>>.broadcast();
  Stream<List<UserMeetingOutput>> get assignListMeetingStream =>
      _assignListMeetingController.stream.asBroadcastStream();

  // is meeting ended
  final _isMeetingEndedController = BehaviorSubject<bool>();
  Stream<bool> get isMeetingEndedStream => _isMeetingEndedController.stream;

  var _assignListMeetingOrigin = [];

  // tab current name
  final _tabCurrentNameController = BehaviorSubject<String>();
  Stream<String> get tabCurrentNameStream => _tabCurrentNameController.stream;

  // keep alive if only change inmeeting tap, otherwise not keep
  final _keepAliveForAdminWebViewTabController = BehaviorSubject<bool>();
  Stream<bool> get keepAliveForAdminWebViewTabControllerStream =>
      _keepAliveForAdminWebViewTabController.stream;

  // click btn select add
  final _actionSelecteFlgController = BehaviorSubject<bool>();
  Stream<bool> get actionSelecteFlgStream => _actionSelecteFlgController.stream;

  // click week selected
  final _actionWeekSelectedController = BehaviorSubject<int>();
  Stream<int> get weekSelectedStream => _actionWeekSelectedController.stream;

  // list user assign
  var _userListMeetingController =
      StreamController<List<UserMeetingOutput>>.broadcast();
  Stream<List<UserMeetingOutput>> get userListMeetingStream =>
      _userListMeetingController.stream.asBroadcastStream();
  List<UserMeetingOutput> _userListMeetingMain = [];
  List<UserMeetingOutput> _userListMeetingOrigin = [];
  List<MemberVM> _userListMeetingToServer = [];

  onSetMeetingId(String _meetingId) {
    _meetingIdController.sink.add(_meetingId);
  }

  String onGetMeetingId() {
    return _meetingIdController.value;
  }

  onNetworkChanged(bool _status) async {
    _isHasNetworController.sink.add(_status);
  }

  bool onGetIsMeetingEnded() {
    return _isMeetingEndedController.value;
  }

  onSetTabCurrentName(String _name) {
    _tabCurrentNameController.sink.add(_name);
  }

  String onGetTabCurrentName() {
    return _tabCurrentNameController.value;
  }

  onSetKeepAliveForAdminWebViewTabController(bool value) {
    _keepAliveForAdminWebViewTabController.sink.add(value);
  }

  bool onGetKeepAliveForAdminWebViewTabController() {
    return _keepAliveForAdminWebViewTabController.value;
  }

  onSetActionSelecteFlg(bool _flg) {
    _actionSelecteFlgController.sink.add(_flg);
  }

  bool onGetActionSelecteFlg() {
    return _actionSelecteFlgController.value;
  }

  onSetWeekSelectedValue(int weekSelectedValue) {
    _actionWeekSelectedController.sink.add(weekSelectedValue);
  }

  int onGetWeekSelectedValue() {
    return _actionWeekSelectedController.value;
  }

  //Count list
  final _meetingCountController = BehaviorSubject<int>();
  Stream<int> get meetingCountStream => _meetingCountController.stream;

  onSetMeetingCount(int _cnt) {
    _meetingCountController.sink.add(0);
    _meetingCountController.sink.add(_cnt);
  }

  int onGetMeetingCount() {
    return (_meetingCountController.value != null)
        ? _meetingCountController.value
        : 0;
  }

  // Admin
  final _meetingAdminInputController = BehaviorSubject<String>();
  Stream<String> get meetingAdminInputStream =>
      _meetingAdminInputController.stream;

  // user join
  final _meetingMemberInputController = BehaviorSubject<String>();
  Stream<String> get meetingMemberInputStream =>
      _meetingMemberInputController.stream;

  // name input
  final _meetingNameInputController = BehaviorSubject<String>();
  Stream<String> get meetingNameInputStream =>
      _meetingNameInputController.stream;

  // meeting date
  final _meetingDateResInputController = BehaviorSubject<String>();
  Stream<String> get meetingDateResInputStream =>
      _meetingDateResInputController.stream;

  // meeting end date
  final _meetingEndDateResInputController = BehaviorSubject<String>();
  Stream<String> get meetingEndDateResInputStream =>
      _meetingEndDateResInputController.stream;

  // description input
  final _meetingAddressInputController = BehaviorSubject<String>();
  Stream<String> get meetingAddressInputStream =>
      _meetingAddressInputController.stream;

  // element input
  final _meetingElementInputController = BehaviorSubject<String>();
  Stream<String> get meetingElementInputStream =>
      _meetingElementInputController.stream;

  // note input
  final _meetingNoteInputController = BehaviorSubject<String>();
  Stream<String> get meetingNoteInputStream =>
      _meetingNoteInputController.stream;

  // guest input
  final _meetingGuestInputController = BehaviorSubject<String>();
  Stream<String> get meetingGuestInputStream =>
      _meetingGuestInputController.stream;

  // list Admin
  var _adminListMeetingController =
      StreamController<List<AccountOut>>.broadcast();
  Stream<List<AccountOut>> get adminListMeetingStream =>
      _adminListMeetingController.stream.asBroadcastStream();
  var _adminListMeetingMain = [];
  List<AccountOut> _adminListMeetingOrigin = [];
  List<MemberVM> _adminListMeetingToServer = [];

  onChangedMeetingAdminInput(List<AccountOut> listData) {
    String listSelectedStr = "[]";
    List<MemberVM> listSelectedVM = [];
    listSelected = [];
    if (listData.length > 0) {
      for (var i = 0; i < listData.length; i++) {
        if (listData[i].selected == true) {
          listSelected.add(listData[i].id);
          //remove in list user join
          String listMemberStr = this.onGetMeetingMemberInput();
          if (!StringUtils.isNullOrEmpty(listMemberStr)) {
            if (listMemberStr.contains(listData[i].id) == true) {
              List<Object> listMember =
                  StringUtils.convertStringToList(listMemberStr);
              for (var j = 0; j < listMember.length; j++) {
                if (listMember[j].toString() == listData[i].id) {
                  listMember.remove(listMember[j]);
                  break;
                }
              }
              String listMemberStrNew =
                  StringUtils.convertListToString(listMember);
              this.onSetMeetingMemberInput(listMemberStrNew);
            }
          }
          //add
          listSelectedVM.add(
            MemberVM()
              ..object = listData[i].id
              ..type = listData[i].type,
          );
          //remove in list user join
          for (var k = 0; k < _userListMeetingToServer.length; k++) {
            if (_userListMeetingToServer[k].object == listData[i].id &&
                _userListMeetingToServer[k].type == listData[i].type) {
              _userListMeetingToServer.remove(_userListMeetingToServer[k]);
              break;
            }
          }
        }
      }

      listSelectedStr = StringUtils.convertListToString(listSelected);
    }
    _meetingAdminInputController.sink.add(listSelectedStr);
    _adminListMeetingToServer = listSelectedVM;
  }

  List<MemberVM> onGetMeetingAdminToServer() {
    return _adminListMeetingToServer;
  }

  List<MemberVM> onGetMeetingUserToServer() {
    return _userListMeetingToServer;
  }

  onSetMeetingAdminToServer(List<MemberVM> value) {
    _adminListMeetingToServer = value;
  }

  onSetMeetingUserToServer(List<MemberVM> value) {
    _userListMeetingToServer = value;
  }

  onChangedMeetingMemberInput(List<dynamic> stringList) {
    List<UserMeetingOutput> listUser = this._userListMeetingMain;
    String listSelectedStr = "[]";
    List<MemberVM> listSelectedVM = [];
    listSelected = [];
    for (var j = 0; j < stringList.length; j++) {
      bool isHasSystem = false;
      for (var i = 0; i < listUser.length; i++) {
        if (listUser[i].id == stringList[j].toString()) {
          isHasSystem = true;
          listSelected.add(listUser[i].id);
          //add
          MemberVM tmp = new MemberVM();
          tmp.object = listUser[i].id;
          tmp.type = listUser[i].type;
          listSelectedVM.add(tmp);
        }
      }
      if (isHasSystem == false) {
        listSelected.add(stringList[j].toString());
        //add
        MemberVM tmp = new MemberVM();
        tmp.object = stringList[j].toString();
        tmp.type = constants.TYPE_OTHER;
        listSelectedVM.add(tmp);
      }
    }
    listSelectedStr = StringUtils.convertListToString(listSelected);
    _meetingMemberInputController.sink.add(listSelectedStr);
    _userListMeetingToServer = listSelectedVM;
  }

  String getListNameUserSelected(List<dynamic> stringList) {
    List<UserMeetingOutput> list = this._userListMeetingMain;
    String listNm = "";
    for (var j = 0; j < stringList.length; j++) {
      bool isExist = false;
      for (var i = 0; i < list.length; i++) {
        if (list[i].id == stringList[j].toString()) {
          if (listNm == "") {
            listNm = list[i].name;
          } else {
            listNm = listNm + ", " + list[i].name;
          }
          isExist = true;
        }
      }
      if (isExist == false) {
        if (listNm == "") {
          listNm = stringList[j].toString();
        } else {
          listNm = listNm + ", " + stringList[j].toString();
        }
      }
    }

    return listNm;
  }

  onSetMeetingMemberInput(String value) {
    return _meetingMemberInputController.sink.add(value);
  }

  String onGetMeetingMemberInput() {
    return _meetingMemberInputController.value;
  }

  onChangedMeetingNameInput(String value) {
    if (StringUtils.isNullOrEmpty(value?.trim())) {
      return _meetingNameInputController.sink.addError("Vui lòng nhập tiêu đề");
    }
    if (!StringUtils.isLength(value, 1, 250)) {
      return _meetingNameInputController.sink
          .addError("Tiêu đề không được quá 250 ký tự");
    }

    return _meetingNameInputController.sink.add(value);
  }

  onSetMeetingNameInput(String value) {
    return _meetingNameInputController.sink.add(value);
  }

  String onGetMeetingNameInput() {
    return _meetingNameInputController.value;
  }

  onChangedMeetingAddressInput(String value) {
    if (StringUtils.isNullOrEmpty(value?.trim())) {
      return _meetingAddressInputController.sink
          .addError("Vui lòng nhập địa điểm");
    }
    if (!StringUtils.isLength(value, 1, 500)) {
      return _meetingAddressInputController.sink
          .addError("Địa điểm không được quá 500 ký tự");
    }

    return _meetingAddressInputController.sink.add(value);
  }

  onSetMeetingAddressInput(String value) {
    return _meetingAddressInputController.sink.add(value);
  }

  String onGetMeetingAddressInput() {
    return _meetingAddressInputController.value;
  }

  onChangedMeetingAdminTextInput(String value) {
    if (StringUtils.isNullOrEmpty(value?.trim())) {
      return _meetingAdminInputController.sink
          .addError("Vui lòng nhập thông tin \"Chủ trì cuộc họp\"");
    }
    if (!StringUtils.isLength(value, 1, 500)) {
      return _meetingAdminInputController.sink
          .addError("Thông tin \"Chủ trì cuộc họp\" không được quá 500 ký tự");
    }

    return _meetingAddressInputController.sink.add(value);
  }

  onSetMeetingAdminInput(String value) {
    return _meetingAddressInputController.sink.add(value);
  }

  String onGetMeetingAdminInput() {
    return _meetingAddressInputController.value;
  }

  onChangedMeetingElementTextInput(String value) {
    if (StringUtils.isNullOrEmpty(value?.trim())) {
      return _meetingElementInputController.sink
          .addError("Vui lòng nhập thông tin \"Thành phần cuộc họp\"");
    }
    if (!StringUtils.isLength(value, 1, 500)) {
      return _meetingElementInputController.sink.addError(
          "Thông tin \"Thành phần cuộc họp\" không được quá 500 ký tự");
    }

    return _meetingElementInputController.sink.add(value);
  }

  onSetMeetingElementInput(String value) {
    return _meetingElementInputController.sink.add(value);
  }

  String onGetMeetingElementInput() {
    return _meetingElementInputController.value;
  }

  onChangedMeetingNoteTextInput(String value) {
    if (StringUtils.isNullOrEmpty(value?.trim())) {
      return _meetingNoteInputController.sink
          .addError("Vui lòng nhập thông tin \"Chuẩn bị\"");
    }
    if (!StringUtils.isLength(value, 1, 500)) {
      return _meetingNoteInputController.sink
          .addError("Thông tin \"Chuẩn bị\" không được quá 500 ký tự");
    }

    return _meetingNoteInputController.sink.add(value);
  }

  onSetMeetingNoteInput(String value) {
    return _meetingNoteInputController.sink.add(value);
  }

  String onGetMeetingNoteInput() {
    return _meetingNoteInputController.value;
  }

  onChangedMeetingGuestTextInput(String value) {
    if (!StringUtils.isLength(value, 1, 500)) {
      return _meetingGuestInputController.sink
          .addError("Thông tin \"Khách mời\" không được quá 500 ký tự");
    }

    return _meetingGuestInputController.sink.add(value);
  }

  onSetMeetingGuestInput(String value) {
    return _meetingGuestInputController.sink.add(value);
  }

  String onGetMeetingGuestInput() {
    return _meetingGuestInputController.value;
  }

  // username
  final _roleAppController = BehaviorSubject<String>();
  Stream<String> get roleAppStream => _roleAppController.stream;

  checkRolePage(
      String pageIDInput, String pageNmInput, String controlStrInput) async {
    final _roleInput = RoleInput(
        pageID: pageIDInput, pageNm: pageNmInput, controlStr: controlStrInput);
    final _response = await _meetingRepository.checkRolePage(_roleInput);

    return _response;
  }

  getRolePage(String roleIDInput, String pageIDInput) async {
    final _roleInput = RoleInput(roleID: roleIDInput, pageID: pageIDInput);
    final _response = await _meetingRepository.getRolePage(_roleInput);

    if (_response.status == 1) {
      _roleAppController.sink.add(_response.data);

      if (!StringUtils.isNullOrEmpty(_response.data)) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('rolepage', _response.data);
      }
    }

    return _response;
  }

  String onGetRoleAppStr() {
    return _roleAppController.value;
  }

  onChangedMeetingDateResInput(String value) {
    return _meetingDateResInputController.sink.add(value);
  }

  onSetMeetingDateResInput(String value) {
    return _meetingDateResInputController.sink.add(value);
  }

  String onGetMeetingDateResInput() {
    return _meetingDateResInputController.value;
  }

  onChangedMeetingEndDateResInput(String value) {
    return _meetingEndDateResInputController.sink.add(value);
  }

  onSetMeetingEndDateResInput(String value) {
    return _meetingEndDateResInputController.sink.add(value);
  }

  String onGetMeetingEndDateResInput() {
    return _meetingEndDateResInputController.value;
  }

  Future<bool> checkUserHasCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final _checkInInput = CheckInInput(
      meetingID: _meetingIdController.value,
      personalID: prefs.getString('personalID') ?? '',
    );
    final _response =
        await _meetingRepository.checkUserHasCheckIn(_checkInInput);

    return _response.data;
  }

  Future<bool> qrCheckedFlg(String _qrCode) async {
    final _qrCheckedParam = QRCheckedInput(qrCode: _qrCode);
    final _response = await _meetingRepository.qrCheckedFlg(_qrCheckedParam);

    return _response.data;
  }

  Future<bool> isMeetingEnd() async {
    final _meetingEndInput =
        MeetingEndInput(meetingID: _meetingIdController.value);
    final _response = await _meetingRepository.isMeetingEnd(_meetingEndInput);
    _isMeetingEndedController.sink.add(_response.data);
    return _response.data;
  }

  Future<IOWebSocketChannel> openCheckinWebSocketChannel() {
    return _meetingRepository.wsCheckin();
  }

  Future<IOWebSocketChannel> openJoinAbsentWebSocketChannel() {
    return _meetingRepository.wsJoinAbsent();
  }

  getListUserAssign(String _searchTxt) async {
    final prefs = await SharedPreferences.getInstance();
    final _userMeetingInput = UserMeetingInput(
        personalID: prefs.getString('personalID'),
        unitID: prefs.getString('user_unitID'),
        searchTxt: _searchTxt,
        meetingID: _meetingIdController.value);
    final res = await _meetingRepository.getAssignList(_userMeetingInput);
    final _data = List<UserMeetingOutput>.from(res.data);
    _assignListMeetingController.sink.add(_data);

    _assignListMeetingOrigin =
        _data.map((item) => new UserMeetingOutput.clone(item)).toList();
  }

  bool isChanged(listUser) {
    for (var i = 0; i < _assignListMeetingOrigin.length; i++) {
      if (listUser[i].selected != _assignListMeetingOrigin[i].selected) {
        return true;
      }
    }
    return false;
  }

  updateAdminListMeetingOrigin(List<AccountOut> listAdmin) {
    _adminListMeetingOrigin =
        listAdmin.map((item) => new AccountOut.clone(item)).toList();
  }

  updateAssignListMeetingOrigin(List<UserMeetingOutput> listUser) {
    _assignListMeetingOrigin =
        listUser.map((item) => new UserMeetingOutput.clone(item)).toList();
  }

  updateUserListMeetingOrigin(List<UserMeetingOutput> listUser) {
    _userListMeetingOrigin =
        listUser.map((item) => new UserMeetingOutput.clone(item)).toList();
  }

  assignUsers(String userIds) async {
    final prefs = await SharedPreferences.getInstance();
    final _inMeetingInput = InMeetingInput(
        personalID: prefs.getString('personalID'),
        meetingID: _meetingIdController.value,
        assignList: userIds);
    final res = await _meetingRepository.assignUsers(_inMeetingInput);
    return res;
  }

  addNewAdmin(AccountOut user) {
    var _result = _adminListMeetingOrigin.toList();
    //_result.add(user);
    _adminListMeetingController.sink.add(_result);
  }

  addNewUser(UserMeetingOutput user) {
    var _result = _userListMeetingOrigin.toList();
    //_result.add(user);
    _userListMeetingController.sink.add(_result);
  }

  searchUser(String _searchText, List<dynamic> stringList) {
    if (StringUtils.isNullOrEmpty(_searchText)) {
      this.getListUser('', stringList);
      //_userListMeetingController.sink.add(_userListMeetingOrigin);
      return;
    }

    var _result = _userListMeetingOrigin
        .where((test) =>
            test.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    _userListMeetingController.sink.add(_result);
  }

  searchAdmin(String _searchText) {
    if (StringUtils.isNullOrEmpty(_searchText)) {
      _adminListMeetingController.sink.add(_adminListMeetingOrigin);
      return;
    }

    var _result = _adminListMeetingOrigin
        .where((test) =>
            test.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    _adminListMeetingController.sink.add(_result);
  }

  Future<TResult> createMeeting(MeetingObjRequest _data) async {
    final _response = await _meetingRepository.createMeeting(_data);
    return _response;
  }

  Future<TResult> updateMeeting(MeetingObjRequest _data) async {
    final _response = await _meetingRepository.updateMeeting(_data);
    return _response;
  }

  Future<TResult> getMeetingById(String id) async {
    final _response = await _meetingRepository.getMeetingById(id);
    MeetingObjInput _meetingObjInput = _response.data;
    //set value init
    _meetingNameInputController.sink.add(_meetingObjInput.name);
    _meetingAddressInputController.sink.add(_meetingObjInput.address);
    _meetingMemberInputController.sink.add(_meetingObjInput.memberList);
    _meetingDateResInputController.sink.add(_meetingObjInput.meetingDate);
    _meetingElementInputController.sink.add(_meetingObjInput.element);
    _meetingNoteInputController.sink.add(_meetingObjInput.note);
    _meetingGuestInputController.sink.add(_meetingObjInput.guest);
    _meetingEndDateResInputController.sink.add(_meetingObjInput.meetingEndDate);

    return _response;
  }

  getListAdmin(List<dynamic> stringList) async {
    final res = await _meetingRepository.getAccount();
    final _data = List<AccountOut>.from(res.data);
    _adminListMeetingMain =
        _data.map((item) => new AccountOut.clone(item)).toList();

    //reset value
    if (stringList != null && stringList.length > 0) {
      for (var i = 0; i < stringList.length; i++) {
        bool isHasSystem = false;
        for (var j = 0; j < _data.length; j++) {
          if (stringList[i].toString() == _data[j].id) {
            isHasSystem = true;
            _data[j].selected = true;
            break;
          }
        }

        if (isHasSystem == false) {
          _data.add(AccountOut(
            id: stringList[i].toString(),
            personalID: '', // hoặc giá trị phù hợp
            name: stringList[i].toString(),
            avatar: '',
            type: constants.TYPE_OTHER,
            selected: true,
          ));
        }
      }
      _data.sort((a, b) =>
          a.selected.toString().length.compareTo(b.selected.toString().length));
    }

    _adminListMeetingController.sink.add(_data);
    _adminListMeetingOrigin =
        _data.map((item) => new AccountOut.clone(item)).toList();
  }

  getListUser(String _searchTxt, List<dynamic> stringList) async {
    final _userMeetingInput = UserMeetingInput(
        searchTxt: _searchTxt, adminList: this.onGetMeetingAdminInput());
    final res = await _meetingRepository.getUserList(_userMeetingInput);
    final _data = List<UserMeetingOutput>.from(res.data);
    _userListMeetingMain =
        _data.map((item) => new UserMeetingOutput.clone(item)).toList();
    //reset value
    if (stringList != null && stringList.length > 0) {
      for (var i = 0; i < stringList.length; i++) {
        bool isHasSystem = false;
        for (var j = 0; j < _userListMeetingMain.length; j++) {
          if (stringList[i].toString() == _userListMeetingMain[j].id) {
            isHasSystem = true;
            _data[j].selected = true;
            break;
          }
        }

        if (isHasSystem == false) {
          _data.add(UserMeetingOutput(
            id: stringList[i].toString(),
            name: stringList[i].toString(),
            phone: '', // gán mặc định nếu không có
            avatar: '', // gán mặc định nếu không có
            type: constants.TYPE_OTHER,
            selected: true,
            disable: false, // gán mặc định nếu không có
          ));
        }
      }
      _data.sort((a, b) =>
          a.selected.toString().length.compareTo(b.selected.toString().length));
    }
    _userListMeetingController.sink.add(_data);
    _userListMeetingOrigin =
        _data.map((item) => new UserMeetingOutput.clone(item)).toList();
  }

  Future<TResult> onStartEndMeetingByQRCode(String _meetingID) async {
    final _response =
        await _meetingRepository.onStartEndMeetingByQRCode(_meetingID);
    return _response;
  }

  Future<TResult> onCheckinByQRCode(String _qrCode) async {
    final prefs = await SharedPreferences.getInstance();
    final _qrScanParam = QRScanInput(
        qrCode: _qrCode, personalID: prefs.getString('personalID') ?? '');
    final _response = await _meetingRepository.checkinByQRCode(_qrScanParam);

    return _response;
  }

  @override
  void dispose() {
    _meetingIdController?.close();
    _isHasNetworController?.close();
    _meetingListStreamController?.close();
    _eventListStreamController?.close();
    _assignListMeetingController?.close();
    _isMeetingEndedController?.close();
    _tabCurrentNameController?.close();
    _keepAliveForAdminWebViewTabController?.close();
    _actionSelecteFlgController?.close();
    _meetingCountController?.close();
    _roleAppController.close();
    _meetingAdminInputController.close();
    _meetingMemberInputController.close();
    _meetingDateResInputController.close();
    _meetingNameInputController.close();
    _meetingAddressInputController.close();
    _actionWeekSelectedController?.close();
    _meetingElementInputController.close();
    _meetingNoteInputController.close();
    _meetingGuestInputController.close();
    _meetingEndDateResInputController.close();
  }
}
