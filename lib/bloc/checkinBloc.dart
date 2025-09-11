import 'dart:async';
import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/checkin.dart';
import 'package:nmeeting/repository/checkin-repository.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class CheckinBloc extends BaseBloc {
  // repository
  final _checkinRepository = new CheckinRepository();

  Future<TResult> onStartEndMeetingByQRCode(String _meetingID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _checkinInput = StartEndMeetingInput(
        personalID: prefs.getString('personalID') ?? '', meetingID: _meetingID);

    final _response =
        await _checkinRepository.onStartEndMeetingByQRCode(_checkinInput);
    return _response;
  }

  Future<TResult> onCheckinByQRCode(String _qrCode) async {
    final prefs = await SharedPreferences.getInstance();
    final _qrScanParam = CheckinMember(
        qrCode: _qrCode, personalID: prefs.getString('personalID') ?? '');
    final _response = await _checkinRepository.checkinByQRCode(_qrScanParam);

    return _response;
  }

  Future<IOWebSocketChannel> openCheckinWebSocketChannel() {
    return _checkinRepository.wsCheckin();
  }

  @override
  void dispose() {}
}
