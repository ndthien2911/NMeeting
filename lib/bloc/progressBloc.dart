import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/idea.dart';
import 'package:nmeeting/models/in-meeting.dart';
import 'package:nmeeting/models/progress.dart';
import 'package:nmeeting/models/voting.dart';
import 'package:nmeeting/repository/progress-repository.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class ProgressBloc extends BaseBloc {
  // repository
  final _progressRepository = new ProgressRepository();

  // meeting Id
  final _meetingIdController = BehaviorSubject<String>();
  Stream<String> get meetingIdStream => _meetingIdController.stream;

  // meeting Name
  final _meetingNameController = BehaviorSubject<String>();
  Stream<String> get meetingNameStream => _meetingNameController.stream;

  // controller
  final _progressListStreamController =
      StreamController<ProgressIdea>.broadcast();
  Stream<ProgressIdea> get progressListStream =>
      _progressListStreamController.stream.asBroadcastStream();

  // voting newest Name
  final _votingNewestNameController = BehaviorSubject<String>();
  Stream<String> get votingNewestNameStream =>
      _votingNewestNameController.stream;

  onSetMeetingId(String _meetingId) {
    _meetingIdController.sink.add(_meetingId);
  }

  String onGetMeetingId() {
    return _meetingIdController.value;
  }

  onSetMeetingName(String _meetingName) {
    _meetingNameController.sink.add(_meetingName);
  }

  String onGetMeetingName() {
    return _meetingNameController.value;
  }

  getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final _progressInput = ProgressInput(
        meetingID: _meetingIdController.value,
        personalID: prefs.getString('personalID'));
    final _response = await _progressRepository.getAllProgress(_progressInput);
    if (_response.status == 1) {
      _progressListStreamController.sink.add(_response.data);
    }
  }

  Future<TResult> checkIsInMeeting(var meetingID) async {
    final prefs = await SharedPreferences.getInstance();
    final _inMeetingInput = {
      'personalID': prefs.getString('personalID'),
      'meetingID': meetingID
    };

    final res = await _progressRepository.checkIsInMeeting(_inMeetingInput);
    return res;
  }

  Future<TResult> getQuestionByProblemId(String _problemId) async {
    final prefs = await SharedPreferences.getInstance();
    final _questionInput = QuestionInput(
        problemID: _problemId, personalID: prefs.getString('personalID') ?? '');
    final res =
        await _progressRepository.getQuestionByProblemId(_questionInput);
    return res;
  }

  Future<TResult> onAnwserSelected(
      String _questionId, String _anwserSelected, bool _isAnswerValid) async {
    final prefs = await SharedPreferences.getInstance();
    final _anwserInput = {
      'answerIDs': [_anwserSelected],
      'personalID': prefs.getString('personalID'),
      'questionID': _questionId,
      'isAnswerValid': _isAnswerValid
    };
    final _response = await _progressRepository.onAnwserSelected(_anwserInput);

    return _response;
  }

  // page BQ result
  Future<TResult> getBQResultByProblemId(String _problemId) async {
    final _questionInput = QuestionResultInput(
        meetingID: _meetingIdController.value,
        groupID: 0,
        problemID: _problemId);
    final _response =
        await _progressRepository.getBQResultByProblemId(_questionInput);

    return _response;
  }

  Future<TResult> sendRegist(ideaID) async {
    final prefs = await SharedPreferences.getInstance();
    final _inputParam = IdeaInput(
        personalID: prefs.getString('personalID') ?? '', ideaID: ideaID);
    final _response = await _progressRepository.sendRegist(_inputParam);

    return _response;
  }

  Future<IOWebSocketChannel> openProgressWebSocketChannel() {
    return _progressRepository.openProgressWebSocketChannel();
  }

  Future<IOWebSocketChannel> openStartEndMeetingWebSocketChannel() {
    return _progressRepository.openStartEndMeetingWebSocketChannel();
  }

  @override
  void dispose() {
    _meetingIdController?.close();
    _meetingNameController?.close();
    _progressListStreamController?.close();
    _votingNewestNameController?.close();
  }
}
