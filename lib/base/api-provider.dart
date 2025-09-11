import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'custom-exception.dart';

class ApiProvider {
  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response =
          await http.get(Uri.parse(url), headers: await _createHeader());
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url, dynamic body) async {
    var responseJson;
    try {
      final response = await http.post(Uri.parse(url),
          headers: await _createHeader(), body: body);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> getToken(
      String url, dynamic body, Map<String, String> header) async {
    var responseJson;
    try {
      final response =
          await http.post(Uri.parse(url), headers: header, body: body);
      responseJson = json.decode(response.body.toString());
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> put(String url, String id, dynamic body) async {
    var responseJson;
    try {
      final response = await http.put(Uri.parse(url + '/' + id),
          headers: await _createHeader(), body: body);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> upload(http.MultipartRequest request) async {
    request.headers.addAll(await _createHeader());

    var responseJson;
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<IOWebSocketChannel> openWebSocket(String url) async {
    return IOWebSocketChannel.connect(url, headers: await _createHeader());
  }

  Future<Map<String, String>> _createHeader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> _headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('token')}',
      'UserName': '${prefs.getString('username')}',
      HttpHeaders.acceptLanguageHeader: 'vi-VN'
    };

    return _headers;
  }

  dynamic _response(http.Response response) {
    log(response.request!.url.toString());
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
      // throw BadRequestException(response.body.toString());
      case 401:
      case 403:
      // throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        print(response.body.toString());
        print(response.statusCode);

        final responseJson = {
          'Status': 0,
          'data': null,
          'Msg': 'Lỗi giao tiếp với server, status code: ${response.statusCode}'
        };
        return responseJson;
      // throw FetchDataException(
      //     'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
