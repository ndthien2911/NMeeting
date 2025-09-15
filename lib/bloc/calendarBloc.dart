import 'dart:async';
import 'dart:convert';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/calendar.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/calendar-repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarBloc extends BaseBloc {
  // repository
  final _calendarRepository = CalendarRepository();
  final _monthYearHeaderViewController = BehaviorSubject<String>();
  Stream<String> get monthYearHeaderViewStream =>
      _monthYearHeaderViewController.stream;

  setMonthYearHeaderView(String value) {
    _monthYearHeaderViewController.sink.add(value);
  }

  Future<TResult> getEventByMonth(
      String from, String to, List<String> searchValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final _eventByMonthInput = EventByMonthInput(
        personalID: prefs.getString('personalID') ?? '',
        eventFromDate: from,
        eventToDate: to,
        searchValue: jsonEncode(searchValue));
    final _response =
        await _calendarRepository.getEventByMonth(_eventByMonthInput);

    return _response;
  }

  Future<TResult> getEventByDay(String date, List<String> searchValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final _eventByDayInput = EventByDayInput(
        personalID: prefs.getString('personalID') ?? '',
        eventDate: date,
        searchValue: jsonEncode(searchValue));
    final _response = await _calendarRepository.getEventByDay(_eventByDayInput);

    return _response;
  }

  @override
  void dispose() {
    _monthYearHeaderViewController.close();
  }
}

class UnitBloc extends BaseBloc {
  final _unitRepository = UnitRepository();
  final _unitListStreamController =
      StreamController<List<UnitList>>.broadcast();
  Stream<List<UnitList>> get unitListStream =>
      _unitListStreamController.stream.asBroadcastStream();

  List<UnitList> originalUnitList = [];

  setUnitListStreamController() {
    //_unitListStreamController.sink.add([]);
    _unitListStreamController.sink.add(originalUnitList);
  }

  getUnitList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _response =
        await _unitRepository.getUnit(prefs.getString('personalID') ?? '');
    if (_response.status == 1) {
      originalUnitList = _response.data;

      List<String> listSelected =
          prefs.getStringList('calendar_searchValues') ?? [];

      if (listSelected.isNotEmpty) {
        for (var i = 0; i < originalUnitList.length; i++) {
          if (listSelected.contains(originalUnitList[i].id)) {
            originalUnitList[i].selected = true;
          }
        }
      } else {
        if (originalUnitList.isNotEmpty) {
          originalUnitList[0].selected = true;
        }
      }

      _unitListStreamController.sink.add(originalUnitList);
    }
  }

  updateSelectedUnitList(int index) {
    originalUnitList[index].selected = !originalUnitList[index].selected!;

    // if not selected any item, select first item in list
    List<String> listSelected = getUnitListSelect();
    if (listSelected.isEmpty) {
      originalUnitList[0].selected = true;
    }

    _unitListStreamController.sink.add(originalUnitList);

    List<String> idSelected = originalUnitList
        .where((element) => element.selected == true)
        .map((e) => e.id!)
        .toList();
    setSearchValuesSelectedSharedPreferences(idSelected);
  }

  List<String> getUnitListSelect() {
    setUnitListStreamController();
    return originalUnitList
        .where((element) => element.selected == true)
        .map((e) => e.id!)
        .toList();
  }

  setSearchValuesSelectedSharedPreferences(List<String> values) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('calendar_searchValues', values);
  }

  @override
  void dispose() {
    _unitListStreamController.close();
  }
}
