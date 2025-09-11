import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/models/login.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/login-repository.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:nmeeting/configs/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc extends BaseBloc {
  // repository
  final _loginRepository = new LoginRepository();

  // username
  final _usernameController = BehaviorSubject<String>();
  Stream<String> get usernameStream => _usernameController.stream;

  // password
  final _passwordController = BehaviorSubject<String>();
  Stream<String> get passwordStream => _passwordController.stream;

  // tokendevice
  final _tokenDeviceController = BehaviorSubject<String>();
  Stream<String> get tokenDeviceStream => _tokenDeviceController.stream;

  // imeicode
  final _iMEICodeController = BehaviorSubject<String>();
  Stream<String> get iMEICodeController => _iMEICodeController.stream;

  onUsernameChanged(value) {
    _usernameController.sink.add(value);
  }

  onPasswordChanged(value) {
    _passwordController.sink.add(value);
  }

  onSetTokenDevice(value) {
    _tokenDeviceController.sink.add(value);
  }

  onSetIMEICode(value) {
    _iMEICodeController.sink.add(value);
  }

  onGetTokenDevice() {
    return _tokenDeviceController.value;
  }

  onGetIMEICode() {
    return _iMEICodeController.value;
  }

  bool isValidInput() {
    bool _isValid = true;
    if (StringUtils.isNullOrEmpty(_usernameController.value?.trim())) {
      _usernameController.sink.addError('Vui lòng nhập tài khoản');
      _isValid = false;
    }

    if (StringUtils.isNullOrEmpty(_passwordController.value?.trim())) {
      _passwordController.sink.addError('Vui lòng nhập mật khẩu');
      _isValid = false;
    }

    return _isValid;
  }

  Future<TResult> onLogin() async {
    final _loginParam = LoginInput(
      username: _usernameController.value,
      password: _passwordController.value,
      device: constants.PAGE_ID_FOR_APP,
      tokenDevice: this.onGetTokenDevice(),
      iMEICode: this.onGetIMEICode(),
    );
    final _response = await _loginRepository.login(_loginParam);
    return _response;
  }

  Future<TResult> onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final _logoutParam =
        LoginOutput(accLogID: prefs.getString('loginid') ?? '');
    final _response = await _loginRepository.onLogout(_logoutParam);
    return _response;
  }

  Future<TResult> onRefreshPassword(String email) async {
    final _refreshParam = ResetPassword(email: email);
    final _response = await _loginRepository.refreshPassword(_refreshParam);
    return _response;
  }

  @override
  void dispose() {
    _usernameController?.close();
    _passwordController?.close();
    _tokenDeviceController?.close();
    _iMEICodeController?.close();
  }
}
