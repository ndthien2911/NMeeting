import 'dart:async';
import 'dart:io';

import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:flutter/material.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PageWebviewDefault extends StatefulWidget {
  final String url;
  final String title;

  const PageWebviewDefault({Key? key, required this.url, required this.title})
      : super(key: key);

  @override
  _PageWebviewDefaultState createState() => _PageWebviewDefaultState();
}

class _PageWebviewDefaultState extends State<PageWebviewDefault> {
  late final WebViewController controller;
  int _stackToView = 0;

  String _token = '';
  String _username = '';
  String _url = '';
  bool _isHasParam = false;

  @override
  void initState() {
    super.initState();

    _url = '${api.URL_WEB_CLIENT}/${widget.url}';
    _isHasParam =
        !StringUtils.isNullOrEmpty(widget.url) && widget.url.contains('&');

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          setState(() {
            _stackToView = 1;
          });
        },
        onNavigationRequest: (request) async {
          if (Platform.isAndroid) {
            return await _androidWebviewOpenFile(request);
          }
          return NavigationDecision.navigate;
        },
      ));

    _loadInitialUrl();
  }

  Future<void> _loadInitialUrl() async {
    final url = await _getUrlWithAuth();
    controller.loadRequest(Uri.parse(url));
  }

  Future<String> _getUrlWithAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _username = prefs.getString('username') ?? '';
    return '${_url}userName=$_username&token=$_token';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () async {
            if (!_isHasParam) {
              final currentUrl = await controller.currentUrl();
              if ((currentUrl ?? '') + '?' == _url) {
                Navigator.of(context).pop();
              } else if (await controller.canGoBack()) {
                controller.goBack();
              } else {
                Navigator.of(context).pop();
              }
            } else if ((await controller.currentUrl()) != _url &&
                await controller.canGoBack()) {
              controller.goBack().then((_) async {
                if (await controller.currentUrl() == '${api.URL_WEB_CLIENT}/') {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.of(context).pop();
                  });
                }
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _stackToView,
          children: <Widget>[
            const Center(child: CircularProgressIndicator()),
            WebViewWidget(controller: controller),
          ],
        ),
      ),
    );
  }

  Future<NavigationDecision> _androidWebviewOpenFile(
      NavigationRequest request) async {
    var url = request.url;
    if (!StringUtils.isNullOrEmpty(url) &&
        (url.endsWith('.pdf') ||
            url.endsWith('.doc') ||
            url.endsWith('.docx'))) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }
}
