import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/config-repository.dart';
import 'package:rxdart/rxdart.dart';

class ConfigBloc extends BaseBloc {
  // repository
  final _configRepository = new ConfigRepository();

  // unit used
  final _unitUsedController = BehaviorSubject<String>();
  Stream<String> get unitUsedStream => _unitUsedController.stream;

  Future<TResult> getAppVersion() async {
    final res = await _configRepository.getAppVersion();

    return res;
  }

  getUnitUsed() async {
    final res = await _configRepository.getUnitUsed();

    if (res.status == 1) {
      _unitUsedController.sink.add(res.data);
    }
  }

  @override
  void dispose() {
    _unitUsedController?.close();
  }
}
