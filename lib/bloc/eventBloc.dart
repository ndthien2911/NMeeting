import 'dart:async';

import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/calendar.dart';
import 'package:nmeeting/models/event.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/calendar-repository.dart';
import 'package:nmeeting/repository/event-repository.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nmeeting/configs/constants.dart' as constants;

class EventBloc extends BaseBloc {
  // repository
  final _eventRepository = new EventRepository();
  final _calendarRepository = new CalendarRepository();

  // name
  final _eventNameInputController = BehaviorSubject<String>();
  Stream<String> get eventNameInputStream => _eventNameInputController.stream;

  // tagID
  final _eventTagIDInputController = BehaviorSubject<String>();
  Stream<String> get eventTagIDInputStream => _eventTagIDInputController.stream;

  // Reminder
  final _eventReminderInputController = BehaviorSubject<int?>();
  Stream<int?> get eventReminderInputStream =>
      _eventReminderInputController.stream;

  // Reminder Value
  final _eventReminderValueController = BehaviorSubject<int>();
  Stream<int> get eventReminderValueStream =>
      _eventReminderValueController.stream;

  // date
  final _eventDateInputController = BehaviorSubject<String>();
  Stream<String> get eventDateInputStream => _eventDateInputController.stream;

  // controller
  final _eventTimelineController = StreamController<List<EventByDayOutput>>();
  Stream<List<EventByDayOutput>> get eventTimelineStream =>
      _eventTimelineController.stream;

  //list tag
  var _eventTagListController = StreamController<List<EventTag>>.broadcast();
  Stream<List<EventTag>> get eventTagListStream =>
      _eventTagListController.stream.asBroadcastStream();

  //list reminder
  var _eventReminderListController =
      StreamController<List<EventReminder>>.broadcast();
  Stream<List<EventReminder>> get eventReminderListStream =>
      _eventReminderListController.stream.asBroadcastStream();

  Future<List<EventByDayOutput>> getTimeline(String _eventDate) async {
    List<EventByDayOutput> _data = [];
    if (StringUtils.isNullOrEmpty(_eventDate)) {
      _eventTimelineController.sink.add([]);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final res = await _calendarRepository.getEventByPersonal(
          prefs.getString('personalID') ?? '', _eventDate);
      if (res.status == 1) {
        _data = List<EventByDayOutput>.from(res.data);
      }
      _eventTimelineController.sink.add(_data);
    }

    return _data;
  }

  Future<TResult> createEvent(EventObj _data) async {
    final _response = await _eventRepository.createEvent(_data);
    return _response;
  }

  Future<TResult> updateEvent(EventObj _data) async {
    final _response = await _eventRepository.updateEvent(_data);
    return _response;
  }

  Future<TResult> getEventDetail(String eventID) async {
    final prefs = await SharedPreferences.getInstance();
    final _param = EventReq(
        personalID: prefs.getString('personalID') ?? '', eventID: eventID);
    final _response = await _eventRepository.getEventDetail(_param);
    if (_response.status == 1) {
      EventObj output = _response.data;
      _eventNameInputController.sink.add(output.name);
      _eventDateInputController.sink.add(output.eventDate);
    }

    return _response;
  }

  Future<String> deleteItem(String idItem) async {
    if (idItem != null && idItem != "") {
      List<String> listIDDelete = [];
      listIDDelete.add(idItem);
      final _dataInput =
          DeleteInput(idList: StringUtils.convertListToString(listIDDelete));
      final _response = await _eventRepository.deleteItem(_dataInput);
      if (_response.status == 1) {
        return constants.STATUS_SUCCESS;
      } else {
        return _response.msg;
      }
    } else {
      return "Vui lòng chọn ít nhất 1 lịch cá nhân";
    }
  }

  getListTags() async {
    final res = await _eventRepository.getListTags();

    if (res.status == 1) {
      final _data = List<EventTag>.from(res.data);
      _eventTagListController.sink.add(_data);
    } else {
      _eventTagListController.sink.add([]);
    }
  }

  getListReminders() async {
    final res = await _eventRepository.getListReminders();

    if (res.status == 1) {
      final _data = List<EventReminder>.from(res.data);
      _eventReminderListController.sink.add(_data);
    } else {
      _eventReminderListController.sink.add([]);
    }
  }

  onChangedEventNameInput(String value) {
    if (StringUtils.isNullOrEmpty(value.trim())) {
      return _eventNameInputController.sink
          .addError("Name of event is field required!");
    }
    if (!StringUtils.isLength(value, 1, 250)) {
      return _eventNameInputController.sink
          .addError("Max length of this field is 250 character!");
    }

    return _eventNameInputController.sink.add(value);
  }

  onSetEventNameInput(String value) {
    return _eventNameInputController.sink.add(value);
  }

  String onGetEventNameInput() {
    return _eventNameInputController.value;
  }

  onChangedEventDateInput(String value) {
    return _eventDateInputController.sink.add(value);
  }

  onSetEventDateInput(String value) {
    return _eventDateInputController.sink.add(value);
  }

  String onGetEventDateInput() {
    return _eventDateInputController.value;
  }

  onSetEventTagIDInput(String value) {
    return _eventTagIDInputController.sink.add(value);
  }

  String onGetEventTagIDInput() {
    return _eventTagIDInputController.value;
  }

  onSetEventReminderInput(int? value) {
    return _eventReminderInputController.sink.add(value);
  }

  int? onGetEventReminderInput() {
    return _eventReminderInputController.value;
  }

  onSetEventReminderValue(int value) {
    return _eventReminderValueController.sink.add(value);
  }

  int onGetEventReminderValue() {
    return _eventReminderValueController.value;
  }

  @override
  void dispose() {
    _eventNameInputController?.close();
    _eventDateInputController?.close();
    _eventTimelineController?.close();
    _eventTagListController?.close();
    _eventTagIDInputController?.close();
    _eventReminderInputController?.close();
    _eventReminderListController?.close();
    _eventReminderValueController?.close();
  }
}
