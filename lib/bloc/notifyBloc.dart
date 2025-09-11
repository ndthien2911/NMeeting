import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/notify.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/notify-repository.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class NotifyBloc extends BaseBloc {
  // repository
  final _notifyRepository = new NotifyRepository();

  var _notifyListController = StreamController<List<NotifyObj>>();
  Stream<List<NotifyObj>> get notifyListStream => _notifyListController.stream;

  var _notifyCntAllController = StreamController<int>();
  Stream<int> get notifyCntAllStream => _notifyCntAllController.stream;

  var _notifyCntNotSeenController = StreamController<int>();
  Stream<int> get notifyCntNotSeenStream => _notifyCntNotSeenController.stream;

  onGetNotifyList() async {
    _notifyListController = StreamController<List<NotifyObj>>();
    _notifyListController.sink.add([]);
    final prefs = await SharedPreferences.getInstance();
    final _inputParam = NotifyInput(
      personalID: prefs.getString('personalID') ?? '',
    );
    final _response =
        await _notifyRepository.getNotifyWithPersonalID(_inputParam);
    if (_response.status == 1) {
      NotifyRes _mapEvents = _response.data;
      _notifyListController.sink.add(_mapEvents.notifyList);
      _notifyCntAllController.sink.add(_mapEvents.notifyCnt);
      _notifyCntNotSeenController.sink.add(0);
    }
  }

  onGetCountNotifyNotSeen() async {
    final prefs = await SharedPreferences.getInstance();

    final _response = await _notifyRepository
        .countNotifyNotSeenWithPersonalID(prefs.getString('personalID') ?? '');
    if (_response.status == 1) {
      _notifyCntNotSeenController.sink.add(_response.data);
    }
  }

  Future<TResult> getUsersByMeetingIDs(List<String> listIDSelected) async {
    final _dataInput = NotifyByMeetingIdsInput(
      meetingIDs: StringUtils.convertListToString(listIDSelected),
    );

    final _response = await _notifyRepository.getUsersByMeetingIDs(_dataInput);
    return _response;
  }

  Future<IOWebSocketChannel> openNotifyWebSocketChannel() {
    return _notifyRepository.openNotifyWebSocketChannel();
  }

  @override
  void dispose() {
    _notifyListController?.close();
    _notifyCntAllController?.close();
    _notifyCntNotSeenController?.close();
  }
}
