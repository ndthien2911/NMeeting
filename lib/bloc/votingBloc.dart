import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/voting.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/voting-repository.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class VotingBloc extends BaseBloc {
  // repository
  final _votingRepository = new VotingRepository();

  // meeting Id
  final _meetingIdController = BehaviorSubject<String>();
  Stream<String> get meetingIdStream => _meetingIdController.stream;

  // problem Id
  final _problemIdController = BehaviorSubject<String>();
  Stream<String> get problemIdStream => _problemIdController.stream;

  // problem name
  final _problemNameController = BehaviorSubject<String>();
  Stream<String> get problemNameStream => _problemNameController.stream;

  // problem index
  final _problemIndexController = BehaviorSubject<String>();
  Stream<String> get problemIndexStream => _problemIndexController.stream;

  // List
  // controller
  final _problemListStreamController =
      StreamController<List<ProblemOutput>>.broadcast();
  // stream
  Stream<List<ProblemOutput>> get problemListStream =>
      _problemListStreamController.stream.asBroadcastStream();

  // controller
  var _questionListStreamController = StreamController<List<QuestionOutput>>();
  // stream
  Stream<List<QuestionOutput>> get questionListStream =>
      _questionListStreamController.stream;

  // controller
  var _questionResultStreamController =
      StreamController<QuestionFinalResultOutput?>();
  // stream
  Stream<QuestionFinalResultOutput?> get questionResultStream =>
      _questionResultStreamController.stream;

  // controller
  var _indicatorListStreamController = StreamController<List<Widget>>();
  // stream
  Stream<List<Widget>> get indicatorListStream =>
      _indicatorListStreamController.stream;

  // is complete problem
  final _isCompleteProblemController = BehaviorSubject<CompleteOutput>();
  Stream<CompleteOutput> get isCompleteProblemStream =>
      _isCompleteProblemController.stream;

  // group ID
  final _groupIdController = BehaviorSubject<int>();
  Stream<int> get groupIdStream => _groupIdController.stream;

  // member role
  final _memberRoleController = BehaviorSubject<int>();
  Stream<int> get memberRoleStream => _memberRoleController.stream;

// controller
  late var _bcResultListStreamController =
      BehaviorSubject<List<BCResultOutput>>();
// stream
  Stream<List<BCResultOutput>> get bcResultListStream =>
      _bcResultListStreamController.stream;

// controller
  final _bcQuestionNameStreamController = BehaviorSubject<String>();
// stream
  Stream<String> get bcQuestionNameStream =>
      _bcQuestionNameStreamController.stream;

  List<Widget> _listIndicator = [];
  List<QuestionOutput> _listQuestion = [];
  QuestionFinalResultOutput? _questionResult;

  int firstIndexQuestionNoAnwser = 0;

  onSetMeetingId(String _id) {
    _meetingIdController.sink.add(_id);
  }

  String onGetMeetingId() {
    return _meetingIdController.value;
  }

  onSetProlemId(String _id) {
    _problemIdController.sink.add(_id);
  }

  String onGetProlemId() {
    return _problemIdController.value;
  }

  onSetProlemName(String _name) {
    _problemNameController.sink.add(_name);
  }

  onSetProlemIndex(String _index) {
    _problemIndexController.sink.add(_index);
  }

  onSetCompleteProblem(CompleteOutput _value) {
    _isCompleteProblemController.sink.add(_value);
  }

  onSetGroupId(int _value) {
    _groupIdController.sink.add(_value);
  }

  onSetMemberRole(int _value) {
    _memberRoleController.sink.add(_value);
  }

  onSetbcQuestionName(int _pageIndex) {
    var _name = _bcResultListStreamController.value[_pageIndex].questionName;
    _bcQuestionNameStreamController.sink.add(_name);
  }

  getProblems() async {
    final prefs = await SharedPreferences.getInstance();
    final _problemInput = ProblemInput(
        meetingID: _meetingIdController.value,
        personalID: prefs.getString('personalID') ?? '');
    final _response = await _votingRepository.getProblems(_problemInput);
    if (_response.status == 1) {
      _problemListStreamController.sink.add(_response.data);
    } else {
      _problemListStreamController.sink.add([]);
    }
  }

  Future<TResult> getProblemsForVotingStartWs() async {
    final prefs = await SharedPreferences.getInstance();
    final _problemInput = ProblemInput(
        meetingID: _meetingIdController.value,
        personalID: prefs.getString('personalID') ?? '');
    final _response = await _votingRepository.getProblems(_problemInput);
    return _response;
  }

  getQuestionByProblemId() async {
    _questionListStreamController = StreamController<List<QuestionOutput>>();
    _questionListStreamController.sink.add([]);
    _indicatorListStreamController = StreamController<List<Widget>>();
    _indicatorListStreamController.sink.add([]);
    _listQuestion = [];

    final prefs = await SharedPreferences.getInstance();

    final _questionInput = QuestionInput(
        problemID: _problemIdController.value,
        personalID: prefs.getString('personalID') ?? '');
    final _response =
        await _votingRepository.getQuestionByProblemId(_questionInput);
    if (_response.status == 1) {
      _listQuestion = _response.data;
      _questionListStreamController.sink.add(_listQuestion);

      firstIndexQuestionNoAnwser = _listQuestion
          .indexWhere((test) => test.answers.every((test) => !test.isChosen));

      _buildIndicator(firstIndexQuestionNoAnwser, _listQuestion.length);
    }
  }

  onChoosen(String _questionId, String _anwserId) {
    // biểu quyết chọn 1 đáp án
    if (_groupIdController.value == 0) {
      for (var _item in _listQuestion) {
        if (_item.questionID == _questionId) {
          for (var _a in _item.answers) {
            if (_a.id == _anwserId) {
              _a.isChosen = true;
            } else {
              _a.isChosen = false;
            }
          }
        }
      }
    }

    // bầu cử chọn tự do
    if (_groupIdController.value == 1) {
      for (var _item in _listQuestion) {
        if (_item.questionID == _questionId) {
          for (var _a in _item.answers) {
            if (_a.id == _anwserId) {
              _a.isChosen = !_a.isChosen;
            }
          }
        }
      }
    }

    _questionListStreamController.sink.add(_listQuestion);
  }

  bool checkBCAnwserIsValid(List<Answer> _anwsers) {
    return !(_anwsers.every((test) => test.isChosen == true) ||
        _anwsers.every((test) => test.isChosen == false));
  }

  Future<TResult> onAnwserSelected(
      String _questionId, List<Answer> _anwsers, bool _isAnswerValid) async {
    final prefs = await SharedPreferences.getInstance();
    final _anwserInput = AnwserInput(
        answerIDs: _groupIdController.value == 0
            ? _anwsers.where((test) => test.isChosen).map((f) => f.id).toList()
            : _anwsers
                .where((test) => !test.isChosen)
                .map((f) => f.id)
                .toList(),
        personalID: prefs.getString('personalID') ?? '',
        questionID: _questionId,
        problemID: _problemIdController.value,
        isAnswerValid: _isAnswerValid);
    final _response = await _votingRepository.onAnwserSelected(_anwserInput);

    return _response;
  }

  Future<TResult> checkCompleteProblem() async {
    final prefs = await SharedPreferences.getInstance();
    final _completeProblemInput = CompleteProblemInput(
        personalID: prefs.getString('personalID') ?? '',
        problemID: _problemIdController.value);
    final _response =
        await _votingRepository.checkCompleteProblem(_completeProblemInput);

    _isCompleteProblemController.sink.add(_response.data);

    return _response;
  }

  Future<TResult> checkAllowVoting() async {
    final _allowInput = AllowInput(problemID: _problemIdController.value);
    final _response = await _votingRepository.checkAllowVoting(_allowInput);

    return _response;
  }

  Future<TResult> checkDeclareVoting() async {
    final _declareInput = DeclareInput(problemID: _problemIdController.value);
    final _response = await _votingRepository.checkDeclareVoting(_declareInput);

    return _response;
  }

  Future<TResult> startVoting() async {
    final prefs = await SharedPreferences.getInstance();
    final _allowInput = AllowInput(
        problemID: _problemIdController.value,
        personalID: prefs.getString('personalID') ?? '');
    final _response = await _votingRepository.startVoting(_allowInput);

    return _response;
  }

  Future<TResult> endVoting() async {
    final prefs = await SharedPreferences.getInstance();
    final _allowInput = AllowInput(
        problemID: _problemIdController.value,
        personalID: prefs.getString('personalID') ?? '');
    final _response = await _votingRepository.endVoting(_allowInput);

    return _response;
  }

  onChangedPageView(int _index) {
    _buildIndicator(_index, _listIndicator.length);
  }

  // _onChangedIndicator(int _index) {
  //   print('jump $_index');
  //   _buildIndicator(_index, _listIndicator.length);
  // }

  // page BQ result
  getBQResultByProblemId() async {
    _questionResultStreamController =
        StreamController<QuestionFinalResultOutput>();
    _questionResultStreamController.sink.add(null);
    _indicatorListStreamController = StreamController<List<Widget>>();
    _indicatorListStreamController.sink.add([]);
    _questionResult = null;

    final _questionInput = QuestionResultInput(
        meetingID: _meetingIdController.value,
        groupID: _groupIdController.value,
        problemID: _problemIdController.value);
    final _response =
        await _votingRepository.getBQResultByProblemId(_questionInput);
    if (_response.status == 1) {
      _questionResult = _response.data;
      _questionResultStreamController.sink.add(_questionResult);

      _buildIndicator(0, _questionResult!.questionResults!.length);
    }
  }

  getBCResultByProblemId() async {
    _bcResultListStreamController = BehaviorSubject<List<BCResultOutput>>();
    _bcResultListStreamController.sink.add([]);
    _indicatorListStreamController = StreamController<List<Widget>>();
    _indicatorListStreamController.sink.add([]);

    final _response = await _votingRepository
        .getBCResultByProblemId(_problemIdController.value);
    if (_response.status == 1) {
      _bcResultListStreamController.sink.add(_response.data);

      _buildIndicator(0, _response.data.length);
    }
  }

  _buildIndicator(int _indexActive, int _length) {
    _listIndicator.clear();
    for (var i = 0; i < _length; i++) {
      if (i == _indexActive) {
        _listIndicator.add(
          GestureDetector(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(250, 30, 37, 239),
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 3, left: i < 9 ? 10 : 3),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ],
            ),
            onTap: () {
              //_onChangedIndicator(i);
            },
          ),
        );
      } else {
        _listIndicator.add(
          GestureDetector(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: Color.fromARGB(250, 30, 37, 239),
                              width: 2)),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 3, left: i < 9 ? 10 : 3),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                              color: Color.fromARGB(250, 30, 37, 239),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ],
            ),
            onTap: () {},
          ),
        );
      }
    }
    _indicatorListStreamController.sink.add(_listIndicator);
  }

  Future<IOWebSocketChannel> openProgressWebSocketChannel() {
    return _votingRepository.openProgressWebSocketChannel();
  }

  Future<IOWebSocketChannel> openVotingDeclareWebSocketChannel() {
    return _votingRepository.openVotingDeclareWebSocketChannel();
  }

  Future<IOWebSocketChannel> openVotingStartWebSocketChannel() {
    return _votingRepository.openVotingStartWebSocketChannel();
  }

  Future<IOWebSocketChannel> openVotingEndWebSocketChannel() {
    return _votingRepository.openVotingEndWebSocketChannel();
  }

  @override
  void dispose() {
    _meetingIdController?.close();
    _problemIdController?.close();
    _problemNameController?.close();
    _problemIndexController?.close();
    _problemListStreamController?.close();
    _questionListStreamController?.close();
    _indicatorListStreamController?.close();
    _isCompleteProblemController?.close();
    _questionResultStreamController?.close();
    _groupIdController?.close();
    _memberRoleController?.close();
    _bcResultListStreamController?.close();
    _bcQuestionNameStreamController?.close();
  }
}
