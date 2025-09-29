import 'dart:convert';
import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/calendar.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;

class CalendarRepository {
  final _provider = ApiProvider();

  Future<TResult> getEventByMonth(EventByMonthInput data) async {
    final response =
        await _provider.post(api.URL_CALENDAR_BY_MONTH, jsonEncode(data));
    List<EventByMonthOutput> _eventByMonthOutput = [];
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<Map<String, dynamic>>();
      _eventByMonthOutput = _data.map<EventByMonthOutput>((event) {
        return EventByMonthOutput.fromJson(event);
      }).toList();
    }

    final r = TResult(
        status: response['Status'],
        data: _eventByMonthOutput,
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> getEventByDay(EventByDayInput data) async {
    final response =
        await _provider.post(api.URL_CALENDAR_BY_DAY, jsonEncode(data));
    List<EventByDayOutput> _eventByDayOutput = [];
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<Map<String, dynamic>>();
      _eventByDayOutput = _data.map<EventByDayOutput>((event) {
        return EventByDayOutput.fromJson(event);
      }).toList();
    }

    final r = TResult(
        status: response['Status'],
        data: _eventByDayOutput,
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> getEventByPersonal(
      String personalID, String eventDate) async {
    final response = await _provider.get(api.URL_CALENDAR_BY_PERSONAL +
        '?personalID=' +
        personalID +
        '&eventDate=' +
        eventDate);
    List<EventByDayOutput> _eventByDayOutput = [];
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<Map<String, dynamic>>();
      _eventByDayOutput = _data.map<EventByDayOutput>((event) {
        return EventByDayOutput.fromJson(event);
      }).toList();
    }

    final r = TResult(
        status: response['Status'],
        data: _eventByDayOutput,
        msg: response['Msg'] ?? '');
    return r;
  }
}

class UnitRepository {
  final _provider = ApiProvider();
  Future<TResult> getUnit(personalID) async {
    final response = await _provider
        .get(api.URL_GET_LIST_UNIT + '?personalID=' + personalID);

    List<UnitList> _unitList = [];
    if (response['Status'] == 1) {
      final _unitListData = response['Data'].cast<Map<String, dynamic>>();
      _unitList = _unitListData.map<UnitList>((event) {
        return UnitList.fromJson(event);
      }).toList();
    }

    return TResult(
        status: response['Status'],
        data: _unitList,
        msg: response['Msg'] ?? '');
  }
}
