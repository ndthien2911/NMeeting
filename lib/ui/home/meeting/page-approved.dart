import 'dart:async';
import 'dart:ui';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nmeeting/bloc/in-meeting/approvedBloc.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/bloc/notifyBloc.dart';
import 'package:nmeeting/models/in-meeting/approved.dart';
import 'package:nmeeting/models/in-meeting/user-meeting.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/ui/home/meeting/page-meeting-create.dart';
import 'package:nmeeting/utilities/common-utils.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:nmeeting/configs/constants.dart' as constants;
import 'package:web_socket_channel/io.dart';

class PageApproved extends StatefulWidget {
  final MeetingBloc meetingBloc;
  final TargetPlatform platform;

  PageApproved({Key key, @required this.meetingBloc, this.platform})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageApprovedState();
  }
}

class _PageApprovedState extends State<PageApproved> {
  final _bloc = ApprovedBloc();
  bool _haveSelectFlg = false;
  double _sizeBtn = 134;
  double _sizeFont = 17;
  double _sizeFontTitle = 25;
  int _sizeDevice = constants.DEVICE_NORMAL;

  final _notifyBloc = NotifyBloc();
  IOWebSocketChannel _notifyChannel;
  int weekSelectedValue = 0;

  @override
  void initState() {
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
      this._publicMeeting();
    }
  }

  _publicMeeting() {
    _showConfirmPublicDialog();
  }

  _showErrorDialog(String str) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: VNPTDialogType.warning,
            title: "Warning",
            description: str,
            actions: <Widget>[
              ButtonTheme(
                minWidth: 134,
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
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
        });
  }

  _showConfirmPublicDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: VNPTDialogType.normal,
            title: 'Duyệt cuộc họp',
            styleTitle: TextStyle(
                fontSize: _sizeFontTitle,
                color: Color.fromARGB(255, 0, 0, 128),
                fontWeight: FontWeight.bold),
            description:
                'Cuộc họp được duyệt sẽ hiển thị trên lịch tuần. Bạn có muốn tiếp tục?',
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
                  child: Text("Đóng",
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
                  child: Text("Xác nhận",
                      style: TextStyle(
                          fontSize: _sizeFont, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // List<String> listIDSelected = _bloc.getListIDSelected();
                    // Future<dynamic> _resultFuture = _bloc.changeMode(
                    //     constants.MODE_PUBLIC, constants.MODE_APPROVED);
                    // _resultFuture.then((res) async {
                    //   if (res.toString() == constants.STATUS_SUCCESS) {
                    //     setState(() {
                    //       _haveSelectFlg = false;
                    //     });

                    //     Future<TResult> _notifyFu = _notifyBloc.getUsersByMeetingIDs(listIDSelected);
                    //     _notifyFu.then((res) {
                    //       if (res.status == 1) {
                    //         _notifyChannel.sink.add(res.data);
                    //       }
                    //     });
                    //   } else {
                    //     showToast(res.toString());
                    //   }
                    // });
                    // Navigator.of(context).pop();
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

      Future<TResult> _notifyFu = _notifyBloc.getUsersByMeetingIDs([id]);
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
                        padding: EdgeInsets.only(bottom: 30),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          child: Material(
                                            color: Color.fromARGB(
                                                255, 251, 251, 251),
                                            //elevation: 2,
                                            //borderRadius:
                                            //    BorderRadius.circular(3),
                                            //shadowColor: Color(0x802196F3),
                                            child: Slidable(
                                              actionPane:
                                                  SlidableDrawerActionPane(),
                                              actionExtentRatio: 0.25,
                                              child: Container(
                                                  //color: Colors.white,
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
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          251,
                                                                          251,
                                                                          251),
                                                                      child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment
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
                                                                            if (snapshot.data[index].hiddenRejectFlg)
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
                                                                            Container(
                                                                                padding: EdgeInsets.fromLTRB(7, 3, 7, 3),
                                                                                //color: Color.fromARGB(255, 66, 133, 244),
                                                                                child: Text(
                                                                                  StringUtils.getWeekday(snapshot.data[index].meetingDate) + ', ' + StringUtils.convertTimeFromString(snapshot.data[index].meetingDate, 'dd/MM') + (snapshot.data[index].meetingEndDate == snapshot.data[index].meetingDate ? '' : '-' + StringUtils.convertTimeFromString(snapshot.data[index].meetingEndDate, 'dd/MM')),
                                                                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),
                                                                                )),
                                                                          ])),

                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Flexible(
                                                                          child:
                                                                              Container(
                                                                        margin: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        padding:
                                                                            EdgeInsets.all(0),
                                                                        alignment:
                                                                            Alignment.topLeft,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                            border: Border.all(color: Colors.black45)),
                                                                        child: Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              Container(
                                                                                margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
                                                                                padding: EdgeInsets.all(0),
                                                                                alignment: Alignment.topLeft,
                                                                                child: Text(snapshot.data[index].name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 66, 133, 244))),
                                                                              ),
                                                                              Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                                  padding: EdgeInsets.all(0),
                                                                                  alignment: Alignment.topLeft,
                                                                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                    Text("Chủ trì: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                                    Flexible(
                                                                                      child: Container(
                                                                                        child: Text(snapshot.data[index].adminNmList, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0))),
                                                                                      ),
                                                                                    )
                                                                                  ])),
                                                                              if (!StringUtils.isNullOrEmpty(snapshot.data[index].note))
                                                                                Container(
                                                                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                                    padding: EdgeInsets.all(0),
                                                                                    alignment: Alignment.topLeft,
                                                                                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                      Text("Chuẩn bị: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                                      Flexible(
                                                                                        child: Container(
                                                                                          child: Text(snapshot.data[index].note, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0))),
                                                                                        ),
                                                                                      )
                                                                                    ])),
                                                                              Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                                  padding: EdgeInsets.all(0),
                                                                                  alignment: Alignment.topLeft,
                                                                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                    Text("T.Phần: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                                    Flexible(
                                                                                      child: Container(
                                                                                        child: Text(snapshot.data[index].memberNmList, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0))),
                                                                                      ),
                                                                                    )
                                                                                  ])),
                                                                              if (!StringUtils.isNullOrEmpty(snapshot.data[index].guest))
                                                                                Container(
                                                                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                                    padding: EdgeInsets.all(0),
                                                                                    alignment: Alignment.topLeft,
                                                                                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                      Text("Mời: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                                      Flexible(
                                                                                        child: Container(
                                                                                          child: Text(snapshot.data[index].guest, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0))),
                                                                                        ),
                                                                                      )
                                                                                    ])),
                                                                              Container(
                                                                                margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                                                                padding: EdgeInsets.all(0),
                                                                                alignment: Alignment.topLeft,
                                                                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                                                                  Text("Địa chỉ: ", overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                                  Flexible(
                                                                                    child: Container(
                                                                                      child: Text(snapshot.data[index].address, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: snapshot.data[index].insertFlg ? Colors.red : Color.fromARGB(255, 0, 0, 0))),
                                                                                    ),
                                                                                  )
                                                                                ]),
                                                                              ),
                                                                              // if (snapshot.data[index].hiddenRejectFlg)
                                                                              //   Container(margin: EdgeInsets.fromLTRB(10, 0, 0, 0), padding: EdgeInsets.all(0), alignment: Alignment.topRight, child: Text("Lịch đăng ký VTTP", overflow: TextOverflow.visible, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color.fromARGB(255, 0, 0, 128)))),
                                                                            ]),
                                                                      )),
                                                                    ],
                                                                  )
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
                                                if (snapshot.data[index]
                                                            .hiddenRejectFlg !=
                                                        true &&
                                                    CommonUtils.checkRole(
                                                            constants
                                                                .BTN_NAME_REVERT_APPROVE,
                                                            widget.meetingBloc
                                                                .onGetRoleAppStr()) ==
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
                                                        // setState(() {
                                                        //   _haveSelectFlg =
                                                        //       false;
                                                        // });
                                                        Future<String>
                                                            _statusFu =
                                                            _bloc.revertStatus(
                                                                constants
                                                                    .MODE_WAITING,
                                                                constants
                                                                    .MODE_APPROVED,
                                                                snapshot
                                                                    .data[index]
                                                                    .id,
                                                                snapshot
                                                                    .data[index]
                                                                    .hiddenRejectFlg);
                                                        _statusFu.then((str) {
                                                          _getAll();
                                                          if (str ==
                                                              constants
                                                                  .STATUS_SUCCESS) {
                                                            Future<TResult>
                                                                _notifyFu =
                                                                _notifyBloc
                                                                    .getUsersByMeetingIDs([
                                                              snapshot
                                                                  .data[index]
                                                                  .id
                                                            ]);
                                                            _notifyFu
                                                                .then((res) {
                                                              if (res.status ==
                                                                  1) {
                                                                _notifyChannel
                                                                    .sink
                                                                    .add(res
                                                                        .data);
                                                              }
                                                            });
                                                          } else {
                                                            _showErrorDialog(
                                                                str);
                                                          }
                                                        });
                                                      }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ])),
                              // onTap: () async {
                              //   if (CommonUtils.checkRole(
                              //       constants.BTN_NAME_PUBLIC,
                              //       widget.meetingBloc.onGetRoleAppStr())) {
                              //     //_clickItem(snapshot.data[index].id, !snapshot.data[index].selectFlg);
                              //   }
                              // },
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
        floatingActionButton: new Visibility(
          visible: (CommonUtils.checkRole(constants.BTN_NAME_PUBLIC,
                      widget.meetingBloc.onGetRoleAppStr()) ==
                  true &&
              _haveSelectFlg == true),
          child: new FloatingActionButton(
              child: Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: Container(
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.centerRight,
                        child: Image(
                          image: AssetImage('lib/assets/icons/confirm.png'),
                          width: 60,
                          height: 63,
                        )),
                  ),
                ],
              ),
              onPressed: () => this._clickBtnBottom(_haveSelectFlg)),
        ));
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
        onTap: () {},
      );
    } else {
      return Text("");
    }
  }
}
