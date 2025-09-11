import 'package:flutter/material.dart';
import 'package:nmeeting/bloc/documentBloc.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/home/document-viewer/page-document-viewer.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:nmeeting/models/progress.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/configs/constants.dart' as constants;

class PageLibrary extends StatefulWidget {
  PageLibrary({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageLibraryState();
  }
}

class _PageLibraryState extends State<PageLibrary> {
  final _documentBloc = DocumentBloc();
  @override
  void initState() {
    super.initState();
    this._getDocument();
  }

  _getDocument() {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        _documentBloc.getDocumentByPersonalID();
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Thư viện tài liệu',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              _searchView(),
              Expanded(
                child: Container(
                  child: StreamBuilder<List<LibraryOutput>>(
                      stream: _documentBloc.libraryListStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          if (snapshot.data!.length == 0) {
                            return _nodata();
                          }
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              if (snapshot.data![index].isDateGroup == true) {
                                return Container(
                                  padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                                  child: Text(
                                    StringUtils.convertDayToString(
                                        snapshot.data![index].name!),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }
                              return Container(
                                padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                                child: Row(
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                          'lib/assets/icons/pdf.png'),
                                      width: 32,
                                      height: 32,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: GestureDetector(
                                          child: Text(
                                            snapshot.data![index].name!,
                                            maxLines: 2,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 18),
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 40,
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(
          color: Color.fromRGBO(236, 236, 236, 1),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.bottom,
          onChanged: (value) {
            _documentBloc.search(value);
          },
          onSubmitted: (value) => {},
          decoration: InputDecoration(
              hintText: 'Tìm kiếm',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
        ),
      ),
    );
  }

  Widget _nodata() {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Image(
            image: AssetImage('lib/assets/images/no-data.png'),
            height: 80,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Không có tài liệu nào',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  _viewDocument(String _documentID, bool _isAllowDownload) {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        Future<TResult> _fu = _documentBloc.getUrlDocumentByID(_documentID);
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
}
