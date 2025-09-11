import 'dart:convert';
import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/idea.dart';
import 'package:nmeeting/models/in-meeting.dart';
import 'package:nmeeting/models/progress.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/models/voting.dart';
import 'package:web_socket_channel/io.dart';

class ProgressRepository {
  final _provider = ApiProvider();

  Future<TResult> getAllProgress(ProgressInput data) async {
    final response =
        await _provider.post(api.URL_PROGRESS_GET_ALL, jsonEncode(data));

    List<ProgressOutput> _progress = [];
    Idea? _idea;
    if (response['Status'] == 1) {
      final _progressData =
          response['Data']['ProgressData'].cast<Map<String, dynamic>>();
      _progress = _progressData.map<ProgressOutput>((object) {
        return ProgressOutput.fromJson(object);
      }).toList();

      final _ideaMap = response['Data']['IdeaData']?.cast<String, dynamic>();

      _idea = _ideaMap == null
          ? null
          : Idea(
              id: _ideaMap['ID'],
              accountHasRegist: _ideaMap['AccountHasRegist'],
              accountHasInviteByAdmin: _ideaMap['AccountHasInviteByAdmin'],
              ideaDetailID: _ideaMap['IdeaDetailID'],
              isUserEndIdea: _ideaMap['IsUserEndIdea'],
              memberInvited: _ideaMap['MemberInvited'] == null
                  ? null
                  : MemberInvited(
                      memberInvitedID: _ideaMap['MemberInvited']
                          ['MemberInvitedID'],
                      message: _ideaMap['MemberInvited']['Message']));
    }

    var r = ProgressIdea(progressOutput: _progress, idea: _idea);

    return TResult(status: response['Status'], data: r, msg: response['Msg']);
  }

  Future<TResult> checkIsInMeeting(data) async {
    final response =
        await _provider.post(api.URL_MEETING_IS_INMEETING, jsonEncode(data));

    // UserGoToMeetingOutput _inMeetingOutput;
    // final _data = response['Data'].cast<String, dynamic>();
    // _inMeetingOutput = UserGoToMeetingOutput(
    //     data: _data['Data']);

    final r = TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
    return r;
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
        msg: response['Msg']);
  }

  Future<TResult> onAnwserSelected(data) async {
    final response =
        await _provider.post(api.URL_VOTING_ANWSER_SELECTED, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
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
        status: response['Status'], data: _res, msg: response['Msg']);
  }

  Future<TResult> sendRegist(IdeaInput data) async {
    final response =
        await _provider.post(api.URL_IDEA_SEND_REGIST, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
  }

  Future<IOWebSocketChannel> openProgressWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_PROGRESS);
  }

  Future<IOWebSocketChannel> openStartEndMeetingWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_ADMIN_START_END_MEETING);
  }
}
