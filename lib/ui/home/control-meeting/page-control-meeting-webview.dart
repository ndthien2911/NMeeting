import 'dart:async';

import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PageControlMeetingWebview extends StatefulWidget {
  final String meetingID;
  const PageControlMeetingWebview({Key? key, required this.meetingID})
      : super(key: key);

  @override
  State<PageControlMeetingWebview> createState() =>
      _PageControlMeetingWebviewState();
}

class _PageControlMeetingWebviewState extends State<PageControlMeetingWebview> {
  late final WebViewController _controller;
  int _stackToView = 0;
  String _token = '';
  String _username = '';

  final String _url = '${api.URL_WEB_CLIENT}/meeting/in-meeting';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _stackToView = 1;
            });
          },
        ),
      );
  }

  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _username = prefs.getString('username') ?? '';
    final urlWithAuth =
        '$_url?meetingID=${widget.meetingID}&userName=$_username&token=$_token';
    await _controller.loadRequest(Uri.parse(urlWithAuth));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Điều hành cuộc họp',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _stackToView,
          children: [
            const Center(child: CircularProgressIndicator()),
            FutureBuilder(
              future: _loadUrl(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return WebViewWidget(controller: _controller);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}
