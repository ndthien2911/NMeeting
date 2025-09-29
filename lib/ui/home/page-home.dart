import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:nmeeting/bloc/calendarBloc.dart';
import 'package:nmeeting/bloc/checkinBloc.dart';
import 'package:nmeeting/bloc/homeBloc.dart';
import 'package:nmeeting/bloc/in-meeting/in-meetingBloc.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/bloc/notifyBloc.dart';
import 'package:nmeeting/bloc/profileBloc.dart';
import 'package:nmeeting/bloc/progressBloc.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/configs/constants.dart' as constants;
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:nmeeting/models/calendar.dart';
import 'package:nmeeting/models/home.dart';
import 'package:nmeeting/models/in-meeting/in-meeting.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/ui/home/calendar/page-calendar.dart';
import 'package:nmeeting/ui/home/event/page-event-create.dart';
import 'package:nmeeting/ui/home/library/page-library-management-webview.dart';
import 'package:nmeeting/ui/home/library/page-library-process-webview.dart';
import 'package:nmeeting/ui/home/library/page-library.dart';
import 'package:nmeeting/ui/home/meeting/page-qr-scan.dart';
import 'package:nmeeting/ui/home/notifycation/page-notification.dart';
import 'package:nmeeting/ui/home/page-webview-default.dart';
import 'package:nmeeting/ui/home/profile/page-profile.dart';
import 'package:nmeeting/ui/home/progress/page-progress.dart';
import 'package:nmeeting/ui/home/regist-meeting/page-regist-meeting-webview.dart';
import 'package:nmeeting/ui/home/webview/page-news-webview.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

import 'meeting/page-checkin.dart';
import 'meeting/page-meeting-detail.dart';

class PageHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PageHomeState();
  }
}

class _PageHomeState extends State<PageHome> {
  final _profileBloc = ProfileBloc();
  final _inmeetingBloc = InMeetingBloc();
  final _meetingBloc = MeetingBloc();
  final _checkinBloc = CheckinBloc();
  final _progressBloc = ProgressBloc();
  final _notifyBloc = NotifyBloc();
  final _homeBloc = HomeBloc();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  double _sizeBtn = 134;
  double _sizeFont = 17;
  double _sizeFontTitle = 25;

  late IOWebSocketChannel _channelCheckin;
  late IOWebSocketChannel _channelLogin;
  late IOWebSocketChannel _notifyChannel;

  bool onNotificationTrigger = false;

  final List<Color> _busyDayColors = [
    Colors.red,
    Colors.black,
  ];
  final List<Color> _normalDayColors = [
    Color.fromARGB(255, 44, 178, 206),
    //Color.fromARGB(255, 22, 107, 113),
    Colors.black,
  ];
  final List<Color> _freeDayColors = [
    Color.fromARGB(255, 44, 206, 71),
    // Color.fromARGB(255, 37, 176, 69),
    Colors.black,
  ];

