import 'dart:convert';

import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/notify.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:web_socket_channel/io.dart';

import '../configs/api-endpoint.dart' as api;

class NotifyRepository {
  final _provider = ApiProvider();

  Future<TResult> getNotifyWithPersonalID(NotifyInput data) async {
    final response =
        await _provider.post(api.URL_NOTIFY_GET_ALL, jsonEncode(data));
    NotifyRes? _notifyRes;
    if (response['Status'] == 1) {
      final _notifyResEventsData = response['Data'].cast<String, dynamic>();
      _notifyRes = NotifyRes(
          notifyCnt: _notifyResEventsData['NotifyCnt'],
          notifyList: _notifyResEventsData['Notify'].map<NotifyObj>((event) {
            return NotifyObj.fromJson(event);
          }).toList());
    }

    return TResult(
        status: response['Status'], data: _notifyRes, msg: response['Msg']);
  }

  Future<TResult> countNotifyNotSeenWithPersonalID(String _personalID) async {
    final response = await _provider
        .get(api.URL_NOTIFY_COUNT_NOT_SEEN + '?PersonalID=' + _personalID);

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
  }

  Future<TResult> getUsersByMeetingIDs(NotifyByMeetingIdsInput data) async {
    final response = await _provider.post(
        api.URL_NOTIFY_GET_USER_BY_MEETINGID, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
  }

  Future<IOWebSocketChannel> openNotifyWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_NOTIFY);
  }
}
