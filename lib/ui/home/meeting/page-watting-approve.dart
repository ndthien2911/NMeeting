import 'dart:async';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nmeeting/bloc/in-meeting/wattingApproveBloc.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/bloc/notifyBloc.dart';
import 'package:nmeeting/models/in-meeting/user-meeting.dart';
import 'package:nmeeting/models/in-meeting/wattingApprove.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/ui/home/meeting/page-meeting-create.dart';
import 'package:nmeeting/utilities/common-utils.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:web_socket_channel/io.dart';
import 'package:nmeeting/configs/constants.dart' as constants;

class PageWaittingApprove extends StatefulWidget {
  final MeetingBloc meetingBloc;
  final void Function() onTabProgress;

  const PageWaittingApprove(
      {Key key, @required this.meetingBloc, this.onTabProgress})
      : super(key: key);
  @override
  _PageWaittingApproveState createState() => _PageWaittingApproveState();
}

class _PageWaittingApproveState extends State<PageWaittingApprove> {
  final _bloc = WattingApproveBloc();
  final _notifyBloc = NotifyBloc();
  IOWebSocketChannel _notifyChannel;
  bool _haveSelectFlg = false;
  double _sizeBtn = 134;
  double _sizeFont = 17;
  double _sizeFontTitle = 25;
  int _sizeDevice = constants.DEVICE_NORMAL;
  ScrollController _scrollController;
  double _marginBottom = 20;
  int weekSelectedValue = 0;

  _scrollListener() {
    print(_scrollController.position.maxScrollExtent);
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        setState(() {
          _marginBottom = 20;
        });
      } else {
        setState(() {
          _marginBottom = 80;
        });
      }
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    super.initState();
    this._getAll();
    widget.meetingBloc.actionSelecteFlgStream.listen((onData) {
      this._clickAllItem(onData);
    });

    widget.meetingBloc.weekSelectedStream.listen((onData) {
      this.weekSelectedValue = onData;
      this._getAll();
    });

    this._checkHasSelect();

    _bloc.meetingCountStream.listen((onData) {
      widget.meetingBloc.onSetMeetingCount(onData);
    });

