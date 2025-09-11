import 'dart:async';

import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PageLibraryManagementWebview extends StatefulWidget {
  const PageLibraryManagementWebview({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageLibraryManagementWebviewState();
  }
}

class _PageLibraryManagementWebviewState
    extends State<PageLibraryManagementWebview> {
  late final WebViewController controller;

  int _stackToView = 0;
  String _token = '';
  String _username = '';

  final String _url = '${api.URL_WEB_CLIENT}/office/of-office';

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            final url = request.url;
            if (!StringUtils.isNullOrEmpty(url) && url.endsWith('.pdf')) {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                throw 'Could not launch $url';
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            setState(() {
              _stackToView = 1;
            });
          },
        ),
      );
  }

  Future<String> _getUrlWithAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _username = prefs.getString('username') ?? '';
    return '$_url?userName=$_username&token=$_token';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () async {
            if (await controller.canGoBack()) {
              await controller.goBack();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Quản lý văn bản',
          style: TextStyle(color: Colors.black, fontSize: 22),
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
            FutureBuilder<String>(
              future: _getUrlWithAuth(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  controller.loadRequest(Uri.parse(snapshot.data!));
                  return WebViewWidget(controller: controller);
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
