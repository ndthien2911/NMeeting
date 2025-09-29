import 'dart:convert';
import 'dart:io';

import 'package:nmeeting/base/api-provider.dart';
import 'package:nmeeting/models/profile.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;

class ProfileRepository {
  final _provider = ApiProvider();

  Future<TResult> updateProfile(String id, ProfileInput data) async {
    final response =
        await _provider.put(api.URL_PROPFILE, id, jsonEncode(data));
    ProfileOutput? _profileOutput;
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      _profileOutput = ProfileOutput(
          id: _data['ID'],
          currentName: _data['CurrentName'],
          //gender: _data['Gender'],
          phone: _data['Phone'],
          email: _data['Email'],
          birthDate: _data['BirthDate'],
          avatarUrl: _data['AvatarUrl'],
          signinAt: _data['SigninAt'],
          unitID: _data['UnitID'],
          accLogID: _data['AccLogID']);
    }

    final r = TResult(
        status: response['Status'],
        data: _profileOutput,
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> uploadAvatar(String userId, File imageFile) async {
    var postUri = Uri.parse(api.URL_UPLOAD_AVATAR);
    var request = new http.MultipartRequest("POST", postUri);
    request.fields['user_id'] = userId;

    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));

    request.files.add(multipartFile);
    final response = await _provider.upload(request);
    final r = TResult(
        status: response['Status'],
        data: response['Data'],
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> getProfile(String id) async {
    final response = await _provider.get(api.URL_GET_PROPFILE + "?id=${id}");
    ProfileBasicOutput? _profileOutput;
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      _profileOutput = ProfileBasicOutput(
          userName: _data['UserName'],
          currentName: _data['CurrentName'] ?? '',
          avartaUrl: _data['AvatarUrl'] ?? '',
          email: _data['Email'] ?? '',
          //gender: _data['Gender'],
          phone: _data['Phone'] ?? '',
          birthDate: _data['BirthDate'] ?? '');
    }

    final r = TResult(
        status: response['Status'],
        data: _profileOutput,
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> getPolicy() async {
    final response = await _provider.get(api.URL_GET_POLICY);
    String policyUrl = '';
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      policyUrl = _data['URL'];
    }

    final r = TResult(
        status: response['Status'],
        data: policyUrl,
        msg: response['Msg'] ?? '');
    return r;
  }

  Future<TResult> getHelpDocument() async {
    final response = await _provider.get(api.URL_GET_HELP_DOCUMENT);
    String policyUrl = '';
    if (response['Status'] == 1) {
      final _data = response['Data'].cast<String, dynamic>();
      policyUrl = _data['URL'];
    }

    final r = TResult(
        status: response['Status'],
        data: policyUrl,
        msg: response['Msg'] ?? '');
    return r;
  }
}
