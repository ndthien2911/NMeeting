import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PageMeetingWebview extends StatefulWidget {
  final String meetingID;

  const PageMeetingWebview({Key? key, required this.meetingID})
      : super(key: key);

  @override
  State<PageMeetingWebview> createState() => _PageMeetingWebviewState();
}

class _PageMeetingWebviewState extends State<PageMeetingWebview> {
  late final WebViewController _controller;
  int _stackToView = 0;
  String _token = '';
  String _username = '';

  final String _url = '${api.URL_WEB_CLIENT}/meeting/meeting';

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
          onPageFinished: (url) {
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
        '$_url?userName=$_username&token=$_token&meetingID=${widget.meetingID}';
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
              await _controller.goBack();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Thông báo',
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
