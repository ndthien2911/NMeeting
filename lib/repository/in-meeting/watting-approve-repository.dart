import 'dart:convert';
import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/in-meeting/wattingApprove.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;

class WattingApproveRepository {
  final _provider = ApiProvider();

  Future<TResult> getAll(DataInput data) async {
    final response =
        await _provider.post(api.URL_GET_ALL_PAGE_METTING, jsonEncode(data));

    List<MeetingObj> _progress;
    if (response['Status'] == 1) {
      final _progressData = response['Data'].cast<Map<String, dynamic>>();
      _progress = _progressData.map<MeetingObj>((object) {
        return MeetingObj.fromJson(object);
      }).toList();
    }

    return TResult(
        status: response['Status'], data: _progress, msg: response['Msg']);
  }

  Future<TResult> changeMode(ChangeModeInput data) async {
    final response = await _provider.post(
        api.URL_CHANGE_MODE_PAGE_METTING, jsonEncode(data));

    List<MeetingObj> _progress;
    if (response['Status'] == 1) {
      final _progressData = response['Data'].cast<Map<String, dynamic>>();
      _progress = _progressData.map<MeetingObj>((object) {
        return MeetingObj.fromJson(object);
      }).toList();
    }

    return TResult(
        status: response['Status'], data: _progress, msg: response['Msg']);
  }

  Future<TResult> deleteItem(DeleteInput data) async {
    final response =
        await _provider.post(api.URL_DELETE_PAGE_METTING, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
  }

  Future<TResult> rejectItem(RejectInput data) async {
    final response =
        await _provider.post(api.URL_REJECT_PAGE_METTING, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
  }
}
