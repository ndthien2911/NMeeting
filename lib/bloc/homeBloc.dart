import 'dart:async';

import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/home.dart';
import 'package:rxdart/rxdart.dart';
import 'package:nmeeting/repository/home-repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeBloc extends BaseBloc {
  // repository
  final _homeRepository = new HomeRepository();

  // List
  final _meetingTodayListStreamController =
      StreamController<List<MeetingTodayOutput>>();
  final _menuAppLayoutListStreamController =
      StreamController<List<MenuAppLayout>>.broadcast();
  // stream
  Stream<List<MeetingTodayOutput>> get meetingTodayListStream =>
      _meetingTodayListStreamController.stream;

  Stream<List<MenuAppLayout>> get menuAppLayoutListStream =>
      _menuAppLayoutListStreamController.stream.asBroadcastStream();

  final _backgroundColorController = BehaviorSubject<int>();
  Stream<int> get backgroundColorStream => _backgroundColorController.stream;

  getMeetingToday() async {
    final prefs = await SharedPreferences.getInstance();
    final res = await _homeRepository
        .getMeetingToday(prefs.getString('personalID') ?? '');

    if (res.status == 1) {
      _meetingTodayListStreamController.sink.add(res.data);

      //  khung tính thời gian có lịch họp trên 1 ngày làm việc 8 tiếng như sau:
      // - Nếu bận rộn (>=70% thời gian trong 1 ngày làm việc có 8 tiếng) thì nền Top màu đỏ, kèm chữ Một ngày rất bận rộn
      // - Nếu bình thường (có cuộc họp và nhỏ hơn 70%) nền màu xanh nước biển, kèm chữ Một ngày mới tốt lành
      // - Nếu thảnh thơi (Không có cuộc họp nào) nền màu xanh lá, kèm chữ Một ngày thật thảnh thơi
      int _totalMeetingMinutesTime = 0;
      for (var item in res.data) {
        DateTime startAt = DateTime.parse(item.startAt);

        DateTime endAt = item.endAt == null
            ? startAt.add(Duration(hours: 2))
            : DateTime.parse(item.endAt);
        int _diffMinutes = endAt.difference(startAt).inMinutes;
        _totalMeetingMinutesTime += _diffMinutes;
      }

      if (_totalMeetingMinutesTime >= 336) {
        _backgroundColorController.sink.add(0);
      } else if ((_totalMeetingMinutesTime < 336 &&
              _totalMeetingMinutesTime > 144) ||
          _totalMeetingMinutesTime > 0) {
        _backgroundColorController.sink.add(1);
      } else if (_totalMeetingMinutesTime == 0) {
        _backgroundColorController.sink.add(2);
      }
    }
  }

  getMenuAppList() async {
    final prefs = await SharedPreferences.getInstance();
    final res = await _homeRepository
        .getMenuAppLayout(prefs.getString('username') ?? '');

    if (res.status == 1) {
      _menuAppLayoutListStreamController.sink.add(res.data);
    }
  }

  @override
  void dispose() {
    _meetingTodayListStreamController?.close();
    _menuAppLayoutListStreamController?.close();
    _backgroundColorController?.close();
  }
}
