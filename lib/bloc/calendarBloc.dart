import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/calendar-repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitBloc extends BaseBloc {
  final _unitRepository = UnitRepository();

  // Stream controller
  final _unitListController = StreamController<List<UnitList>>.broadcast();
  Stream<List<UnitList>> get unitListStream => _unitListController.stream;

  // Original list
  List<UnitList> originalUnitList = [];

  // Load initial unit list from repository and set selection from shared prefs
  Future<void> loadUnitList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final personalID = prefs.getString('personalID') ?? '';

    final response = await _unitRepository.getUnit(personalID);
    if (response.status == 1 && response.data.isNotEmpty) {
      originalUnitList = response.data;

      // Lấy danh sách đã chọn từ SharedPreferences
      List<String> savedSelected =
          prefs.getStringList('calendar_searchValues') ?? [];

      if (savedSelected.isNotEmpty) {
        for (var unit in originalUnitList) {
          unit.selected = savedSelected.contains(unit.id);
        }
      } else {
        // Mặc định chọn item đầu tiên
        originalUnitList[0].selected = true;
      }

      // Cập nhật stream
      _unitListController.sink.add(originalUnitList);
    }
  }

  // Toggle selection của unit theo index
  void toggleUnitSelection(int index) async {
    originalUnitList[index].selected = !originalUnitList[index].selected;

    // Nếu không còn item nào được chọn, chọn lại item đầu tiên
    if (!originalUnitList.any((unit) => unit.selected)) {
      originalUnitList[0].selected = true;
    }

    // Cập nhật stream
    _unitListController.sink.add(originalUnitList);

    // Lưu danh sách đã chọn vào SharedPreferences
    await _saveSelectedUnitsToPrefs();
  }

  // Lấy danh sách id của unit đã chọn
  List<String> getSelectedUnitIds() {
    return originalUnitList
        .where((unit) => unit.selected)
        .map((unit) => unit.id)
        .toList();
  }

  // Lưu SharedPreferences
  Future<void> _saveSelectedUnitsToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final selectedIds = getSelectedUnitIds();
    await prefs.setStringList('calendar_searchValues', selectedIds);
  }

  @override
  void dispose() {
    _unitListController.close();
  }
}

// Model UnitList
class UnitList {
  final String id;
  final String name;
  bool selected;

  UnitList({
    required this.id,
    required this.name,
    this.selected = false,
  });

  factory UnitList.fromJson(Map<String, dynamic> json) {
    return UnitList(
      id: json['ID'] ?? '',
      name: json['Name'] ?? '',
      selected: json['Selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'ID': id,
        'Name': name,
        'Selected': selected,
      };
}
