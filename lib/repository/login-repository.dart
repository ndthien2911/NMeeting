import 'dart:convert';
import 'dart:io';

import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:nmeeting/configs/token.dart' as token;
import 'package:nmeeting/models/login.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

import '../configs/api-endpoint.dart' as api;

class LoginRepository {
  final _provider = ApiProvider();

  Future<TResult> login(LoginInput login) async {
    Map<String, String> _headers = {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
    };

    final _tokenParam = {
      'client_id': '',
      'grant_type': token.GRANT_TYPE,
      'username': login.username,
      'password': login.password,
      'device': login.device,
      'IMEICode': login.iMEICode ?? '',
      'tokenDevice': login.tokenDevice ?? ''
    };

    final response =
        await _provider.getToken(api.URL_TOKEN, _tokenParam, _headers);

    if (StringUtils.isNullOrEmpty(response['error'])) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!StringUtils.isNullOrEmpty(response['access_token'])) {
        prefs.setString('token', response['access_token']);
      }
      if (!StringUtils.isNullOrEmpty(response['UserName'])) {
        prefs.setString('username', response['UserName']);
      }
      if (!StringUtils.isNullOrEmpty(response['PersonalID'])) {
        prefs.setString('personalID', response['PersonalID']);
      }
      if (!StringUtils.isNullOrEmpty(response['UnitID'])) {
        prefs.setString('unitid', response['UnitID']);
      }
      if (!StringUtils.isNullOrEmpty(response['LoginID'])) {
        prefs.setString('loginid', response['LoginID']);
      }
      if (!StringUtils.isNullOrEmpty(response['RoleID'])) {
        prefs.setString('roleid', response['RoleID']);
      }
      if (!StringUtils.isNullOrEmpty(response['FullName'])) {
        prefs.setString('fullname', response['FullName']);
      }
      if (!StringUtils.isNullOrEmpty(response['Password'])) {
        prefs.setString('password', response['Password']);
      }

      return TResult(status: 1, data: null, msg: '');
    } else {
      return TResult(status: 0, data: null, msg: response['error_description']);
    }
  }

  Future<TResult> refreshPassword(ResetPassword data) async {
    final response =
        await _provider.post(api.URL_RESET_PASSWORD, jsonEncode(data));
    final r = TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> onLogout(LoginOutput data) async {
    final response = await _provider.post(api.URL_LOGOUT_APP, jsonEncode(data));
    final r = TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<IOWebSocketChannel> openLoginWebSocketChannel() async {
    return _provider.openWebSocket(api.WS_URL_LOGIN);
  }
}
