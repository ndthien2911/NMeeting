import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/idea.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/idea-repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class IdeaBloc extends BaseBloc {
  // repository
  final _ideaRepository = new IdeaRepository();

  // meeting ID
  final _ideaIdController = BehaviorSubject<String>();
  Stream<String> get ideaIdStream => _ideaIdController.stream;

  // meeting Id
  final _meetingIdController = BehaviorSubject<String>();
  Stream<String> get meetingIdStream => _meetingIdController.stream;

  // network
  final _isHasNetworController = BehaviorSubject<bool>();
  Stream<bool> get isHasNetworkStream => _isHasNetworController.stream;

  final _eventListStreamController =
      StreamController<Map<DateTime, List<String>>>();
  Stream<Map<DateTime, List<String>>> get eventListStream =>
      _eventListStreamController.stream;

  var _ideaCnt = StreamController<int>();
  Stream<int> get ideaCnt => _ideaCnt.stream;

  var _limit = StreamController<int>();
  Stream<int> get getLimitCur => _limit.stream;

  var _offset = StreamController<int>();
  Stream<int> get getOffsetCur => _offset.stream;

  var _startFlg = BehaviorSubject<bool>();
  Stream<bool> get getStartFlg => _startFlg.stream;

  var _ideaId = BehaviorSubject<String>();
  Stream<String> get getIdeaId => _ideaId.stream;

  var _accountHasRegist = BehaviorSubject<bool>();
  Stream<bool> get getAccountHasRegist => _accountHasRegist.stream;

  var _ideaDetailId = BehaviorSubject<String>();
  Stream<String> get getIdeaDetailId => _ideaDetailId.stream;

  onNetworkChanged(bool _status) async {
    _isHasNetworController.sink.add(_status);
  }

  startCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final _inputParam = IdeaInput(
        personalID: prefs.getString('personalID'),
        meetingID: _meetingIdController.value);
    final _response = await _ideaRepository.startCheck(_inputParam);
    if (_response.status == 1) {
      StartCheckResp _mapEvents = _response.data;
      _startFlg.sink.add(_mapEvents.startFlg);
      _ideaId.sink.add(_mapEvents.ideaID);
      _accountHasRegist.sink.add(_mapEvents.accountHasRegist);
    }
  }

  // Future<TResult> sendRegist() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final _inputParam = IdeaInput(
  //       personalID: prefs.getString('personalID'), ideaID: _ideaId.value);
  //   final _response = await _ideaRepository.sendRegist(_inputParam);

  //   if (_response.status == 1) {
  //     _accountHasRegist.sink.add(_response.data);
  //   }
  //   return _response;
  // }

  Future<String> registCheck() async {
    var _msg = '';
    final _inputParam = IdeaInput(ideaID: _ideaId.value);
    final _response = await _ideaRepository.registCheck(_inputParam);
    if (_response.status == 1) {
      RegistCheckResp _mapEvents = _response.data;
      if (_ideaDetailId.value != _mapEvents.id) {
        _ideaDetailId.sink.add(_mapEvents.id);
        if (_response.msg != null && _response.msg != "") {
          _msg = _response.msg;
        }
      }
    }

    return _msg;
  }

  Future<TResult> endIdea(ideaDetailID, description) async {
    final _response = await _ideaRepository.endIdea(ideaDetailID, description);
    return _response;
  }

  Future<TResult> startIdea(ideaDetailID) async {
    final _response = await _ideaRepository.startIdea(ideaDetailID);
    return _response;
  }

  onSetNotifyId(String _ideaId) {
    _ideaIdController.sink.add(_ideaId);
  }

  onSetLimitCur(int _limitCur) {
    _limit.sink.add(_limitCur);
  }

  onSetOffsetCur(int _offsetCur) {
    _offset.sink.add(_offsetCur);
  }

  onSetMeetingId(String _id) {
    _meetingIdController.sink.add(_id);
  }

  Future<IOWebSocketChannel> openIdeaWebSocketChannel() {
    return _ideaRepository.openIdeaWebSocketChannel();
  }

  @override
  void dispose() {
    _ideaIdController?.close();
    _meetingIdController?.close();
    _isHasNetworController?.close();
    _ideaCnt?.close();
    _limit?.close();
    _offset?.close();
    _startFlg?.close();
    _ideaId?.close();
    _ideaDetailId?.close();
    _eventListStreamController?.close();
    _accountHasRegist?.close();
  }
}
