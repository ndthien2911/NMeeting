import 'dart:convert';
import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/checkin.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:web_socket_channel/io.dart';

class CheckinRepository {
  final _provider = ApiProvider();

  Future<TResult> onStartEndMeetingByQRCode(StartEndMeetingInput data) async {
    final response = await _provider.post(
        api.URL_CHECKIN_START_END_MEETING, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<TResult> checkinByQRCode(CheckinMember data) async {
    final response =
        await _provider.post(api.URL_CHECKIN_MEMBER, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }

  Future<IOWebSocketChannel> wsCheckin() async {
    return _provider.openWebSocket(api.WS_URL_CHECKIN);
  }
}
