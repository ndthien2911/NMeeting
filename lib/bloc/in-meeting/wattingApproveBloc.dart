import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/in-meeting/wattingApprove.dart';
import 'package:nmeeting/repository/in-meeting/watting-approve-repository.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:nmeeting/configs/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';

class WattingApproveBloc extends BaseBloc {
  // repository
  final _wattingApproveRepository = new WattingApproveRepository();
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

  List<String> getListIDSelected() {
    return listIDSelected;
  }

  onSetMeetingId(String _id) {
    _meetingIdController.sink.add(_id);
  }

  onSetMeetingList(list) {
    _meetingListStreamController.sink.add(list);
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
        statusVal: 0,
        pageID: constants.PAGE_ID_FOR_APP,
        weekSelectedValue: _weekSelectedValue);
    final _response = await _wattingApproveRepository.getAll(_dataInput);
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
        if (listMeeting[i].hiddenRejectFlg == true) {
          selectFlg = false;
        }
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
      if (listMeeting[i].hiddenRejectFlg == true) {
        selectFlg = false;
      }
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

  changeMode(int mode, int statusVal) async {
    if (listIDSelected.length > 0) {
      final _dataInput = ChangeModeInput(
          idList: StringUtils.convertListToString(listIDSelected),
          modeVal: mode,
          statusVal: statusVal);
      final _response = await _wattingApproveRepository.changeMode(_dataInput);
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

  revertStatus(int mode, int statusVal, String idItem) {
    listIDSelected = new List<String>();
    listIDSelected.add(idItem);
    changeMode(mode, statusVal);
  }

  deleteItem(int statusVal, String idItem) async {
    if (idItem != null && idItem != "") {
      List<String> listIDDelete = new List<String>();
      listIDDelete.add(idItem);
      final _dataInput =
          DeleteInput(idList: StringUtils.convertListToString(listIDDelete));
      final _response = await _wattingApproveRepository.deleteItem(_dataInput);
      if (_response.status == 1) {
        for (var i = 0; i < listMeeting.length; i++) {
          if (listMeeting[i].id == idItem) {
            listMeeting.remove(listMeeting[i]);
            break;
          }
        }

        for (var j = 0; j < listIDSelected.length; j++) {
          if (listIDSelected[j] == idItem) {
            listIDSelected.remove(listIDSelected[j]);
            break;
          }
        }

        _meetingListStreamController.sink.add(listMeeting);
        _meetingCountController.sink.add(null);
        _meetingCountController.sink.add(listMeeting.length);

        return constants.STATUS_SUCCESS;
      } else {
        return _response.msg;
      }
    } else {
      return "Please select at least 1 meeting!";
    }
  }

  rejectItem(int statusVal, String idItem) async {
    if (idItem != null && idItem != "") {
      List<String> listIDReject = new List<String>();
      listIDReject.add(idItem);
      final prefs = await SharedPreferences.getInstance();
      final _dataInput = RejectInput(
          idList: StringUtils.convertListToString(listIDReject),
          personalID: prefs.getString('personalID'));
      final _response = await _wattingApproveRepository.rejectItem(_dataInput);
      if (_response.status == 1) {
        for (var i = 0; i < listMeeting.length; i++) {
          if (listMeeting[i].id == idItem) {
            listMeeting[i].approveFlg = constants.STATUS_MEETING_REJECT;
            break;
          }
        }

        // for(var j = 0 ; j < listIDSelected.length; j++) {
        //   if(listIDSelected[j] == idItem) {
        //     listIDSelected.remove(listIDSelected[j]);
        //     break;
        //   }
        // }

        _meetingListStreamController.sink.add(listMeeting);
        _meetingCountController.sink.add(null);
        _meetingCountController.sink.add(listMeeting.length);

        return constants.STATUS_SUCCESS;
      } else {
        return _response.msg;
      }
    } else {
      return "Please select at least 1 meeting!";
    }
  }

  @override
  void dispose() {
    _meetingIdController?.close();
    _meetingListStreamController?.close();
    _meetingCountController.close();
  }
}
