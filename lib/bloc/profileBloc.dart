import 'dart:async';
import 'dart:io';

import 'package:nmeeting/base/base-bloc.dart';
import 'package:nmeeting/repository/login-repository.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:nmeeting/models/profile.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/repository/profile-repository.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/io.dart';

class ProfileBloc extends BaseBloc {
  // repository
  final _profileRepository = new ProfileRepository();
  final _loginRepository = new LoginRepository();

  // username
  final _usernameController = BehaviorSubject<String>();
  Stream<String> get usernameStream => _usernameController.stream;

  // avatar
  final _avatarController = BehaviorSubject<String>();
  Stream<String> get avatarStream => _avatarController.stream;

  // fullname
  final _fullNmController = BehaviorSubject<String>();
  Stream<String> get fullnameStream => _fullNmController.stream;

  // name
  final _nameController = BehaviorSubject<String>();
  Stream<String> get nameStream => _nameController.stream;

  // email
  final _emailController = BehaviorSubject<String>();
  Stream<String> get emailStream => _emailController.stream;

  // app version
  final _appVersionController = BehaviorSubject<String>();
  Stream<String> get appVersionStream => _appVersionController.stream;

  // name input
  final _nameInputController = BehaviorSubject<String>();
  Stream<String> get nameInputStream => _nameInputController.stream;

  // birthday input
  final _birthdayInputController = BehaviorSubject<String>();
  Stream<String> get birthdayInputStream => _birthdayInputController.stream;

  // email input
  final _emailInputController = BehaviorSubject<String>();
  Stream<String> get emailInputStream => _emailInputController.stream;

  // phone input
  final _phoneInputController = BehaviorSubject<String>();
  Stream<String> get phoneInputStream => _phoneInputController.stream;

  // url policy
  final _policyController = BehaviorSubject<String>();
  Stream<String> get policyStream => _policyController.stream;

  Stream<bool> get submitCheck => Rx.combineLatest2(
          nameInputStream, emailInputStream, (name, email) => true)
      .asBroadcastStream();

  Future<TResult> uploadAvatar(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final res = await _profileRepository.uploadAvatar(
        prefs.getString('personalID') ?? '', imageFile);
    return res;
  }

  getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final _response = await _profileRepository
        .getProfile(prefs.getString('personalID') ?? '');
    if (_response.status == 1) {
      ProfileBasicOutput _mapEvents = _response.data;
      var avatarUrl = "";
      if (!StringUtils.isNullOrEmpty(_mapEvents.avartaUrl)) {
        avatarUrl = '${api.BASE_URL}' + _mapEvents.avartaUrl;
      }
      _avatarController.sink.add(avatarUrl);
      // _fullNmController.sink.add(_mapEvents.fullName);
      _nameController.sink.add(_mapEvents.currentName);
      _usernameController.sink.add(_mapEvents.userName);
      _emailController.sink.add(_mapEvents.email);

      _phoneInputController.sink.add(_mapEvents.phone);
      _birthdayInputController.sink.add(_mapEvents.birthDate);
      _nameInputController.sink.add(_mapEvents.currentName);
      _emailInputController.sink.add(_mapEvents.email);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', _mapEvents.userName);
      // prefs.setInt('user_gender', res.data.gender);
      prefs.setString('fullname', _mapEvents.currentName);
      prefs.setString('user_email', _mapEvents.email);
      prefs.setString('user_phone', _mapEvents.phone);
      prefs.setString('user_birthday', _mapEvents.birthDate);
      prefs.setString('user_avatarUrl', avatarUrl);
    }
  }

  getAppVersion() async {
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String version = packageInfo.version;
    // _appVersionController.sink.add(version);
  }

  Future<TResult> updateUserProfile() async {
    canSubmitCheck();
    final prefs = await SharedPreferences.getInstance();
    final _profileInput = ProfileInput(
      name: _nameInputController.value,
      birthday: _birthdayInputController.value,
      // gender: gender,
      email: _emailInputController.value,
      // unitID: unitID,
      phone: _phoneInputController.value,
    );

    final res = await _profileRepository.updateProfile(
        prefs.getString('personalID') ?? '', _profileInput);
    if (res.status == 1) {
      prefs.setString('personalID', res.data.id);
      // prefs.setString('username', res.data.usename);
      prefs.setString('fullname', res.data.currentName);
      //prefs.setInt('user_gender', res.data.gender);
      prefs.setString('user_email', res.data.email);
      prefs.setString('user_phone', res.data.phone);
      prefs.setString('user_birthday', res.data.birthDate);
      prefs.setString('user_avatarUrl', res.data.avatarUrl);
      prefs.setString('user_unitID', res.data.unitID);

      _nameController.sink.add(res.data.currentName);
    }
    return res;
  }

  Future<TResult> getPolicy() async {
    final res = await _profileRepository.getPolicy();
    if (res.status == 1) {
      _policyController.sink.add('${api.BASE_URL}${res.data}');
      var url = '${api.BASE_URL}${res.data}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      showToast('Could not launch');
    }
    return res;
  }

  Future<TResult> getHelpDocument() async {
    final res = await _profileRepository.getHelpDocument();
    if (res.status == 1) {
      _policyController.sink.add('${api.BASE_URL}${res.data}');
      var url = '${api.BASE_URL}${res.data}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      showToast('Could not launch');
    }
    return res;
  }

  canSubmitCheck() {
    if (StringUtils.isNullOrEmpty(_nameInputController.value)) {
      return false;
    }
    if (StringUtils.isNullOrEmpty(_phoneInputController.value) &&
        !StringUtils.isVietnamPhone(_phoneInputController.value)) {
      return false;
    }
    if (StringUtils.isNullOrEmpty(_emailInputController.value) &&
        !StringUtils.isEmail(_emailInputController.value)) {
      return false;
    }
    if (StringUtils.isNullOrEmpty(_birthdayInputController.value)) {
      return false;
    }
    return true;
  }

  onChangedAvatarInput(value) async {
    if (!StringUtils.isNullOrEmpty(value)) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user_avatarUrl', value);
      _avatarController.sink
          .add('${api.BASE_URL}${prefs.getString('user_avatarUrl')}');
    }
  }

  onChangedNameInput(String value) {
    if (StringUtils.isNullOrEmpty(value?.trim())) {
      return _nameInputController.sink.addError("Vui lòng nhập họ và tên");
    }
    if (!StringUtils.isLength(value, 1, 50)) {
      return _nameInputController.sink.addError("Họ và tên quá dài");
    }

    return _nameInputController.sink.add(value);
  }

  onChangedBirthdayInput(value) {
    _birthdayInputController.sink.add(value);
  }

  onChangedEmailInput(value) {
    if (!StringUtils.isNullOrEmpty(value) && !StringUtils.isEmail(value)) {
      return _emailInputController.sink.addError("Email không đúng định dạng");
    }
    return _emailInputController.sink.add(value);
  }

  onChangedPhoneInput(value) {
    if (StringUtils.isNullOrEmpty(value)) {
      return _phoneInputController.sink.addError("Vui lòng nhập số điện thoại");
    }
    if (!StringUtils.isVietnamPhone(value)) {
      return _phoneInputController.sink
          .addError("Vui lòng nhập đúng định dạng số điện thoại");
    }

    return _phoneInputController.sink.add(value);
  }

  Future<IOWebSocketChannel> openLoginWebSocketChannel() {
    return _loginRepository.openLoginWebSocketChannel();
  }

  @override
  void dispose() {
    _avatarController?.close();
    _fullNmController?.close();
    _nameController?.close();
    _usernameController?.close();
    _emailController?.close();
    _nameInputController?.close();
    _birthdayInputController?.close();
    _emailInputController?.close();
    _phoneInputController?.close();
    _policyController?.close();
    _appVersionController?.close();
  }
}