  late PageController _pageController;
  int _currentpage = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: _currentpage,
      keepPage: false,
      viewportFraction: 1.0,
    );

    _initData();

    _openCheckinWebSocketChannel();
    _openLoginWebSocketChannel();
    _openNotifyWebSocketChannel();
  }

  openPage(Map<String, dynamic> message) {
    var notificationType = '';
    var title = '';
    var url = '';
    // var notificationID = '';
    // var officeID = '';
    var meetingID = '';
    // var newsID = '';
    if (Platform.isAndroid) {
      notificationType = message['data']['NotificationType'];
      title = message['data']['Title'];
      url = message['data']['Url'];
      // notificationID = message['data']['NotifyID'];
      // officeID = message['data']['OfficeID'];
      meetingID = message['data']['MeetingID'];
      // newsID = message['data']['NewsID'];
    } else if (Platform.isIOS) {
      notificationType = message['NotificationType'];
      title = message['Title'];
      url = message['Url'];
      // notificationID = message['NotifyID'];
      // officeID = message['OfficeID'];
      meetingID = message['MeetingID'];
      // newsID = message['NewsID'];
    }

    if (!StringUtils.isNullOrEmpty(title) && !StringUtils.isNullOrEmpty(url)) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PageWebviewDefault(url: url, title: title)));
    } else {
      if (notificationType ==
          constants.PUSH_NOTIFY_APPROVE_STATUS_MEETING_TYPE.toString()) {
        _openMeetingDetail(meetingID, 0);
      }
    }

    // if (notificationType ==
    //     constants.PUSH_NOTIFY_APPROVE_STATUS_MEETING_TYPE.toString()) {
    //   _openMeetingDetail(meetingID);
    // } else if (notificationType ==
    //     constants.PUSH_NOTIFY_OFFICE_TYPE.toString()) {
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => PageLibraryProcessWebview(
    //               notifyID: notificationID, officeID: officeID)));
    // } else if (notificationType == constants.PUSH_NOTIFY_NEWS_TYPE.toString()) {
    //   // news
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => PageNewsWebview(newsID: newsID)));
    // }
  }

  String convertPayloadToStringObj(payloadData) {
    if (payloadData == null || payloadData['NotificationType'] == null) {
      return '';
    }

    var payloadDataObj = {};
    payloadDataObj['PayloadDataObj'] = payloadData;
    return json.encode(payloadDataObj);
  }

  _checkMemberIsInMeeting(MeetingReadyOutput _meetingReadyCurrent) async {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      Future<TResult> _resFuture =
          _progressBloc.checkIsInMeeting(_meetingReadyCurrent.id);
      _resFuture.then((res) {
        if (res.status == 1) {
          if (res.data == 1 || res.data == 2 || res.data == 3) {
            var data = new MeetingReadyOutput(
                id: _meetingReadyCurrent.id,
                startAt: _meetingReadyCurrent.startAt);
            _openMeetingCurrent(data, res.data == 3 ? true : false);
          }

          if (res.data == 4) {
            var data = new MeetingReadyOutput(
                id: _meetingReadyCurrent.id, name: _meetingReadyCurrent.name);
            _handleGoToPageProgress(data);
          }
        } else {
          showToast("Bạn không còn là thành viên của cuộc họp!");
        }
      });
    });
  }

  _handleGoToPageProgress(MeetingReadyOutput data) {
    _progressBloc.onSetMeetingId(data.id!);
    _progressBloc.onSetMeetingName(data.name!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageProgress(
          progressBloc: _progressBloc,
        ),
      ),
    );
  }

  _initData() {
    _profileBloc.getProfile();
    _inmeetingBloc.getMeetingReady();
    _homeBloc.getMeetingToday();
    _homeBloc.getMenuAppList();
    _getCountNotifyNotSeen();
  }

  _getCountNotifyNotSeen() {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        _notifyBloc.onGetCountNotifyNotSeen();
      }
    });
  }

  _openNotifyWebSocketChannel() async {
    _notifyChannel = await _notifyBloc.openNotifyWebSocketChannel();
    _listenNotifyWebSocketChannel();
  }

  _listenNotifyWebSocketChannel() {
    _notifyChannel.stream.listen((message) async {
      if (StringUtils.isNullOrEmpty(message)) {
        return;
      }
      List<String> _users = json.decode(message).cast<String>();

      final prefs = await SharedPreferences.getInstance();
      if (_users.contains(prefs.getString('username'))) {
        _getCountNotifyNotSeen();
      }
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
            _openNotifyWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  _openCheckinWebSocketChannel() async {
    _channelCheckin = await _checkinBloc.openCheckinWebSocketChannel();
  }

  _openLoginWebSocketChannel() async {
    _channelLogin = await _profileBloc.openLoginWebSocketChannel();
    _listenLoginWebSocketChannel();
  }

  _reopenLoginWebSocketChannel() async {
    _channelLogin = await _profileBloc.openLoginWebSocketChannel();
    _listenLoginWebSocketChannel();
  }

  _listenLoginWebSocketChannel() {
    _channelLogin.stream.listen((message) {}, onDone: () {
      Timer.periodic(Duration(seconds: 3), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        NetworkCheck _networkCheck = NetworkCheck();
        _networkCheck.check().then((isConnected) {
          if (isConnected) {
            timer.cancel();
            _reopenLoginWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  _checkin() async {
    String _qrCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageQRScan()),
    );

    if (StringUtils.isNullOrEmpty(_qrCode)) {
      return;
    }

    // login by QR Code
    if (_qrCode.startsWith('VNPTQR')) {
      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) async {
        if (isConnected) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final _message = {
            'qrCode': _qrCode,
            'username': prefs.getString('username'),
            'password': prefs.getString('password')
          };
          _channelLogin.sink.add(jsonEncode(_message));
        } else {
          showToast(errorMessage.networkError);
        }
      });
      return;
    }

    // scan to start/end meeting
    if (StringUtils.isLength(_qrCode, 36, 36)) {
      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) async {
        if (isConnected) {
          Future<TResult> _resultFuture =
              _checkinBloc.onStartEndMeetingByQRCode(_qrCode);
          _resultFuture.then((res) {
            showToast(res.msg);
            if (res.status == 1) {
              // send notification to socket
              final _message = {
                'meetingID': _qrCode,
                'action': res.data,
                'actionType': 'StartEndMeeting'
              };
              _channelCheckin.sink.add(jsonEncode(_message));
            }
          });
        } else {
          showToast(errorMessage.networkError);
        }
      });

      return;
    }

    // scan to checkin
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) async {
      if (isConnected) {
        Future<TResult> _resultFuture = _checkinBloc.onCheckinByQRCode(_qrCode);
        _resultFuture.then((res) {
          showToast(res.msg);
          if (res.status == 1) {
            // send notification to socket
            final _message = {
              'meetingID': _qrCode.split(';')[1],
              'errorCode': '',
              'personalID': res.data,
              'actionType': 'Checkin'
            };
            _channelCheckin.sink.add(jsonEncode(_message));
          } else {
            final _message = {
              'meetingID': _qrCode.split(';')[1],
              'errorCode': res.data,
              'personalID': '',
              'actionType': 'Checkin'
            };
            _channelCheckin.sink.add(jsonEncode(_message));
          }
        });
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    if (_mediaQuery.size.width <= 320) {
      _sizeBtn = 90;
      _sizeFont = 13;
      _sizeFontTitle = 17;
    } else if (_mediaQuery.size.width <= 400) {
      _sizeBtn = 90;
      _sizeFont = 13;
      _sizeFontTitle = 19;
    } else if (_mediaQuery.size.width <= 420) {
      _sizeBtn = 90;
      _sizeFont = 13;
      _sizeFontTitle = 19;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Column(
                          children: [
                            StreamBuilder<int>(
                                stream: _homeBloc.backgroundColorStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Container(
                                      height: 140,
                                      width: _mediaQuery.size.width,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.zero,
                                            bottomRight:
                                                Radius.elliptical(500, 60),
                                            topLeft: Radius.zero,
                                            bottomLeft:
                                                Radius.elliptical(200, 40)),
                                        gradient: new LinearGradient(
                                          colors: snapshot.data == 0
                                              ? _busyDayColors
                                              : (snapshot.data == 1
                                                  ? _normalDayColors
                                                  : _freeDayColors),
                                          begin:
                                              const FractionalOffset(1, 0.45),
                                          end: const FractionalOffset(1, 2),
                                        ),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                StreamBuilder<String>(
                                                    stream:
                                                        _profileBloc.nameStream,
                                                    builder:
                                                        (context, snapshot) {
                                                      return Container(
                                                        width: _mediaQuery
                                                                .size.width -
                                                            120,
                                                        child: Text(
                                                          snapshot.hasData
                                                              ? 'Chào ' +
                                                                  snapshot.data!
                                                              : '',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    }),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      GestureDetector(
                                                        child: Icon(
                                                          Icons.settings,
                                                          size: 30,
                                                          color: Colors.white,
                                                        ),
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PageProfile()),
                                                          );
                                                        },
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      GestureDetector(
                                                        child: Stack(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .notifications,
                                                              size: 30,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            StreamBuilder<int>(
                                                                stream: _notifyBloc
                                                                    .notifyCntNotSeenStream,
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (snapshot
                                                                          .hasData &&
                                                                      snapshot.data !=
                                                                          null &&
                                                                      snapshot.data! >
                                                                          0) {
                                                                    return AnimatedContainer(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              15,
                                                                          bottom:
                                                                              10),
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              300),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .redAccent,
                                                                      ),
                                                                      width: 18,
                                                                      height:
                                                                          18,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          snapshot.data! > 9
                                                                              ? '9+'
                                                                              : snapshot.data.toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                  return Container();
                                                                }),
                                                          ],
                                                        ),
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PageNotification(
                                                                notifyBloc:
                                                                    _notifyBloc,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    snapshot.data == 0
                                                        ? 'Một ngày thật bận rộn'
                                                        : (snapshot.data == 1
                                                            ? 'Một ngày mới tốt lành'
                                                            : 'Một ngày thật thảnh thơi'),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.white))
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return Container();
                                }),
                            Container(
                              height: 60,
                              width: _mediaQuery.size.width,
                            )
                          ],
                        ),
                        StreamBuilder<List<MenuAppLayout>>(
                            stream: _homeBloc.menuAppLayoutListStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Positioned(
                                  top: 70,
                                  child: Container(
                                    width: _mediaQuery.size.width,
                                    height: 120,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children:
                                            _listMainMenu(snapshot.data!)),
                                  ),
                                );
                              }
                              return Positioned(
                                top: 70,
                                child: Container(),
                              );
                            }),
                      ],
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: _mediaQuery.size.height - 220,
                      ),
                      width: _mediaQuery.size.width,
                      child: Column(
                        children: [
                          StreamBuilder<List<MenuAppLayout>>(
                              stream: _homeBloc.menuAppLayoutListStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Column(
                                    children: [
                                      Container(
                                        width: _mediaQuery.size.width,
                                        height:
                                            snapshot.data!.length > 3 ? 100 : 0,
                                        child: PageView(
                                          children: _createPageViewItems(
                                              snapshot.data!),
                                          controller: _pageController,
                                          onPageChanged: (value) {
                                            setState(() {
                                              _currentpage = value;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children:
                                            _buildPageIndicator(snapshot.data!),
                                      ),
                                    ],
                                  );
                                }
                                return Container();
                              }),
                          StreamBuilder<MeetingReadyOutput>(
                            stream: _inmeetingBloc.meetingReadyStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                var _meetingReadyCurrent = snapshot.data;
                                return Container(
                                  margin: EdgeInsets.fromLTRB(15, 0, 20, 0),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Cuộc họp đang diễn ra',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Image(
                                            image: AssetImage(
                                                'lib/assets/icons/live.png'),
                                            width: 50,
                                            height: 50,
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        child: Container(
                                          padding: EdgeInsets.only(bottom: 8),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          width: _mediaQuery.size.width,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 15, 10, 10),
                                                child: Text(
                                                  _meetingReadyCurrent!.name ??
                                                      '',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, bottom: 6),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  height: 26,
                                                  child: Text(
                                                    getTime(
                                                        _meetingReadyCurrent
                                                            .startAt!,
                                                        _meetingReadyCurrent
                                                            .endAt!),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6),
                                                child: Row(
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          'lib/assets/icons/admin.png'),
                                                      width: 18,
                                                      height: 18,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        _meetingReadyCurrent
                                                                .admin ??
                                                            '',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6),
                                                child: Row(
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          'lib/assets/icons/place.png'),
                                                      width: 18,
                                                      height: 18,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        _meetingReadyCurrent
                                                                .address ??
                                                            '',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          _checkMemberIsInMeeting(
                                              _meetingReadyCurrent);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          StreamBuilder<List<MeetingTodayOutput>>(
                              stream: _homeBloc.meetingTodayListStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var _meetingTodayData = snapshot.data;
                                  return Container(
                                    margin: EdgeInsets.fromLTRB(15, 0, 20, 0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              'Kế hoạch hôm nay',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        if (_meetingTodayData!.length == 0)
                                          _nodata(),
                                        if (_meetingTodayData.length > 0)
                                          for (var item in _meetingTodayData)
                                            GestureDetector(
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(bottom: 8),
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.1),
                                                      spreadRadius: 3,
                                                    ),
                                                  ],
                                                ),
                                                width: _mediaQuery.size.width,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 15, 10, 10),
                                                      child: Text(
                                                        item.name ?? '',
                                                        style: TextStyle(
                                                          color: item.insertFlg !=
                                                                      null &&
                                                                  item.insertFlg ==
                                                                      true
                                                              ? Colors.red
                                                              : Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration: item.cancelApproved !=
                                                                      null &&
                                                                  item.cancelApproved ==
                                                                      true
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : TextDecoration
                                                                  .none,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              bottom: 6),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: item.groupID ==
                                                                  constants
                                                                      .CALENDAR_GROUP_VTTP
                                                              ? constants
                                                                  .MONTH_VTTP_BACKGROUND_COLOR
                                                              : (item.groupID ==
                                                                      constants
                                                                          .CALENDAR_GROUP_UNITS
                                                                  ? constants
                                                                      .MONTH_UNITS_BACKGROUND_COLOR
                                                                  : constants
                                                                      .MONTH_PERSONAL_BACKGROUND_COLOR),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        height: 26,
                                                        child: Text(
                                                          getTime(item.startAt!,
                                                              item.endAt!),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    if (item.type == 0 &&
                                                        !StringUtils
                                                            .isNullOrEmpty(
                                                                item.admin))
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6),
                                                        child: Row(
                                                          children: [
                                                            Image(
                                                              image: AssetImage(
                                                                  'lib/assets/icons/admin.png'),
                                                              width: 18,
                                                              height: 18,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                item.admin ??
                                                                    '',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (item.type == 0 &&
                                                        !StringUtils
                                                            .isNullOrEmpty(
                                                                item.address))
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6),
                                                        child: Row(
                                                          children: [
                                                            Image(
                                                              image: AssetImage(
                                                                  'lib/assets/icons/place.png'),
                                                              width: 18,
                                                              height: 18,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                item.address ??
                                                                    '',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                _openMeetingDetail(
                                                    item.id!, item.type!);
                                              },
                                            ),
                                      ],
                                    ),
                                  );
                                }
                                return Center(
                                    child: CircularProgressIndicator());
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _createPageViewItems(List<MenuAppLayout> data) {
    List<Widget> _list = [];
    if (data.length > 3) {
      var _listMenuForPageView = data.sublist(3, data.length);

      var _pageViewNumber = (_listMenuForPageView.length / 4).ceil();

      for (var i = 0; i < _pageViewNumber; i++) {
        _list.add(Container(
          padding: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _createMenuInPageView(_listMenuForPageView, i),
          ),
        ));
      }
    }

    return _list;
  }

  List<Widget> _createMenuInPageView(
      List<MenuAppLayout> _listMenuForPageView, int _pageViewIndex) {
    List<Widget> _list = [];

    var _startIndex = _pageViewIndex * 4;
    var _endIndex =
        _startIndex + 4 > _listMenuForPageView.length ? null : _startIndex + 4;
    var data = _listMenuForPageView.sublist(_startIndex, _endIndex);
    for (var i = 0; i < data.length; i++) {
      _list.add(
        GestureDetector(
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      width: 70,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      child: Image.network(api.BASE_URL + data[i].imgUrl!),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                    width: 70,
                    child: Text(
                      data[i].name ?? '',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
            onTap: () {
              if (data[i].url!.isNotEmpty) {
                _onOpenWebview(data[i].url!, data[i].name!);
              } else {
                _onChoseMenu(data[i].id!);
              }
            }),
      );
    }
    return _list;
  }

  List<Widget> _buildPageIndicator(List<MenuAppLayout> data) {
    List<Widget> list = [];
    if (data.length > 3) {
      var _listMenuForPageView = data.sublist(3, data.length);
      var _pageViewNumber = (_listMenuForPageView.length / 4).ceil();

      for (int i = 0; i < _pageViewNumber; i++) {
        list.add(i == _currentpage ? _indicator(true) : _indicator(false));
      }
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return Container(
      height: 10,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 4),
        height: isActive ? 6 : 4,
        width: isActive ? 6 : 4,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: Color(0XFF2FB7B2).withOpacity(0.72),
                    blurRadius: 3,
                    spreadRadius: 1,
                    offset: Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: isActive ? Colors.blue : Colors.grey[400],
        ),
      ),
    );
  }

  _listMainMenu(List<MenuAppLayout> data) {
    List<Widget> rows = [];
    for (var i = 0; i < 3; i++) {
      if (data[i] != null) {
        if (i == 0) {
          rows.add(
            GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 75,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              child:
                                  Image.network(api.BASE_URL + data[i].imgUrl!),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              width: 70,
                              child: Text(
                                data[i].name ?? '',
                                style: TextStyle(fontSize: 13),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  if (data[i].url!.isNotEmpty) {
                    _onOpenWebview(data[i].url!, data[i].name!);
                  } else {
                    _onChoseMenu(data[i].id!);
                  }
                }),
          );
        }
        if (i == 1) {
          rows.add(
            GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 120,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              child:
                                  Image.network(api.BASE_URL + data[i].imgUrl!),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              width: 90,
                              child: Text(
                                data[i].name ?? '',
                                style: TextStyle(fontSize: 13),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  if (data[i].url!.isNotEmpty) {
                    _onOpenWebview(data[i].url!, data[i].name!);
                  } else {
                    _onChoseMenu(data[i].id!);
                  }
                }),
          );
        }

        if (i == 2) {
          rows.add(
            GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 90,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              child:
                                  Image.network(api.BASE_URL + data[i].imgUrl!),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              width: 80,
                              child: Text(
                                data[i].name ?? '',
                                style: TextStyle(fontSize: 13),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  if (data[i].url!.isNotEmpty) {
                    _onOpenWebview(data[i].url!, data[i].name!);
                  } else {
                    _onChoseMenu(data[i].id!);
                  }
                }),
          );
        }
      }
    }

    return rows;
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();

    _initData();
    new Timer(new Duration(seconds: 1), () {
      print("timer complete");
      completer.complete();
    });

    return completer.future;
  }

  _onChoseMenu(String id) async {
    switch (id) {
      case 'Calendar':
        // final _menuCalenderList = await _inmeetingBloc.getMenuCalender();
        // List<String> _data = new List<String>.from(_menuCalenderList);
        final _unitBloc = new UnitBloc();
        final _searchList = await _unitBloc.getUnitList();
        final _returnData = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PageCalendar(
                      inmeetingBloc: _inmeetingBloc,
                      unitBloc: _unitBloc,
                    )));
        _initData();
        // showToast('PageCalendar');
        break;
      // case 'Meeting':
      //   final _returnData = await Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => PageRegistMeetingWebview()));
      //   _initData();
      //   break;
      // case 'Office':
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => PageLibraryManagementWebview()));
      //   break;
      case 'Document':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PageLibrary()));
        break;
      case 'QRCode':
        _checkin();
        break;
      default:
        break;
    }
  }

  _onOpenWebview(String url, String name) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PageWebviewDefault(
                  url: url + '?',
                  title: name,
                )));
    // switch (url) {
    //   case 'office/of-office':
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => PageLibraryManagementWebview()));
    //     break;
    //   case 'meeting/meeting':
    //     final _returnData = await Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => PageRegistMeetingWebview()));
    //     _initData();
    //     break;
    //   default:
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => PageWebviewDefault(
    //                   url: url,
    //                   title: name,
    //                 )));
    // }
  }

  _openMeetingCurrent(MeetingReadyOutput data, bool isChecked) {
    _meetingBloc.onSetMeetingId(data.id!);
    _inmeetingBloc.onSetMeetingId(data.id!);
    DateTime tempDate = DateTime.parse(data.startAt!);
    _inmeetingBloc.onSetMeetingTime(tempDate);
    final TargetPlatform platform = Theme.of(context).platform;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageCheckIn(
            inmeetingBloc: _inmeetingBloc,
            meetingBloc: _meetingBloc,
            platform: platform,
            isChecked: isChecked),
      ),
    );
  }

  _openMeetingDetail(String meetingID, int type) async {
    if (type == 0) {
      _meetingBloc.onSetMeetingId(meetingID);
      _inmeetingBloc.onSetMeetingId(meetingID);
      final TargetPlatform platform = Theme.of(context).platform;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PageMeetingDetail(
              inmeetingBloc: _inmeetingBloc,
              meetingBloc: _meetingBloc,
              platform: platform),
        ),
      );
    }

    if (type == 1) {
      String _resultStr = '';
      _resultStr = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PageCreateEvent(
            eventId: meetingID,
            meetingBloc: _meetingBloc,
          ),
        ),
      );

      if (!StringUtils.isNullOrEmpty(_resultStr) &&
          _resultStr == constants.STATUS_SUCCESS) {
        _homeBloc.getMeetingToday();
      }
    }
  }

  String getTime(String start, String end) {
    String startFormated = StringUtils.convertTimeFromString(start, 'hh:mm');
    String endFormated = StringUtils.convertTimeFromString(end, 'hh:mm');

    if (StringUtils.isNullOrEmpty(endFormated)) {
      return startFormated;
    }

    return startFormated + ' - ' + endFormated;
  }

  Widget _nodata() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Image(
            image: AssetImage('lib/assets/images/no-data-home-page.png'),
            height: 200,
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return VNPTDialog(
              type: VNPTDialogType.normal,
              title: 'Thoát',
              styleTitle: TextStyle(
                fontSize: _sizeFontTitle,
                color: const Color.fromARGB(255, 0, 0, 128),
                fontWeight: FontWeight.bold,
              ),
              description: 'Bạn có muốn thoát ứng dụng?',
              actions: <Widget>[
                SizedBox(
                  width: _sizeBtn,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 0, 0, 128),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 0, 0, 128),
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Huỷ',
                      style: TextStyle(
                        fontSize: _sizeFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: _sizeBtn,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 108, 183),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 0, 108, 183),
                        ),
                      ),
                    ),
                    onPressed: () => SystemNavigator.pop(),
                    child: Text(
                      'Thoát',
                      style: TextStyle(
                        fontSize: _sizeFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        )) ??
        false;
  }

  @override
  void dispose() {
    if (_channelCheckin != null) {
      _channelCheckin.sink.close();
    }
    if (_channelLogin != null) {
      _channelLogin.sink.close();
    }
    if (_notifyChannel != null) {
      _notifyChannel.sink.close();
    }
    super.dispose();
  }
}
