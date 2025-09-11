import 'dart:convert';

import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/models/event.dart';
import 'package:nmeeting/models/t-result.dart';

class EventRepository {
  final _provider = ApiProvider();

  Future<TResult> getListTags() async {
    final response = await _provider.get(api.URL_GET_TAGS);
    List<EventTag> _eventTagsOutput = [];
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<Map<String, dynamic>>();
      _eventTagsOutput = _data.map<EventTag>((event) {
        return EventTag.fromJson(event);
      }).toList();
    }

    final r = TResult(
        status: response['Status'],
        data: _eventTagsOutput,
        msg: response['Msg']);
    return r;
  }

  Future<TResult> getListReminders() async {
    final response = await _provider.get(api.URL_GET_REMINDERS);
    List<EventReminder> _eventRemindersOutput = [];
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<Map<String, dynamic>>();
      _eventRemindersOutput = _data.map<EventReminder>((event) {
        return EventReminder.fromJson(event);
      }).toList();
    }

    final r = TResult(
        status: response['Status'],
        data: _eventRemindersOutput,
        msg: response['Msg']);
    return r;
  }

  Future<TResult> createEvent(EventObj data) async {
    final response =
        await _provider.post(api.URL_POST_CREATE_EVENT, jsonEncode(data));

    EventObj? _outputObj;
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      _outputObj = EventObj(
          id: _data['ID'],
          name: _data['Name'],
          admin: _data['Admin'],
          eventDate: _data['MeetingDate'],
          startAt: _data['StartAt'],
          endAt: _data['EndAt'],
          type: _data['Type']);
    }

    return TResult(
        status: response['Status'], data: _outputObj, msg: response['Msg']);
  }

  Future<TResult> updateEvent(EventObj data) async {
    final response =
        await _provider.post(api.URL_POST_UPDATE_EVENT, jsonEncode(data));

    EventObj? _outputObj;
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      _outputObj = EventObj(
          id: _data['ID'],
          name: _data['Name'],
          admin: _data['Admin'],
          eventDate: _data['MeetingDate'],
          startAt: _data['StartAt'],
          endAt: _data['EndAt'],
          type: _data['Type']);
    }

    return TResult(
        status: response['Status'], data: _outputObj, msg: response['Msg']);
  }

  Future<TResult> getEventDetail(EventReq data) async {
    final response =
        await _provider.post(api.URL_GET_EVENT_DETAIL, jsonEncode(data));

    EventObj? _outputObj;
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      _outputObj = EventObj(
          id: _data['ID'],
          name: _data['Name'],
          admin: _data['Admin'],
          eventDate: _data['EventDate'],
          startAt: _data['StartAt'],
          endAt: _data['EndAt'],
          reminderID: _data['ReminderID'],
          reminderVal: _data['ReminderVal'],
          tagID: _data['TagID'],
          tagNm: _data['TagNm'],
          type: _data['Type']);
    }

    return TResult(
        status: response['Status'], data: _outputObj, msg: response['Msg']);
  }

  Future<TResult> deleteItem(DeleteInput data) async {
    final response =
        await _provider.post(api.URL_DELETE_PAGE_EVENT, jsonEncode(data));

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg']);
  }
}
