import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/models/home.dart';
import 'package:nmeeting/models/t-result.dart';

class HomeRepository {
  final _provider = ApiProvider();

  Future<TResult> getMeetingToday(String personalID) async {
    final response = await _provider
        .get(api.URL_MEETING_GET_BY_TODAY + '?personalID=' + personalID);

    List<MeetingTodayOutput> _meetingTodayList = [];
    if (response['Status'] == 1) {
      final _meetingTodayData = response['Data'].cast<Map<String, dynamic>>();

      _meetingTodayList = _meetingTodayData.map<MeetingTodayOutput>((event) {
        return MeetingTodayOutput.fromJson(event);
      }).toList();
    }

    return TResult(
        status: response['Status'],
        data: _meetingTodayList,
        msg: response['Msg']);
  }

  Future<TResult> getMenuAppLayout(String userName) async {
    final response =
        await _provider.get(api.URL_GET_MENU_APP + '?userName=' + userName);
    List<MenuAppLayout> _menuAppLayoutList = [];
    if (response['Status'] == 1) {
      final _menuAppListData = response['Data'].cast<Map<String, dynamic>>();
      _menuAppLayoutList = _menuAppListData.map<MenuAppLayout>((event) {
        return MenuAppLayout.fromJson(event);
      }).toList();
    }
    return TResult(
        status: response['Status'],
        data: _menuAppLayoutList,
        msg: response['Msg']);
  }
}
