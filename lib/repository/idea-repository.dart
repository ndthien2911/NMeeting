import 'dart:convert';

import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/idea.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:web_socket_channel/io.dart';

import '../configs/api-endpoint.dart' as api;

class IdeaRepository {
  final _provider = ApiProvider();

  Future<TResult> startCheck(IdeaInput data) async {
    final response =
        await _provider.post(api.URL_IDEA_START_CHECK, jsonEncode(data));
    StartCheckResp? _startCheckResp;
    if (response['Status'] == 1) {
      final _ideaResEventsData = response['Data'].cast<String, dynamic>();
      _startCheckResp = StartCheckResp(
          startFlg: _ideaResEventsData['StartFlg'],
          ideaID: _ideaResEventsData['IdeaID'],
          accountHasRegist: _ideaResEventsData['AccountHasRegist']);
    }

    return TResult(
        status: response['Status'],
        data: _startCheckResp,
        msg: response['Msg'] ?? '');
  }

  Future<TResult> sendRegist(IdeaInput data) async {
    final response =
        await _provider.post(api.URL_IDEA_SEND_REGIST, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> registCheck(IdeaInput data) async {
    final response =
        await _provider.post(api.URL_IDEA_REGIST_CHECK, jsonEncode(data));

    RegistCheckResp? _registCheckResp;
    if (response['Status'] == 1) {
      final _ideaResEventsData = response['Data'].cast<String, dynamic>();
      _registCheckResp = RegistCheckResp(id: _ideaResEventsData['ID']);
    }
    return TResult(
        status: response['Status'],
        data: _registCheckResp,
        msg: response['Msg'] ?? '');
  }

  Future<TResult> endIdea(ideaDetailID, description) async {
    final response = await _provider.get(api.URL_MEETING_END_APPROVE_IDEA +
        '?ideaID=' +
        ideaDetailID +
        '&description=' +
        description);

    final r = TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> startIdea(ideaDetailID) async {
    final response = await _provider
        .get(api.URL_MEETING_APPROVE_IDEA + '?ideaID=' + ideaDetailID);

    final r = TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<IOWebSocketChannel> openIdeaWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_IDEA);
  }
}
