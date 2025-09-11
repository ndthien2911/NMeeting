import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:nmeeting/bloc/documentBloc.dart';
import 'package:nmeeting/bloc/in-meeting/in-meetingBloc.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/models/in-meeting/in-meeting.dart';
import 'package:nmeeting/models/in-meeting/join-meeting.dart';
import 'package:nmeeting/ui/home/document-viewer/page-document-viewer.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:flutter/material.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/ui/home/meeting/page-meeting-detail-assign-user.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/io.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:nmeeting/configs/constants.dart' as constants;

class PageMeetingDetail extends StatefulWidget {
  final InMeetingBloc inmeetingBloc;
  final MeetingBloc meetingBloc;
  final TargetPlatform platform;
  PageMeetingDetail(
      {Key? key,
      required this.inmeetingBloc,
      required this.meetingBloc,
      required this.platform})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageMeetingDetailState();
}

class _PageMeetingDetailState extends State<PageMeetingDetail> {
  final _documentBloc = DocumentBloc();
  String eventTitle = '';
  String eventDes = '';
  bool isDublicate = false;
  String? userId;
  String? qrCode;
  String _meetingNm = '';

  IOWebSocketChannel? _channelCheckin;
  IOWebSocketChannel? _channelJoinAbsent;

  @override
  void initState() {
    super.initState();
    initValue();

    widget.inmeetingBloc.onSetIsLoading(false);
    widget.inmeetingBloc.onSetIsPermissionReady(false);

    // widget.meetingBloc.onNetworkChanged(true);
    widget.inmeetingBloc.onGetMeetingDetailById();

    widget.inmeetingBloc.isMeetingEnd();

    _openCheckinWebSocketChannel();
    _openJoinAbsentWebSocketChannel();

    // check member has checkin, if not call timer in bellow
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        widget.inmeetingBloc.onSetIsLoading(true);
        Future<bool> _resultFuture = widget.meetingBloc.checkUserHasCheckIn();
        _resultFuture.then((res) {
          if (!res) {
            _listenCheckinWebSocketChannel();
          }
        });
      } else {
        widget.meetingBloc.onNetworkChanged(false);
      }
    });
  }

  _openCheckinWebSocketChannel() async {
    _channelCheckin = await widget.meetingBloc.openCheckinWebSocketChannel();
  }

  _listenCheckinWebSocketChannel() {
    _channelCheckin?.stream.listen((message) {
      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) {
        if (isConnected) {
          widget.meetingBloc.onNetworkChanged(true);
          if (qrCode != null) {
            Future<bool> _resultFuture =
                widget.meetingBloc.qrCheckedFlg(qrCode ?? '');
            _resultFuture.then((res) {
              // if checkedFlg = true
              if (res == true) {
                // check is in meeting
                Future<TResult> _resFuture =
                    widget.inmeetingBloc.checkIsInMeeting();
                _resFuture.then((res) {
                  if (res.status == 1) {
                    // set meeting name
                    widget.inmeetingBloc.onSetMeetingName(_meetingNm);
                    Navigator.pop(context, true);
                  } else {
                    // showToast('Điểm danh thành công, ${res.msg}');
                    Navigator.pop(context, false);
                  }
                });
              }
            });
          }
        } else {
          widget.meetingBloc.onNetworkChanged(false);
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
            _openCheckinWebSocketChannel();
            //_listenCheckinWebSocketChannel();
            // _channel.sink.add('data');
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  _openJoinAbsentWebSocketChannel() async {
    _channelJoinAbsent =
        await widget.meetingBloc.openJoinAbsentWebSocketChannel();
    _listenJoinAbsentWebSocketChannel();
  }

  _listenJoinAbsentWebSocketChannel() {
    _channelJoinAbsent?.stream.listen((message) {}, onDone: () {
      Timer.periodic(Duration(seconds: 3), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        NetworkCheck _networkCheck = NetworkCheck();
        _networkCheck.check().then((isConnected) {
          if (isConnected) {
            timer.cancel();
            _openJoinAbsentWebSocketChannel();
            _listenJoinAbsentWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_channelCheckin != null) {
      _channelCheckin?.sink.close();
    }
    _channelJoinAbsent?.sink.close();
  }

  initValue() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
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
          'Thông tin cuộc họp',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const Divider(
                      color: Color.fromARGB(255, 227, 227, 227),
                      height: 1,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                    _meetingInfo()
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder<bool>(
              stream: widget.inmeetingBloc.actionGetApprovedFlgStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == true)
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Container(
                        //   child: Column(
                        //     children: [
                        //       SizedBox(
                        //         height: 60,
                        //         width: 60,
                        //         child: FlatButton(
                        //           child: Image(
                        //             image: AssetImage(
                        //                 'lib/assets/icons/absent.png'),
                        //             width: 30,
                        //             height: 30,
                        //           ),
                        //           color: Colors.grey[100],
                        //           shape: RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.all(
                        //                   Radius.circular(50))),
                        //           onPressed: () {
                        //             if (!widget.inmeetingBloc
                        //                 .onGetIsMeetingEnded()) {
                        //               _showTimerPopup();
                        //             }
                        //           },
                        //         ),
                        //       ),
                        //       SizedBox(height: 7),
                        //       Text(
                        //         "Nhắc lịch",
                        //         style: TextStyle(
                        //             color: Colors.black54, fontSize: 14),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Container(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    backgroundColor: Colors.grey[100],
                                    padding: EdgeInsets.all(10),
                                  ),
                                  onPressed: () {
                                    if (!widget.inmeetingBloc
                                        .onGetIsMeetingEnded()) {
                                      _onPressAssign();
                                    }
                                  },
                                  child: Image.asset(
                                    'lib/assets/icons/invite.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              const Text(
                                "Mời",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder<bool>(
                          stream:
                              widget.inmeetingBloc.actionGetPersionalFlgStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Container(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 60,
                                      width: 60,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          backgroundColor: Colors.grey[100],
                                          padding: EdgeInsets.all(10),
                                          elevation:
                                              0, // giống FlatButton (phẳng, không bóng)
                                        ),
                                        onPressed: () {
                                          _onAddOrRemovePersonal();
                                        },
                                        child: Image.asset(
                                          snapshot.data == true
                                              ? 'lib/assets/icons/remind-me-remove.png'
                                              : 'lib/assets/icons/remind-me.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      snapshot.data == true
                                          ? "Báo vắng"
                                          : "Nhắc tôi",
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    );
                }
                return Container();
              },
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  _onJoinMeeting() {
    Future<TResult> _resultFuture = widget.inmeetingBloc.onJoinMeeting();
    _resultFuture.then((res) async {
      if (res.status == 1) {
        // send notification to socket

        final _message = {
          'meetingID': widget.meetingBloc.onGetMeetingId(),
          'actionType': 'Join'
        };
        _channelJoinAbsent?.sink.add(jsonEncode(_message));
      }
    });
  }

  _submitAbsent() {
    Future<TResult> _resultFuture = widget.inmeetingBloc.onSubmitAbsent();
    _resultFuture.then((res) async {
      if (res.status == 1) {
        final _joinMeetingOutput = JoinMeetingOutput(code: 0);
        widget.inmeetingBloc.onSetjoinMeeting(_joinMeetingOutput);
        widget.inmeetingBloc.onSetIsJoinedMeeting(false);

        // send notification to socket

        final _message = {
          'meetingID': widget.meetingBloc.onGetMeetingId(),
          'actionType': 'Absent'
        };
        _channelJoinAbsent?.sink.add(jsonEncode(_message));
      }
      showToast(res.msg);
    });
  }

  _onPressAssign() {
    Future<dynamic> _resultFuture = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PageMeetingDetailAssignUser(inMeetingBloc: widget.inmeetingBloc),
      ),
    );
    _resultFuture.then((res) async {
      widget.inmeetingBloc.onGetMeetingDetailById();
    });
  }

  Color getColor(int groupID) {
    if (groupID == constants.CALENDAR_GROUP_VTTP) {
      return constants.MONTH_VTTP_BACKGROUND_COLOR;
    }
    if (groupID == constants.CALENDAR_GROUP_UNITS) {
      return constants.MONTH_UNITS_BACKGROUND_COLOR;
    }

    if (groupID == constants.CALENDAR_GROUP_PERSONAL) {
      return constants.MONTH_PERSONAL_BACKGROUND_COLOR;
    }
    return Colors.white;
  }

  Widget _meetingInfo() {
    final _mediaQuery = MediaQuery.of(context);
    return StreamBuilder<InMeetingOutput?>(
        stream: widget.inmeetingBloc.meetingStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              _meetingNm = snapshot.data!.name!;
              eventTitle = snapshot.data!.name!;
              eventDes = StringUtils.convertTimeFromString(
                      snapshot.data!.startAt, 'dd/MM/YYYY hh:mm') +
                  ((!StringUtils.isNullOrEmpty(snapshot.data!.endAt!))
                      ? ' - ' +
                          StringUtils.convertTimeFromString(
                              snapshot.data!.endAt, 'dd/MM/YYYY hh:mm')
                      : "");
              return Center(
                child: Container(
                  width: _mediaQuery.size.width,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: _mediaQuery.size.width,
                      child: Column(children: <Widget>[
                        SizedBox(height: 7),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Column(children: <Widget>[
                            Text(snapshot.data!.name!,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold))
                          ]),
                        ),
                        SizedBox(height: 10),
                        if (snapshot.data!.approveFlg == true &&
                            snapshot.data!.personalFlg == true)
                          _qrView(snapshot.data),

                        if (snapshot.data!.cancelApproved == true)
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Column(children: <Widget>[
                              Text("Cuộc họp này đã bị hủy",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold))
                            ]),
                          ),

                        SizedBox(height: 10),
                        // Box
                        Container(
                          child: Container(
                            //color: Colors.grey[100],
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            width: _mediaQuery.size.width * 0.9,
                            child: Column(
                              children: <Widget>[
                                // Thời gian
                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.startAt!))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Color.fromARGB(
                                                255, 241, 243, 244)),
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(children: <Widget>[
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          'Thời gian: ',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color:
                                              getColor(snapshot.data!.groupID!),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        height: 30,
                                        child: Text(
                                          StringUtils.convertTimeFromString(
                                                  snapshot.data!.startAt,
                                                  'hh:mm') +
                                              ((!StringUtils.isNullOrEmpty(
                                                      snapshot.data!.endAt!))
                                                  ? ' - ' +
                                                      StringUtils
                                                          .convertTimeFromString(
                                                              snapshot
                                                                  .data!.endAt!,
                                                              'hh:mm')
                                                  : ""),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ]),
                                  ),

                                //Ngày
                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.meetingDate!))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Ngày: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              StringUtils.convertTimeFromString(
                                                      snapshot
                                                          .data!.meetingDate,
                                                      'dd/MM/YYYY') +
                                                  (snapshot.data!.meetingDate !=
                                                          snapshot.data!
                                                              .meetingEndDate
                                                      ? ' - ' +
                                                          StringUtils
                                                              .convertTimeFromString(
                                                                  snapshot.data!
                                                                      .meetingEndDate,
                                                                  'dd/MM/YYYY')
                                                      : ''),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0)),
                                            ),
                                          ),
                                        ]),
                                  ),

                                // Chủ trì
                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.adminNm))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Chủ trì: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              snapshot.data!.adminNm!,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0)),
                                            ),
                                          ),
                                        ]),
                                  ),

                                // Chuẩn bị
                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.equipment))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Chuẩn bị: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              snapshot.data!.equipment != null
                                                  ? snapshot.data!.equipment!
                                                  : "",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0)),
                                            ),
                                          ),
                                        ]),
                                  ),

                                // Thành phần
                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.element))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Thành phần: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Text(
                                                snapshot.data!.element ?? '',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0)),
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ),

                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.guest))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Khách mời: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              snapshot.data!.guest ?? '',
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0)),
                                            ),
                                          ),
                                        ]),
                                  ),

                                // Địa điểm
                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.address))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Địa điểm: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              snapshot.data!.address ?? '',
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0)),
                                            ),
                                          ),
                                        ]),
                                  ),

                                // Vị trí ngồi
                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.seatPosition))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Vị trí ngồi: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              snapshot.data!.seatPosition ?? '',
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0)),
                                            ),
                                          ),
                                        ]),
                                  ),

                                // Tham dự
                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.memberJoin))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Tham dự: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                              child: Text(
                                            snapshot.data!.memberJoin != null
                                                ? "\t${snapshot.data!.memberJoin}"
                                                : "",
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0)),
                                          )),
                                        ]),
                                  ),

                                // Ghi chú
                                if (!StringUtils.isNullOrEmpty(
                                    snapshot.data!.note))
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Ghi chú: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                            child: Text(
                                              snapshot.data!.note ?? '',
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0)),
                                            ),
                                          ),
                                        ]),
                                  ),

                                // Tài liệu
                                if (snapshot.data!.files != null &&
                                    snapshot.data!.files!.length > 0)
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 241, 243, 244),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                            child: Text('Tài liệu: ',
                                                style: TextStyle(fontSize: 17)),
                                          ),
                                          Expanded(
                                              child: Column(
                                            children: _renderDocument(
                                                snapshot.data!.files),
                                          )),
                                        ]),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ),
              );
            } else {
              return Text('Kiểm tra đường truyền internet của bạn');
            }
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  _renderDocument(files) {
    List<Widget> _list = [];
    for (var item in files) {
      _list.add(
        Container(
          padding: EdgeInsets.only(top: 5),
          child: Row(children: <Widget>[
            Expanded(
              child: GestureDetector(
                  child: Text(item.name,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      )),
                  onTap: () {
                    _viewDocument(item.id, item.downloadFlg);
                  }),
            )
          ]),
        ),
      );
    }
    return _list;
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

  Widget _qrView(meetingData) {
    final _mediaQuery = MediaQuery.of(context);

    if (meetingData.qrCode != null && meetingData.joinedFlg == true) {
      qrCode = meetingData.qrCode;
      final _inMeetingOutput = InMeetingOutput(qrCode: qrCode);
      final _joinMeetingOutput =
          JoinMeetingOutput(code: 1, data: _inMeetingOutput);

      widget.inmeetingBloc.onSetjoinMeeting(_joinMeetingOutput);
    }

    return StreamBuilder<JoinMeetingOutput?>(
        stream: widget.inmeetingBloc.joinMeetingStream,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.code == 1 &&
              snapshot.data!.data != null &&
              snapshot.data!.data!.qrCode != null) {
            qrCode = snapshot.data!.data!.qrCode;
            return QrImageView(
              data: snapshot.data!.data!.qrCode!,
              version: QrVersions.auto,
              size: _mediaQuery.size.width * 0.45,
            );
          } else {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _handleDataJoin(snapshot.data));
            return GestureDetector(
              child: new Container(
                  width: 130, //_mediaQuery.size.width * 0.7,
                  height: 130,
                  child: DottedBorder(
                    dashPattern: [3, 3, 3, 3],
                    radius: Radius.circular(10),
                    strokeWidth: 1,
                    strokeCap: StrokeCap.square,
                    borderType: BorderType.RRect,
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        width: 130, //_mediaQuery.size.width * 0.7,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 248, 248, 248),
                        ),
                        child: Center(
                          child: Text(
                            'Click vào đây để nhận mã QR và xác nhận tham gia cuộc họp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color.fromARGB(255, 88, 88, 88),
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                  )),
              onTap: () {
                _showConfirmJoinDialog();
              },
            );
          }
        });
  }

  _showTimerPopup() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          String dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
          String timeStr = DateFormat('HH:mm').format(DateTime.now());
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: StatefulBuilder(
              // You need this, notice the parameters below:
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                    color: Colors.transparent,
                    width: 300,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Stack(children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Container(
                                child: Material(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    child: Column(children: <Widget>[
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          child: Text('Nhắc hẹn',
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          child: SizedBox(
                                            width: 500,
                                            height: 0.2,
                                            child: const DecoratedBox(
                                              decoration: const BoxDecoration(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )),
                                      Row(
                                        children: <Widget>[
                                          Text('Ngày'),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              picker.DatePicker.showDatePicker(
                                                context,
                                                showTitleActions: true,
                                                minTime: DateTime.now(),
                                                theme: picker.DatePickerTheme(
                                                  headerColor: Colors.grey,
                                                  backgroundColor: Colors.white,
                                                  itemStyle: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                  doneStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                onChanged: (date) {
                                                  print(
                                                    'change $date in time zone ${date.timeZoneOffset.inHours}',
                                                  );
                                                },
                                                onConfirm: (date) {
                                                  setState(() {
                                                    dateStr =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(date);
                                                  });
                                                  print('confirm $date');
                                                },
                                                currentTime: DateTime.now(),
                                                locale: picker.LocaleType.vi,
                                              );
                                            },
                                            child: Text(dateStr),
                                          )
                                        ],
                                      ),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 13, 0, 13),
                                          child: SizedBox(
                                            width: 500,
                                            height: 0.2,
                                            child: const DecoratedBox(
                                              decoration: const BoxDecoration(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )),
                                      Row(
                                        children: <Widget>[
                                          Text('Giờ'),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              picker.DatePicker.showTimePicker(
                                                  context,
                                                  showTitleActions: true,
                                                  onChanged: (date) {
                                                print(
                                                    'change $date in time zone ' +
                                                        date.timeZoneOffset
                                                            .inHours
                                                            .toString());
                                              }, onConfirm: (date) {
                                                setState(() {
                                                  timeStr = DateFormat('HH:mm')
                                                      .format(date);
                                                });
                                              },
                                                  currentTime: DateTime.now(),
                                                  locale: picker.LocaleType.vi);
                                            },
                                            child: Text(timeStr),
                                          )
                                        ],
                                      ),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 13, 0, 13),
                                          child: SizedBox(
                                            width: 500,
                                            height: 0.2,
                                            child: const DecoratedBox(
                                              decoration: const BoxDecoration(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(155, 143,
                                                      143, 143), // màu nền
                                              foregroundColor:
                                                  Colors.white, // màu chữ/icon
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                // side: const BorderSide(color: Colors.red), // nếu cần viền
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Huỷ',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            // width: 100,
                                            // height: 30,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      15) //                 <--- border radius here
                                                  ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color.fromARGB(
                                                      255, 30, 37, 239),
                                                  Color.fromARGB(
                                                      255, 16, 116, 230)
                                                ],
                                              ),
                                            ),
                                            child: MaterialButton(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              disabledElevation: 1,
                                              disabledColor: Colors.black45,
                                              shape: const StadiumBorder(),
                                              child: Text(
                                                'Xác nhận',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              onPressed: () {
                                                Future<bool> _isAddedFu =
                                                    _addEventToCalendar(
                                                        dateStr, timeStr);
                                                _isAddedFu.then((value) {
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                            ),
                                          )
                                        ],
                                      )
                                    ]),
                                  ),
                                ),
                              ),
                            ),
                          ])
                        ]));
              },
            ),
          );
        });
  }

  Future<bool> _addEventToCalendar(date, time) {
    int day = int.parse(date.substring(0, 2));
    int month = int.parse(date.substring(3, 5));
    int year = int.parse(date.substring(6, 10));
    int hour = int.parse(time.substring(0, 2));
    int minute = int.parse(time.substring(3, 5));
    DateTime startDate = new DateTime(year, month, day, hour, minute);
    log(startDate.toString());
    Event event = Event(
      title: eventTitle,
      description: eventDes,
      location: 'Meeting Schedule',
      startDate: startDate,
      endDate: startDate.add(Duration(hours: 1)),
      // allDay: true,
    );
    return Add2Calendar.addEvent2Cal(event);
  }

  _showConfirmJoinDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return VNPTDialog(
          type: VNPTDialogType.normal,
          title: 'Xác nhận',
          description: 'Bạn sẽ nhận được mã QR dùng để tham gia cuộc họp này',
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(155, 143, 143, 143),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Huỷ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 30, 37, 239),
                    Color.fromARGB(255, 16, 116, 230),
                  ],
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  _onJoinMeeting();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Xác nhận',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _showAbsentMeetingDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: VNPTDialogType.normal,
            title: 'Xác nhận vắng',
            description: 'Bạn xác nhận không tham gia cuộc họp này',
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(155, 143, 143, 143),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Huỷ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                // width: 100,
                // height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(
                          15) //                 <--- border radius here
                      ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 30, 37, 239),
                      Color.fromARGB(255, 16, 116, 230)
                    ],
                  ),
                ),
                child: MaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  disabledElevation: 1,
                  disabledColor: Colors.black45,
                  shape: const StadiumBorder(),
                  child: Text(
                    'Xác nhận',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _submitAbsent();
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
        });
  }

  _onAddOrRemovePersonal() {
    Future<TResult> _resultFuture =
        widget.inmeetingBloc.onAddOrRemovePersonal();
    _resultFuture.then((res) async {
      if (res.status == 1) {
        Navigator.of(context).pop();
      } else
        showToast(res.msg);
    });
  }

  _handleDataJoin(data) {
    if (data == null) {
      return;
    }
    if (data.status == 0) {
      _showWarnMeetingDialog(
          VNPTDialogType.warning, data, 'Xảy ra lỗi', '${data.msg}');
    } else if (data.code == 3) {
      // duplicate meeting
      _showWarnMeetingDialog(
          VNPTDialogType.warning, data, 'Trùng lịch họp', '${data.msg}');
    } else if (data.code == 2) {
      //
      _showWarnMeetingDialog(
          VNPTDialogType.error, data, 'Từ chối tham dự', '${data.msg}');
    }
  }

  _showWarnMeetingDialog(type, data, title, description) {
    if (data == null) {
      return;
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: type,
            title: title,
            // description: 'Bạn bị trùng với lịch họp lúc 13:30, vui lòng xem lại',
            description: description,
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // màu nền
                  foregroundColor: Colors.white, // màu chữ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                onPressed: () {
                  // request confirm join meeting
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 14),
                ),
              )
            ],
          );
        });
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double height;

  const CustomAppBar(
      {Key? key, required this.child, this.height = kToolbarHeight})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: Colors.white,
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(10, 24, 10, 0),
      child: child,
    );
  }
}
