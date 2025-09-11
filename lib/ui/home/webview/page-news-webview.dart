import 'dart:async';

import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PageNewsWebview extends StatefulWidget {
  final String newsID;
  const PageNewsWebview({Key? key, required this.newsID}) : super(key: key);

  @override
  State<PageNewsWebview> createState() => _PageNewsWebviewState();
}

class _PageNewsWebviewState extends State<PageNewsWebview> {
  late final WebViewController _controller;
  int _stackToView = 0;
  String _token = '';
  String _username = '';

  final String _url = '${api.URL_WEB_CLIENT}/news-feed/news';

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
        '$_url?userName=$_username&token=$_token&newsID=${widget.newsID}';
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
              if (await _controller.currentUrl() == '${api.URL_WEB_CLIENT}/') {
                Navigator.of(context).pop();
              }
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
