import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nmeeting/bloc/documentBloc.dart';
import 'package:nmeeting/models/progress.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/home/document-viewer/page-document-viewer.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:oktoast/oktoast.dart';
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:url_launcher/url_launcher.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:web_socket_channel/io.dart';
import 'package:nmeeting/utilities/string-utils.dart';

class PageDocument extends StatefulWidget {
  final DocumentBloc documentBloc;

  const PageDocument({Key? key, required this.documentBloc}) : super(key: key);
  @override
  _PageDocumentState createState() => _PageDocumentState();
}

class _PageDocumentState extends State<PageDocument> {
  late IOWebSocketChannel _channel;

  static const all = 'Tất cả';
  static const recent = 'Gần đây';
  late String _selectedDocumentModeValue;
  bool _clickall = false;
  bool _clicknearly = true;

  @override
  void initState() {
    super.initState();
    _selectedDocumentModeValue = recent;
    this._getDocument(false);
    this._openProgressWebSocketChannel();
  }

  _openProgressWebSocketChannel() async {
    _channel = await widget.documentBloc.openProgressWebSocketChannel();
    _listenProgressWebSocketChannel();
  }

  _reopenProgressWebSocketChannel() async {
    _channel = await widget.documentBloc.openProgressWebSocketChannel();
    _listenProgressWebSocketChannel();
  }

  _listenProgressWebSocketChannel() {
    _channel.stream.listen((message) {
      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) {
        if (isConnected) {
          this._getDocument(_selectedDocumentModeValue == all);
        }
      });
    }, onDone: () {
      Timer.periodic(Duration(seconds: 3), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        NetworkCheck _networkCheck = NetworkCheck();
        _networkCheck.check().then((isConnected) {
          if (isConnected) {
            timer.cancel();
            _reopenProgressWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tài liệu cuộc họp',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
          padding: EdgeInsets.fromLTRB(1, 0, 1, 1),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Divider(
                color: Colors.black,
                indent: 0,
                endIndent: 0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 10),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 150,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              _clickall ? Colors.red : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        onPressed: _onclickall,
                        child: Text(
                          "Tất cả",
                          style: TextStyle(
                            color: !_clickall ? Colors.red : Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              _clicknearly ? Colors.red : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        onPressed: _oncliecknearly,
                        child: Text(
                          "Gần đây",
                          style: TextStyle(
                            color: !_clicknearly ? Colors.red : Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: StreamBuilder<List<DocumentOutput>>(
                    stream: widget.documentBloc.documentListStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Container(
                              padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                              child: Row(
                                children: <Widget>[
                                  Image(
                                    image:
                                        AssetImage('lib/assets/icons/pdf.png'),
                                    width: 32,
                                    height: 32,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: GestureDetector(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              snapshot.data![index].name!,
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              StringUtils.calculateTimeBefore(
                                                  snapshot
                                                      .data![index].createAt),
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Divider(
                                              color: Colors.black12,
                                              thickness: 0.5,
                                              height: 0.5,
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          _viewDocument(
                                              snapshot.data![index].id!,
                                              snapshot.data![index]
                                                      .isAllowDownload ==
                                                  true);
                                        }),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    }),
              ),
            ],
          )),
    );
  }

  void _onclickall() {
    setState(() {
      _clicknearly = false;
      _clickall = true;
      _selectedDocumentModeValue = all;
    });
    this._getDocument(true);
  }

  void _oncliecknearly() {
    setState(() {
      _clicknearly = true;
      _clickall = false;
      _selectedDocumentModeValue = recent;
      this._getDocument(false);
    });
  }

  _viewDocument(String _documentID, bool _isAllowDownload) {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        Future<TResult> _fu =
            widget.documentBloc.getUrlDocumentByID(_documentID);
        _fu.then((res) async {
          if (res.status == 1) {
            var _url = api.BASE_URL + res.data;
            if (_isAllowDownload) {
              if (await canLaunch(_url)) {
                await launch(_url);
              } else {
                throw 'Could not launch $_url';
              }
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageDocumentViewer(link: _url),
                  ));
            }
          }
        });
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  _getDocument(bool _isGetAll) {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        widget.documentBloc.getDocuments(_isGetAll);
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_channel != null) {
      _channel.sink.close();
    }
  }
}
