import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PageDocumentViewer extends StatefulWidget {
  final String link;

  const PageDocumentViewer({Key? key, required this.link}) : super(key: key);

  @override
  State<PageDocumentViewer> createState() => _PageDocumentViewerState();
}

class _PageDocumentViewerState extends State<PageDocumentViewer> {
  final _key = UniqueKey();
  int _stackToView = 0;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              setState(() {
                _stackToView = 1;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.link));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Document',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: defaultTargetPlatform == TargetPlatform.iOS
          ? _openIosViewer()
          : defaultTargetPlatform == TargetPlatform.android
              ? _openAndroidViewer()
              : const Center(child: Text('Not supported!')),
    );
  }

  Widget _openAndroidViewer() {
    return IndexedStack(
      index: _stackToView,
      children: [
        const Center(child: CircularProgressIndicator()),
        PDF(
          onViewCreated: (pdfViewController) {
            setState(() {
              _stackToView = 1;
            });
          },
        ).cachedFromUrl(
          widget.link,
          placeholder: (progress) => Center(
              child: Text('$progress %', style: const TextStyle(fontSize: 16))),
          errorWidget: (error) => Center(child: Text(error.toString())),
        ),
      ],
    );
  }

  Widget _openIosViewer() {
    return IndexedStack(
      index: _stackToView,
      children: [
        const Center(child: CircularProgressIndicator()),
        WebViewWidget(controller: _controller),
      ],
    );
  }
}
