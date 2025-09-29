import 'dart:convert';
import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/voting.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:web_socket_channel/io.dart';

class VotingRepository {
  final _provider = ApiProvider();

  Future<TResult> getProblems(ProblemInput data) async {
    final response =
        await _provider.post(api.URL_VOTING_PROBLEM, jsonEncode(data));

    List<ProblemOutput> _problems = [];
    if (response['Status'] == 1) {
      final _problemsData = response['Data'].cast<Map<String, dynamic>>();
      _problems = _problemsData.map<ProblemOutput>((meeting) {
        return ProblemOutput.fromJson(meeting);
      }).toList();
    }

    return TResult(
        status: response['Status'],
        data: _problems,
        msg: response['Msg'] ?? '');
  }

  Future<TResult> getQuestionByProblemId(QuestionInput data) async {
    final response = await _provider.post(
        api.URL_VOTING_QUESTION_BY_PROBLEMID, jsonEncode(data));

    List<QuestionOutput> _questionOutput = [];
    if (response['Status'] == 1) {
      final _questionOutputData = response['Data'].cast<Map<String, dynamic>>();
      _questionOutput = _questionOutputData.map<QuestionOutput>((event) {
        return QuestionOutput.fromJson(event);
      }).toList();
    }

    return TResult(
        status: response['Status'],
        data: _questionOutput,
        msg: response['Msg'] ?? '');
  }

  Future<TResult> onAnwserSelected(AnwserInput data) async {
    final response =
        await _provider.post(api.URL_VOTING_ANWSER_SELECTED, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> checkCompleteProblem(CompleteProblemInput data) async {
    final response =
        await _provider.post(api.URL_VOTING_COMPLETE_PROBLEM, jsonEncode(data));

    CompleteOutput? _completeOutput;
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      _completeOutput = CompleteOutput(
          isComplete: _data['IsComplete'], isEndFlg: _data['IsEndFlg']);
    }
    return TResult(
        status: response['Status'],
        data: _completeOutput,
        msg: response['Msg'] ?? '');
  }

  Future<TResult> checkAllowVoting(AllowInput data) async {
    final response =
        await _provider.post(api.URL_VOTING_CHECK_ALLOW, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> checkDeclareVoting(DeclareInput data) async {
    final response =
        await _provider.post(api.URL_VOTING_CHECK_DECLARE, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> getBQResultByProblemId(QuestionResultInput data) async {
    final response = await _provider.post(
        api.URL_VOTING_QUESTION_RESULT_BY_PROBLEMID, jsonEncode(data));

    List<QuestionResultOutput> _questionOutput = [];
    if (response['Status'] == 1) {
      final _questionOutputData =
          response['Data']['QuestionResultData'].cast<Map<String, dynamic>>();
      _questionOutput = _questionOutputData.map<QuestionResultOutput>((event) {
        return QuestionResultOutput.fromJson(event);
      }).toList();
    }

    final _res = QuestionFinalResultOutput(
        totalUserJoin: response['Data']['TotalUserJoin'],
        questionResults: _questionOutput);

    return TResult(
        status: response['Status'], data: _res, msg: response['Msg'] ?? '');
  }

  Future<TResult> getBCResultByProblemId(String problemId) async {
    final response =
        await _provider.get(api.URL_VOTING_BC_RESULT + '?problemId=$problemId');

    List<BCResultOutput> _resultOutput = [];
    if (response['Status'] == 1) {
      final _resultOutputData = response['Data'].cast<Map<String, dynamic>>();
      _resultOutput = _resultOutputData.map<BCResultOutput>((event) {
        return BCResultOutput.fromJson(event);
      }).toList();
    }

    return TResult(
        status: response['Status'],
        data: _resultOutput,
        msg: response['Msg'] ?? '');
  }

  // admin
  Future<TResult> startVoting(AllowInput data) async {
    final response =
        await _provider.post(api.URL_VOTING_ADMIN_START, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> endVoting(AllowInput data) async {
    final response =
        await _provider.post(api.URL_VOTING_ADMIN_END, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<IOWebSocketChannel> openProgressWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_PROGRESS);
  }

  Future<IOWebSocketChannel> openVotingDeclareWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_VOTING_DECLARE);
  }

  Future<IOWebSocketChannel> openVotingStartWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_VOTING_START);
  }

  Future<IOWebSocketChannel> openVotingEndWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_VOTING_END);
  }
}