    _openNotifyWebSocketChannel();
  }

  _openNotifyWebSocketChannel() async {
    _notifyChannel = await _notifyBloc.openNotifyWebSocketChannel();
    _listenNotifyWebSocketChannel();
  }

  _listenNotifyWebSocketChannel() {
    _notifyChannel.stream.listen((message) async {}, onDone: () {
      Timer.periodic(Duration(seconds: 3), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        NetworkCheck _networkCheck = NetworkCheck();
        _networkCheck.check().then((isConnected) {
          if (isConnected) {
            timer.cancel();
            _openNotifyWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  _clickAllItem(flag) {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        _bloc.clickAllItem(flag);
        this._checkHasSelect();
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  _getAll() {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        _bloc.getAll(this.weekSelectedValue);
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  _clickItem(String itemID, bool selecteFlg) {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        _bloc.clickItem(itemID, selecteFlg);
        _checkHasSelect();
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  _checkHasSelect() {
    if (_bloc.checkHasSelect() == true) {
      setState(() {
        _haveSelectFlg = true;
      });
    } else {
      setState(() {
        _haveSelectFlg = false;
      });
    }
  }

  _clickBtnBottom(isApproveFlg) {
    if (isApproveFlg == true) {
      this._approveMeeting();
    } else {
      this._createMeeting();
    }
  }

  _editMeeting(String id) async {
    String _resultStr = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PageCreateMeeting(meetingBloc: widget.meetingBloc, meetingId: id),
      ),
    );

    if (!StringUtils.isNullOrEmpty(_resultStr) &&
        _resultStr == constants.STATUS_SUCCESS) {
      this._getAll();
      //reset button bottom
      setState(() {
        _haveSelectFlg = false;
      });

      List<String> listEventID = new List<String>();
      listEventID.add(id);
      Future<TResult> _notifyFu = _notifyBloc.getUsersByMeetingIDs(listEventID);
      _notifyFu.then((res) {
        if (res.status == 1) {
          _notifyChannel.sink.add(res.data);
        }
      });
    }

    _resetValue();
  }

  _resetValue() {
    widget.meetingBloc.onSetMeetingAdminInput("[]");
    widget.meetingBloc.onSetMeetingMemberInput("[]");
    widget.meetingBloc.onSetMeetingAdminToServer(new List<MemberVM>());
    widget.meetingBloc.onSetMeetingUserToServer(new List<MemberVM>());
  }

  _createMeeting() async {
    String _resultStr = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PageCreateMeeting(meetingBloc: widget.meetingBloc),
      ),
    );

    if (!StringUtils.isNullOrEmpty(_resultStr) &&
        _resultStr == constants.STATUS_SUCCESS) {
      this._getAll();
    }

    _resetValue();
  }

  _approveMeeting() {
    _showConfirmApproveDialog();
  }

  _showConfirmApproveDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: VNPTDialogType.normal,
            title: 'Xác nhận duyệt cuộc họp',
            styleTitle: TextStyle(
                fontSize: _sizeFontTitle,
                color: Color.fromARGB(255, 0, 0, 128),
                fontWeight: FontWeight.bold),
            description:
                'Cuộc họp sẽ được duyệt và chuyển sang danh sách đã duyệt',
            actions: <Widget>[
              ButtonTheme(
                minWidth: _sizeBtn,
                height: 40,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20),
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 128),
                      )),
                  color: Colors.white,
                  textColor: Color.fromARGB(255, 0, 0, 128),
                  child: Text("Huỷ",
                      style: TextStyle(
                          fontSize: _sizeFont, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ButtonTheme(
                minWidth: _sizeBtn,
                height: 40,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20),
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 108, 183),
                      )),
                  color: Color.fromARGB(255, 0, 108, 183),
                  textColor: Colors.white,
                  child: Text("Đồng ý",
                      style: TextStyle(
                          fontSize: _sizeFont, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    List<String> listIDSelected = _bloc.getListIDSelected();
                    Future<dynamic> _resultFuture = _bloc.changeMode(
                        constants.MODE_APPROVED, constants.MODE_WAITING);
                    _resultFuture.then((res) async {
                      if (res.toString() == constants.STATUS_SUCCESS) {
                        _getAll();
                        setState(() {
                          _haveSelectFlg = false;
                        });
                        Future<TResult> _notifyFu =
                            _notifyBloc.getUsersByMeetingIDs(listIDSelected);
                        _notifyFu.then((res) {
                          if (res.status == 1) {
                            _notifyChannel.sink.add(res.data);
                          }
                        });
                      } else {
                        showToast(res.toString());
                      }
                    });
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
        });
  }

  _showConfirmDeleteDialog(String meetingID) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: VNPTDialogType.normal,
            title: 'Xác nhận xoá cuộc họp',
            styleTitle: TextStyle(
                fontSize: _sizeFontTitle,
                color: Color.fromARGB(255, 0, 0, 128),
                fontWeight: FontWeight.bold),
            description: 'Bạn có chắc chắn muốn xoá cuộc họp này?',
            actions: <Widget>[
              ButtonTheme(
                minWidth: _sizeBtn,
                height: 40,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20),
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 128),
                      )),
                  color: Colors.white,
                  textColor: Color.fromARGB(255, 0, 0, 128),
                  child: Text("Huỷ",
                      style: TextStyle(
                          fontSize: _sizeFont, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ButtonTheme(
                minWidth: _sizeBtn,
                height: 40,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20),
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 108, 183),
                      )),
                  color: Color.fromARGB(255, 0, 108, 183),
                  textColor: Colors.white,
                  child: Text("Xoá",
                      style: TextStyle(
                          fontSize: _sizeFont, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Future<dynamic> _resultFuture =
                        _bloc.deleteItem(constants.MODE_WAITING, meetingID);
                    _resultFuture.then((res) async {
                      if (res.toString() == constants.STATUS_SUCCESS) {
                        this._getAll();
                        //reset button bottom
                        setState(() {
                          _haveSelectFlg = false;
                        });

                        Future<TResult> _notifyFu =
                            _notifyBloc.getUsersByMeetingIDs([meetingID]);
                        _notifyFu.then((res) {
                          if (res.status == 1) {
                            _notifyChannel.sink.add(res.data);
                          }
                        });
                      } else {
                        showToast(res.toString());
                      }
                    });
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
        });
  }

  _showConfirmRejectDialog(String meetingID) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: VNPTDialogType.normal,
            title: 'Xác nhận từ chối duyệt',
            styleTitle: TextStyle(
                fontSize: _sizeFontTitle,
                color: Color.fromARGB(255, 0, 0, 128),
                fontWeight: FontWeight.bold),
            description: 'Bạn có chắc chắn từ chối duyệt cuộc họp này?',
            actions: <Widget>[
              ButtonTheme(
                minWidth: _sizeBtn,
                height: 40,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20),
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 128),
                      )),
                  color: Colors.white,
                  textColor: Color.fromARGB(255, 0, 0, 128),
                  child: Text("Huỷ",
                      style: TextStyle(
                          fontSize: _sizeFont, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ButtonTheme(
                minWidth: _sizeBtn,
                height: 40,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20),
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 108, 183),
                      )),
                  color: Color.fromARGB(255, 0, 108, 183),
                  textColor: Colors.white,
                  child: Text("Từ chối duyệt",
                      style: TextStyle(
                          fontSize: _sizeFont, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Future<dynamic> _resultFuture =
                        _bloc.rejectItem(constants.MODE_WAITING, meetingID);
                    _resultFuture.then((res) async {
                      if (res.toString() == constants.STATUS_SUCCESS) {
                        this._getAll();
                        //reset button bottom
                        setState(() {
                          _haveSelectFlg = false;
                        });

                        Future<TResult> _notifyFu =
                            _notifyBloc.getUsersByMeetingIDs([meetingID]);
                        _notifyFu.then((res) {
                          if (res.status == 1) {
                            _notifyChannel.sink.add(res.data);
                          }
                        });
                      } else {
                        showToast(res.toString());
                      }
                    });
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    if (_notifyChannel != null) {
      _notifyChannel.sink.close();
    }
  }

  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    if (_mediaQuery.size.width <= 320) {
      _sizeBtn = 90;
      _sizeFont = 13;
      _sizeFontTitle = 17;
      _sizeDevice = constants.DEVICE_480;
    } else if (_mediaQuery.size.width <= 400) {
      _sizeBtn = 90;
      _sizeFont = 13;
      _sizeFontTitle = 19;
      _sizeDevice = constants.DEVICE_1038;
    } else if (_mediaQuery.size.width <= 420) {
      _sizeBtn = 90;
      _sizeFont = 13;
      _sizeFontTitle = 19;
      _sizeDevice = constants.DEVICE_1080;
    }

    return Scaffold(
      body: Center(
          child: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<MeetingObj>>(
                stream: _bloc.meetingListStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      return _nodata();
                    }
                    return Container(
                      //padding: EdgeInsets.only(bottom: _marginBottom),
                      margin: EdgeInsets.only(bottom: _marginBottom),
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            //#region
                            // child: Padding(
                            //   padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            //   child: Container(
                            //     child: Material(
                            //       color: Colors.white,
                            //       elevation: 2,
                            //       borderRadius: BorderRadius.circular(3),
                            //       shadowColor: Color(0x802196F3),
                            //       child: Slidable(
                            //         actionPane: SlidableDrawerActionPane(),
                            //         actionExtentRatio: 0.25,
                            //         child: Container(
                            //           // decoration: BoxDecoration(
                            //           //   color: Colors.redAccent
                            //           // ),
                            //           color: Colors.white,
                            //           child: Padding(
                            //             padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            //             child: Column(
                            //               mainAxisAlignment: MainAxisAlignment.start,
                            //               crossAxisAlignment: CrossAxisAlignment.start,
                            //               children: <Widget>[
                            //                 Wrap(
                            //                   children: <Widget>[
                            //                     Row(
                            //                       crossAxisAlignment: CrossAxisAlignment.start,
                            //                       children: <Widget>[
                            //                         Container(
                            //                           padding: EdgeInsets.fromLTRB(0, 0 , 10 , 0),
                            //                           alignment: Alignment.topCenter,
                            //                           child: Image(
                            //                             image: AssetImage('lib/assets/icons/meeting.png'),
                            //                             height: 27,
                            //                           )
                            //                         ),
                            //                         Expanded(
                            //                           flex: 9,
                            //                           child: Column(
                            //                             mainAxisAlignment: MainAxisAlignment.center,
                            //                             children: <Widget>[
                            //                               Row(
                            //                                 mainAxisAlignment: MainAxisAlignment.start,
                            //                                 children: <Widget>[
                            //                                   Flexible(
                            //                                     child: Container(
                            //                                       margin: EdgeInsets.fromLTRB(0, 0 , 0, 10),
                            //                                       padding: EdgeInsets.all(0),
                            //                                       alignment: Alignment.topLeft,
                            //                                       child: Column(
                            //                                       mainAxisAlignment: MainAxisAlignment.start,
                            //                                       children: <Widget>[
                            //                                           Container(
                            //                                             margin: EdgeInsets.fromLTRB(0, 0 , 0, 10),
                            //                                             padding: EdgeInsets.all(0),
                            //                                             alignment: Alignment.topLeft,
                            //                                             child:Text(snapshot.data[index].name?.toUpperCase(),
                            //                                                 style: TextStyle(
                            //                                                     fontSize: 15,
                            //                                                     fontWeight: FontWeight.bold,
                            //                                                     color: Color.fromARGB(255, 0, 0, 128)
                            //                                                 )
                            //                                               ),
                            //                                             ),
                            //                                             Container(
                            //                                             margin: EdgeInsets.fromLTRB(0, 0 , 0, 10),
                            //                                             padding: EdgeInsets.all(0),
                            //                                             alignment: Alignment.topLeft,
                            //                                             child:Text("Chủ trì: " + snapshot.data[index].adminNmList,
                            //                                                 style: TextStyle(
                            //                                                     fontSize: 15,
                            //                                                     fontWeight: FontWeight.bold,
                            //                                                     color: Color.fromARGB(255, 0, 0, 128)
                            //                                                 )
                            //                                               ),
                            //                                             ),
                            //                                             Container(
                            //                                             margin: EdgeInsets.fromLTRB(0, 0 , 0, 10),
                            //                                             padding: EdgeInsets.all(0),
                            //                                             alignment: Alignment.topLeft,
                            //                                             child:Text("Thành phần: " +snapshot.data[index].memberNmList,
                            //                                                 style: TextStyle(
                            //                                                     fontSize: 15,
                            //                                                     fontWeight: FontWeight.normal,
                            //                                                     color: Color.fromARGB(255, 0, 0, 128)
                            //                                                 )
                            //                                               ),
                            //                                             ),
                            //                                             Container(
                            //                                             margin: EdgeInsets.fromLTRB(0, 0 , 0, 10),
                            //                                             padding: EdgeInsets.all(0),
                            //                                             alignment: Alignment.topLeft,
                            //                                             child:Text("Địa điểm: " +snapshot.data[index].address,
                            //                                                 style: TextStyle(
                            //                                                     fontSize: 15,
                            //                                                     fontWeight: FontWeight.normal,
                            //                                                     color: Color.fromARGB(255, 0, 0, 128)
                            //                                                 )
                            //                                               ),
                            //                                             ),
                            //                                       ]
                            //                                     ),
                            //                                     )
                            //                                   ),
                            //                                 ],
                            //                               ),
                            //                               if (_sizeDevice == constants.DEVICE_480)
                            //                                 Row(
                            //                                   mainAxisAlignment: MainAxisAlignment.start,
                            //                                   children: <Widget>[
                            //                                     Expanded(
                            //                                       flex: 8, // 20%
                            //                                       child: Column(
                            //                                         mainAxisAlignment: MainAxisAlignment.start,
                            //                                         children: <Widget>[
                            //                                           Row(
                            //                                             mainAxisAlignment: MainAxisAlignment.start,
                            //                                             children: <Widget>[
                            //                                               Image(
                            //                                                 image: AssetImage('lib/assets/icons/clock.png'),
                            //                                                 height: 17,
                            //                                               ),
                            //                                               Text("  " + StringUtils.convertTimeFromString(snapshot.data[index].startAt,'hh:mm')  + (!StringUtils.isNullOrEmpty(snapshot.data[index].endAt)?"-" + StringUtils.convertTimeFromString(snapshot.data[index].endAt,'hh:mm'):""),
                            //                                                 style: TextStyle(
                            //                                                     fontSize: 13,
                            //                                                     fontWeight: FontWeight.bold,
                            //                                                     color: Color.fromARGB(255, 123, 123, 123),
                            //                                                 ),
                            //                                               )
                            //                                             ],
                            //                                           ),
                            //                                           SizedBox(
                            //                                             height: 5,
                            //                                           ),
                            //                                           Row(
                            //                                             mainAxisAlignment: MainAxisAlignment.start,
                            //                                             children: <Widget>[
                            //                                               Image(
                            //                                                 image: AssetImage('lib/assets/icons/calendar.png'),
                            //                                                 height: 17,
                            //                                               ),
                            //                                               Text("  " + StringUtils.convertTimeFromString(snapshot.data[index].meetingDate,'dd/MM/YYYY'),
                            //                                                 style: TextStyle(
                            //                                                     fontSize: 13,
                            //                                                     fontWeight: FontWeight.bold,
                            //                                                     color: Color.fromARGB(255, 123, 123, 123)
                            //                                                 ),
                            //                                               )
                            //                                             ],
                            //                                           )
                            //                                         ],
                            //                                       ),
                            //                                     ),
                            //                                     Expanded(
                            //                                       flex: 2,
                            //                                       child: Row(
                            //                                         mainAxisAlignment: MainAxisAlignment.end,
                            //                                         children: <Widget>[
                            //                                           if (StringUtils.isNullOrEmpty(snapshot.data[index].approveAt)
                            //                                              && (snapshot.data[index].approveFlg == constants.STATUS_MEETING_WAITING  || snapshot.data[index].approveFlg == null))
                            //                                           this.buttonSelect(snapshot.data[index].selectFlg)
                            //                                         ],
                            //                                       )
                            //                                     )
                            //                                   ]
                            //                                 ),
                            //                               if (_sizeDevice == constants.DEVICE_1038)
                            //                                 Row(
                            //                                   mainAxisAlignment: MainAxisAlignment.start,
                            //                                   children: <Widget>[
                            //                                     Expanded(
                            //                                       flex: 5,
                            //                                       child: Row(
                            //                                         mainAxisAlignment: MainAxisAlignment.start,
                            //                                         children: <Widget>[
                            //                                           Image(
                            //                                             image: AssetImage('lib/assets/icons/clock.png'),
                            //                                             height: 17,
                            //                                           ),
                            //                                           Text("  " + StringUtils.convertTimeFromString(snapshot.data[index].startAt,'hh:mm')  + (!StringUtils.isNullOrEmpty(snapshot.data[index].endAt)?"-" + StringUtils.convertTimeFromString(snapshot.data[index].endAt,'hh:mm'):""),
                            //                                             style: TextStyle(
                            //                                                 fontSize: 13,
                            //                                                 fontWeight: FontWeight.bold,
                            //                                                 color: Color.fromARGB(255, 123, 123, 123),
                            //                                             ),
                            //                                           )
                            //                                         ],
                            //                                       ),
                            //                                     ),
                            //                                     Expanded(
                            //                                       flex: 4,
                            //                                       child: Row(
                            //                                         mainAxisAlignment: MainAxisAlignment.end,
                            //                                         children: <Widget>[
                            //                                           Image(
                            //                                             image: AssetImage('lib/assets/icons/calendar.png'),
                            //                                             height: 17,
                            //                                           ),
                            //                                           Text("  " + StringUtils.convertTimeFromString(snapshot.data[index].meetingDate,'dd/MM/YYYY'),
                            //                                             style: TextStyle(
                            //                                                 fontSize: 13,
                            //                                                 fontWeight: FontWeight.bold,
                            //                                                 color: Color.fromARGB(255, 123, 123, 123)
                            //                                             ),
                            //                                           )
                            //                                         ],
                            //                                       ),
                            //                                     ),
                            //                                     Expanded(
                            //                                       flex: 1,
                            //                                       child: Row(
                            //                                         mainAxisAlignment: MainAxisAlignment.end,
                            //                                         children: <Widget>[
                            //                                           if (StringUtils.isNullOrEmpty(snapshot.data[index].approveAt)
                            //                                              && (snapshot.data[index].approveFlg == constants.STATUS_MEETING_WAITING  || snapshot.data[index].approveFlg == null))
                            //                                           this.buttonSelect(snapshot.data[index].selectFlg)
                            //                                         ],
                            //                                       )
                            //                                     )
                            //                                   ]
                            //                                 ),
                            //                               if (_sizeDevice != constants.DEVICE_480 && _sizeDevice != constants.DEVICE_1038)
                            //                               Row(
                            //                                 mainAxisAlignment: MainAxisAlignment.start,
                            //                                 children: <Widget>[
                            //                                   Expanded(
                            //                                     flex: 4, // 20%
                            //                                     child: Row(
                            //                                       mainAxisAlignment: MainAxisAlignment.start,
                            //                                       children: <Widget>[
                            //                                         Image(
                            //                                           image: AssetImage('lib/assets/icons/clock.png'),
                            //                                           height: 17,
                            //                                         ),
                            //                                         Text("  " + StringUtils.convertTimeFromString(snapshot.data[index].startAt,'hh:mm')  + (!StringUtils.isNullOrEmpty(snapshot.data[index].endAt)?"-" + StringUtils.convertTimeFromString(snapshot.data[index].endAt,'hh:mm'):""),
                            //                                           style: TextStyle(
                            //                                               fontSize: 13,
                            //                                               fontWeight: FontWeight.bold,
                            //                                               color: Color.fromARGB(255, 123, 123, 123),
                            //                                           ),
                            //                                         )
                            //                                       ],
                            //                                     ),
                            //                                   ),
                            //                                   Expanded(
                            //                                     flex: 4, // 60%
                            //                                     child: Row(
                            //                                       mainAxisAlignment: MainAxisAlignment.start,
                            //                                       children: <Widget>[
                            //                                         Image(
                            //                                           image: AssetImage('lib/assets/icons/calendar.png'),
                            //                                           height: 17,
                            //                                         ),
                            //                                         Text("  " + StringUtils.convertTimeFromString(snapshot.data[index].meetingDate,'dd/MM/YYYY'),
                            //                                           style: TextStyle(
                            //                                               fontSize: 13,
                            //                                               fontWeight: FontWeight.bold,
                            //                                               color: Color.fromARGB(255, 123, 123, 123)
                            //                                           ),
                            //                                         )
                            //                                       ],
                            //                                     ),
                            //                                   ),
                            //                                   Expanded(
                            //                                     flex: 2,
                            //                                     child: Row(
                            //                                       mainAxisAlignment: MainAxisAlignment.end,
                            //                                       children: <Widget>[
                            //                                         if (StringUtils.isNullOrEmpty(snapshot.data[index].approveAt)
                            //                                              && (snapshot.data[index].approveFlg == constants.STATUS_MEETING_WAITING || snapshot.data[index].approveFlg == null))
                            //                                           this.buttonSelect(snapshot.data[index].selectFlg)
                            //                                       ],
                            //                                     )
                            //                                   )
                            //                                 ]
                            //                               ),
                            //                               if (!StringUtils.isNullOrEmpty(snapshot.data[index].approveAt)
                            //                                 && (snapshot.data[index].approveFlg == constants.STATUS_MEETING_WAITING || snapshot.data[index].approveFlg == null))
                            //                               Container(
                            //                                 padding: EdgeInsets.only(top: 10),
                            //                                 child: Row(
                            //                                   mainAxisAlignment: MainAxisAlignment.start,
                            //                                   children: <Widget>[
                            //                                     Text("Cancelled approval",
                            //                                       style: TextStyle(
                            //                                             fontSize: 13,
                            //                                             fontWeight: FontWeight.bold,
                            //                                             color: Colors.red
                            //                                         ),
                            //                                       ),
                            //                                       Expanded(
                            //                                         flex: 2,
                            //                                         child: Row(
                            //                                           mainAxisAlignment: MainAxisAlignment.end,
                            //                                           children: <Widget>[
                            //                                             this.buttonSelect(snapshot.data[index].selectFlg)
                            //                                           ],
                            //                                         )
                            //                                       )
                            //                                   ]
                            //                                 ),
                            //                               ),
                            //                               if (snapshot.data[index].approveFlg == constants.STATUS_MEETING_REJECT)
                            //                               Container(
                            //                                 padding: EdgeInsets.only(top: 10),
                            //                                 child: Row(
                            //                                   mainAxisAlignment: MainAxisAlignment.start,
                            //                                   children: <Widget>[
                            //                                     Text("Rejected",
                            //                                       style: TextStyle(
                            //                                             fontSize: 13,
                            //                                             fontWeight: FontWeight.bold,
                            //                                             color: Colors.red
                            //                                         ),
                            //                                       ),
                            //                                       Expanded(
                            //                                         flex: 2,
                            //                                         child: Row(
                            //                                           mainAxisAlignment: MainAxisAlignment.end,
                            //                                           children: <Widget>[
                            //                                             this.buttonSelect(snapshot.data[index].selectFlg)
                            //                                           ],
                            //                                         )
                            //                                       )
                            //                                   ]
                            //                                 ),
                            //                               )
                            //                             ],
                            //                           ),
                            //                         )
                            //                       ],
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ],
                            //             ),
                            //           )
                            //         ),
                            //         secondaryActions: <Widget>[
                            //           if (CommonUtils.checkRole(constants.BTN_NAME_EDIT, widget.meetingBloc.onGetRoleAppStr()) == true)
                            //             IconSlideAction(
                            //               color: Color.fromARGB(255, 235, 131, 52),
                            //               iconWidget: Image(
                            //                 image: AssetImage('lib/assets/icons/edit.png'),
                            //                 width: 23,
                            //                 height: 23,
                            //               ),
                            //               onTap: ()  {
                            //                 _editMeeting(snapshot.data[index].id);
                            //               }
                            //             ),
                            //           if (CommonUtils.checkRole(constants.BTN_NAME_DELETE, widget.meetingBloc.onGetRoleAppStr()) == true)
                            //             IconSlideAction(
                            //               color: Color.fromARGB(255, 246, 31, 31),
                            //               iconWidget: Image(
                            //                 image: AssetImage('lib/assets/icons/delete.png'),
                            //                 width: 23,
                            //                 height: 23,
                            //               ),
                            //               onTap: ()  {
                            //                 _showConfirmDeleteDialog(snapshot.data[index].id);
                            //               }
                            //             ),
                            //           if (CommonUtils.checkRole(constants.BTN_NAME_REJECT, widget.meetingBloc.onGetRoleAppStr()) == true
                            //             && snapshot.data[index].approveFlg != constants.STATUS_MEETING_REJECT)
                            //             IconSlideAction(
                            //               color: Color.fromARGB(255, 161, 161, 161),
                            //               iconWidget: Image(
                            //                 image: AssetImage('lib/assets/icons/reject.png'),
                            //                 width: 23,
                            //                 height: 23,
                            //               ),
                            //               onTap: ()  {
                            //                 _showConfirmRejectDialog(snapshot.data[index].id);
                            //               }
                            //             ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            //#endregion
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Material(
                                          color: Color.fromARGB(
                                              255, 251, 251, 251),
                                          //elevation: 2,
                                          //borderRadius: BorderRadius.circular(3),
                                          //shadowColor: Color(0x802196F3),
                                          child: Slidable(
                                            actionPane:
                                                SlidableDrawerActionPane(),
                                            actionExtentRatio: 0.25,
                                            child: Container(
                                                child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Wrap(
                                                    children: <Widget>[
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                // hh:mm
                                                                Container(
                                                                    margin: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    //padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                                                    //alignment: Alignment.topLeft,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            251,
                                                                            251,
                                                                            251),
                                                                    child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .spaceBetween,
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                              padding: EdgeInsets.fromLTRB(10, 3, 10, 3), //.fromARGB(255, 66, 133, 244),
                                                                              margin: EdgeInsets.only(bottom: 2),
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(7),
                                                                                color: Color.fromARGB(255, 66, 133, 244),
                                                                              ),
                                                                              child: Text(
                                                                                StringUtils.convertTimeFromString(snapshot.data[index].startAt, 'hh:mm') + (!StringUtils.isNullOrEmpty(snapshot.data[index].endAt) ? "-" + StringUtils.convertTimeFromString(snapshot.data[index].endAt, 'hh:mm') : ""),
                                                                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                                                                              )),
                                                                          if (snapshot
                                                                              .data[index]
                                                                              .hiddenRejectFlg)
                                                                            Container(
                                                                                padding: EdgeInsets.fromLTRB(10, 3, 10, 3), //.fromARGB(255, 66, 133, 244),
                                                                                margin: EdgeInsets.only(bottom: 2),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(7),
                                                                                  color: Color.fromARGB(255, 251, 188, 5),
                                                                                ),
                                                                                child: Text(
                                                                                  "VTTP",
                                                                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                                                                                )),
                                                                          if (snapshot.data[index].approveFlg ==
                                                                              constants.STATUS_MEETING_REJECT)
                                                                            Container(
                                                                                padding: EdgeInsets.fromLTRB(5, 3, 5, 3), //.fromARGB(255, 66, 133, 244),
                                                                                margin: EdgeInsets.only(bottom: 2),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(7),
                                                                                  color: Colors.red,
                                                                                ),
                                                                                child: Icon(Icons.block, size: 20, color: Colors.white)),
                                                                          Container(
                                                                              padding: EdgeInsets.fromLTRB(7, 3, 7, 3),
                                                                              //color: Color.fromARGB(255, 66, 133, 244),
                                                                              child: Text(
                                                                                StringUtils.getWeekday(snapshot.data[index].meetingDate) + ', ' + StringUtils.convertTimeFromString(snapshot.data[index].meetingDate, 'dd/MM') + (snapshot.data[index].meetingEndDate == snapshot.data[index].meetingDate ? '' : '-' + StringUtils.convertTimeFromString(snapshot.data[index].meetingEndDate, 'dd/MM')),
                                                                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),
                                                                              )),
                                                                        ])),

                                                                // content
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Flexible(
                                                                        child:
                                                                            Container(
                                                                      //color: Colors.white,
                                                                      margin: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              5),
                                                                          border: Border.all(
                                                                              width: snapshot.data[index].selectFlg ? 4.0 : 1.0,
                                                                              color: snapshot.data[index].selectFlg ? Color.fromARGB(255, 66, 133, 244) : Colors.black45)),
                                                                      child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .start,
                                                                          children: <
                                                                              Widget>[
                                                                            Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
                                                                              padding: EdgeInsets.all(0),
                                                                              alignment: Alignment.topLeft,
                                                                              child: Text(snapshot.data[index].name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 66, 133, 244), decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                            ),
                                                                            Container(
                                                                                margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                                padding: EdgeInsets.all(0),
                                                                                alignment: Alignment.topLeft,
                                                                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                  Text("Chủ trì: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold, decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                  Flexible(
                                                                                    child: Container(
                                                                                      child: Text(snapshot.data[index].adminNmList, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0), decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                    ),
                                                                                  )
                                                                                ])),
                                                                            if (!StringUtils.isNullOrEmpty(snapshot.data[index].note))
                                                                              Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                                  padding: EdgeInsets.all(0),
                                                                                  alignment: Alignment.topLeft,
                                                                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                    Text("Chuẩn bị: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold, decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                    Flexible(
                                                                                      child: Container(
                                                                                        child: Text(snapshot.data[index].note, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0), decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                      ),
                                                                                    )
                                                                                  ])),
                                                                            Container(
                                                                                margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                                padding: EdgeInsets.all(0),
                                                                                alignment: Alignment.topLeft,
                                                                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                  Text("T.Phần: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold, decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                  Flexible(
                                                                                    child: Container(
                                                                                      child: Text(snapshot.data[index].memberNmList, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0), decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                    ),
                                                                                  )
                                                                                ])),
                                                                            if (!StringUtils.isNullOrEmpty(snapshot.data[index].guest))
                                                                              Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                                  padding: EdgeInsets.all(0),
                                                                                  alignment: Alignment.topLeft,
                                                                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                    Text("Mời: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold, decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                    Flexible(
                                                                                      child: Container(
                                                                                        child: Text(snapshot.data[index].guest, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0), decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                      ),
                                                                                    )
                                                                                  ])),
                                                                            Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                              padding: EdgeInsets.all(0),
                                                                              alignment: Alignment.topLeft,
                                                                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                Text("Địa chỉ: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold, decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                Flexible(
                                                                                  child: Container(
                                                                                    child: Text(snapshot.data[index].address, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0), decoration: snapshot.data[index].cancelApproved ? TextDecoration.lineThrough : TextDecoration.none)),
                                                                                  ),
                                                                                )
                                                                              ]),
                                                                            ),
                                                                            // if (snapshot.data[index].hiddenRejectFlg)
                                                                            //   Container(margin: EdgeInsets.fromLTRB(10, 0, 0, 0), padding: EdgeInsets.all(0), alignment: Alignment.topRight, child: Text("Lịch đăng ký VTTP", overflow: TextOverflow.visible, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color.fromARGB(255, 0, 0, 128)))),

                                                                            // if (snapshot.data[index].selectFlg)
                                                                            //   Container(
                                                                            //     padding: EdgeInsets.only(top: 0),
                                                                            //     child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                                                                            //       if (snapshot.data[index].approveFlg == constants.STATUS_MEETING_REJECT)
                                                                            //         Container(
                                                                            //             alignment: Alignment.topRight,
                                                                            //             padding: EdgeInsets.only(right: 10),
                                                                            //             child: Text(
                                                                            //               "Lịch đã bị Từ chối duyệt",
                                                                            //               style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
                                                                            //             )),
                                                                            //       Container(
                                                                            //           child: Row(
                                                                            //         mainAxisAlignment: MainAxisAlignment.end,
                                                                            //         children: <Widget>[
                                                                            //           this.buttonSelect(snapshot.data[index].selectFlg)
                                                                            //         ],
                                                                            //       ))
                                                                            //     ]),
                                                                            //   )
                                                                          ]),
                                                                    )),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )),
                                            secondaryActions: <Widget>[
                                              if (CommonUtils.checkRole(
                                                          constants
                                                              .BTN_NAME_EDIT,
                                                          widget.meetingBloc
                                                              .onGetRoleAppStr()) ==
                                                      true &&
                                                  snapshot.data[index]
                                                          .modifyFlg ==
                                                      true)
                                                IconSlideAction(
                                                    color: Color.fromARGB(
                                                        255, 235, 131, 52),
                                                    iconWidget: Image(
                                                      image: AssetImage(
                                                          'lib/assets/icons/edit.png'),
                                                      width: 23,
                                                      height: 23,
                                                    ),
                                                    onTap: () {
                                                      _editMeeting(snapshot
                                                          .data[index].id);
                                                    }),
                                              if (CommonUtils.checkRole(
                                                          constants
                                                              .BTN_NAME_DELETE,
                                                          widget.meetingBloc
                                                              .onGetRoleAppStr()) ==
                                                      true &&
                                                  snapshot.data[index]
                                                          .modifyFlg ==
                                                      true)
                                                IconSlideAction(
                                                    color: Color.fromARGB(
                                                        255, 246, 31, 31),
                                                    iconWidget: Image(
                                                      image: AssetImage(
                                                          'lib/assets/icons/delete.png'),
                                                      width: 23,
                                                      height: 23,
                                                    ),
                                                    onTap: () {
                                                      _showConfirmDeleteDialog(
                                                          snapshot
                                                              .data[index].id);
                                                    }),
                                              if (CommonUtils.checkRole(
                                                          constants
                                                              .BTN_NAME_REJECT,
                                                          widget.meetingBloc
                                                              .onGetRoleAppStr()) ==
                                                      true &&
                                                  snapshot.data[index]
                                                          .approveFlg !=
                                                      constants
                                                          .STATUS_MEETING_REJECT &&
                                                  snapshot.data[index]
                                                          .hiddenRejectFlg !=
                                                      true)
                                                IconSlideAction(
                                                    color: Color.fromARGB(
                                                        255, 161, 161, 161),
                                                    iconWidget: Image(
                                                      image: AssetImage(
                                                          'lib/assets/icons/reject.png'),
                                                      width: 23,
                                                      height: 23,
                                                    ),
                                                    onTap: () {
                                                      _showConfirmRejectDialog(
                                                          snapshot
                                                              .data[index].id);
                                                    }),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ])),
                            onTap: () async {
                              if (CommonUtils.checkRole(
                                  constants.BTN_NAME_APPROVE,
                                  widget.meetingBloc.onGetRoleAppStr())) {
                                _clickItem(snapshot.data[index].id,
                                    !snapshot.data[index].selectFlg);
                              }
                            },
                          );
                        },
                      ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                }),
          ),
        ],
      )),
      floatingActionButton: _renderBtnBottom(),
    );
  }

  Widget _renderBtnBottom() {
    if (CommonUtils.checkRole(constants.BTN_NAME_APPROVE,
                widget.meetingBloc.onGetRoleAppStr()) ==
            true &&
        CommonUtils.checkRole(
                constants.BTN_NAME_ADD, widget.meetingBloc.onGetRoleAppStr()) ==
            true) {
      return GestureDetector(
        child: _haveSelectFlg != true
            ? Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 4, 108, 180),
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  )
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 4, 108, 180),
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                ],
              ),
        onTap: () {
          this._clickBtnBottom(_haveSelectFlg);
        },
      );
    } else if (CommonUtils.checkRole(
            constants.BTN_NAME_APPROVE, widget.meetingBloc.onGetRoleAppStr()) ==
        true) {
      return GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 4, 108, 180),
                  borderRadius: BorderRadius.circular(25)),
            ),
            Icon(
              Icons.check,
              color: Colors.white,
            )
          ],
        ),
        onTap: () {
          this._clickBtnBottom(true);
        },
      );
    } else if (CommonUtils.checkRole(
            constants.BTN_NAME_ADD, widget.meetingBloc.onGetRoleAppStr()) ==
        true) {
      return GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 4, 108, 180),
                  borderRadius: BorderRadius.circular(25)),
            ),
            Icon(
              Icons.add,
              color: Colors.white,
            )
          ],
        ),
        onTap: () {
          this._clickBtnBottom(false);
        },
      );
    }

    return null;
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
            height: 68,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Không có cuộc họp nào',
            style: TextStyle(
                fontSize: 20, color: Color.fromARGB(255, 123, 123, 123)),
          ),
        ],
      ),
    );
  }

  Widget buttonSelect(selectFlg) {
    if (selectFlg == true) {
      return GestureDetector(
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Container(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Image(
                    image: AssetImage('lib/assets/icons/selected.png'),
                    fit: BoxFit.fill,
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          print("select row");
        },
      );
    } else {
      return Text("");
    }
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}
