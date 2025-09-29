import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/models/config.dart';

class ConfigRepository {
  final _provider = ApiProvider();

  Future<TResult> getAppVersion() async {
    final response = await _provider.get(api.URL_APP_VERSION);

    var _data;
    if (response['Status'] == 1) {
      _data = VersionOutput(
          appVersion: response['Data']['AppVersion'],
          url: response['Data']['Url']);
    }
    return TResult(
        status: response['Status'], data: _data, msg: response['Msg'] ?? '');
  }

  Future<TResult> getUnitUsed() async {
    final response = await _provider.get(api.URL_GET_UNIT_USED);

    return TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
  }
}
