import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/in-meeting/approved.dart';
import 'package:nmeeting/repository/in-meeting/approved-repository.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:nmeeting/configs/constants.dart' as constants;

class ApprovedBloc extends BaseBloc {
  // repository
  final _approveRepository = new ApprovedRepository();
  List<MeetingObj> listMeeting = new List<MeetingObj>();
  List<String> listIDSelected = new List<String>();

  // meeting Id
  final _meetingIdController = BehaviorSubject<String>();
  Stream<String> get meetingIdStream => _meetingIdController.stream;

  //Count list
  final _meetingCountController = BehaviorSubject<int>();
  Stream<int> get meetingCountStream => _meetingCountController.stream;

  // controller
  final _meetingListStreamController = StreamController<List<MeetingObj>>();
  Stream<List<MeetingObj>> get meetingListStream =>
      _meetingListStreamController.stream;

  onSetMeetingId(String _id) {
    _meetingIdController.sink.add(_id);
  }

  onSetMeetingList(list) {
    _meetingListStreamController.sink.add(list);
  }

  List<String> getListIDSelected() {
    return listIDSelected;
  }

  onSetMeetingCount(int _cnt) {
    _meetingCountController.sink.add(_cnt);
  }

  int onGetMeetingCount() {
    return (_meetingCountController.value != null)
        ? _meetingCountController.value
        : 0;
  }

  getAll(int _weekSelectedValue) async {
    final _dataInput = DataInput(
        statusVal: 1,
        pageID: constants.PAGE_ID_FOR_APP,
        weekSelectedValue: _weekSelectedValue);
    final _response = await _approveRepository.getAll(_dataInput);
    if (_response.status == 1) {
      _meetingListStreamController.sink.add(_response.data);
      listMeeting = _response.data;
      _meetingCountController.sink.add(null);
      _meetingCountController.sink.add(listMeeting.length);
      listIDSelected = new List<String>();
    }
  }

  clickItem(String itemID, bool selectFlg) async {
    for (var i = 0; i < listMeeting.length; i++) {
      if (itemID == listMeeting[i].id) {
        listMeeting[i].selectFlg = selectFlg;
        if (selectFlg == true) {
          if (!listIDSelected.contains(listMeeting[i].id)) {
            listIDSelected.add(listMeeting[i].id);
          }
        } else {
          listIDSelected.remove(listMeeting[i].id);
        }
      }
    }

    _meetingListStreamController.sink.add(listMeeting);
  }

  clickAllItem(bool selectFlg) async {
    for (var i = 0; i < listMeeting.length; i++) {
      listMeeting[i].selectFlg = selectFlg;
      if (selectFlg == true) {
        if (!listIDSelected.contains(listMeeting[i].id)) {
          listIDSelected.add(listMeeting[i].id);
        }
      } else {
        listIDSelected.remove(listMeeting[i].id);
      }
    }

    _meetingListStreamController.sink.add(listMeeting);
  }

  checkHasSelect() {
    if (listIDSelected.length > 0) {
      return true;
    }

    return false;
  }

  Future<String> changeMode(
      int mode, int statusVal, bool hiddenRejectFlg) async {
    if (hiddenRejectFlg) {
      return "Lịch họp đã gửi lên đơn vị VTTP. Bạn không thể bỏ duyệt";
    }

    if (listIDSelected.length > 0) {
      final _dataInput = ChangeModeInput(
          idList: StringUtils.convertListToString(listIDSelected),
          modeVal: mode,
          statusVal: statusVal);
      final _response = await _approveRepository.changeMode(_dataInput);
      if (_response.status == 1) {
        //_meetingListStreamController.sink.add(_response.data);
        //listMeeting = _response.data;
        //_meetingCountController.sink.add(null);
        //_meetingCountController.sink.add(listMeeting.length);
        //refresh
        listIDSelected = new List<String>();
        //ok
        return constants.STATUS_SUCCESS;
      } else {
        return _response.msg;
      }
    } else {
      return "Please select at least 1 meeting!";
    }
  }

  Future<String> revertStatus(
      int mode, int statusVal, String idItem, bool hiddenRejectFlg) {
    listIDSelected = new List<String>();
    listIDSelected.add(idItem);
    return changeMode(mode, statusVal, hiddenRejectFlg);
  }

  @override
  void dispose() {
    _meetingIdController?.close();
    _meetingListStreamController?.close();
    _meetingCountController.close();
  }
}
