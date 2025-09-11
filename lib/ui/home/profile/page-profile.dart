import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:nmeeting/bloc/checkinBloc.dart';
import 'package:nmeeting/bloc/loginBloc.dart';
import 'package:nmeeting/bloc/profileBloc.dart';
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/ui/home/meeting/page-qr-scan.dart';
import 'package:nmeeting/ui/home/profile/page-profile-webview.dart';
import 'package:nmeeting/ui/login/page-login.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class PageProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile>
    with AutomaticKeepAliveClientMixin<PageProfile> {
  final _bloc = ProfileBloc();
  final _checkinBloc = CheckinBloc();
  final _loginBloc = LoginBloc();

  late IOWebSocketChannel _channelCheckin;
  late IOWebSocketChannel _channelLogin;

  double _sizeBtn = 134;
  double _sizeFont = 17;
  double _sizeFontTitle = 25;

  @override
  void initState() {
    super.initState();
    this._getProfile();

    _openCheckinWebSocketChannel();
    _openLoginWebSocketChannel();
  }

  _openCheckinWebSocketChannel() async {
    _channelCheckin = await _checkinBloc.openCheckinWebSocketChannel();
  }

  _openLoginWebSocketChannel() async {
    _channelLogin = await _bloc.openLoginWebSocketChannel();
    _listenLoginWebSocketChannel();
  }

  _reopenLoginWebSocketChannel() async {
    _channelLogin = await _bloc.openLoginWebSocketChannel();
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

  _getProfile() {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        _bloc.getProfile();
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

    var appVersion = _bloc.getAppVersion();

    super.build(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tài khoản',
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
              Padding(
                padding: EdgeInsets.all(0),
                child: Material(
                    color: Colors.white,
                    elevation: 1,
                    // borderRadius: BorderRadius.circular(5),
                    shadowColor: Color(0x802196F3),
                    child: _userInfo()
                    // child: Padding(
                    //   padding: const EdgeInsets.all(20),
                    //   child: Container(

                    //     child: Row(
                    //   children: <Widget>[
                    //     CircleAvatar(
                    //         radius: 35,
                    //         backgroundImage:
                    //             AssetImage('lib/assets/images/no-avatar.png')),
                    //     SizedBox(
                    //       width: 15,
                    //     ),
                    //     Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: <Widget>[
                    //         SizedBox(
                    //           height: 10,
                    //         ),
                    //         SizedBox(
                    //           width: MediaQuery.of(context).size.width / 2,
                    // child: StreamBuilder<String>(
                    //     stream: _bloc.fullnameStream,
                    //     builder: (context, snapshot) {
                    //       return Text(
                    //           snapshot.hasData ? snapshot.data : '',
                    //           style: TextStyle(
                    //               fontSize: 18,
                    //               fontWeight: FontWeight.bold,
                    //               color: Color.fromARGB(255, 0, 0, 128)),
                    //           overflow: TextOverflow.clip);
                    //     }),
                    //         ),
                    //         SizedBox(
                    //           height: 8,
                    //         ),
                    //         SizedBox(
                    //           width: MediaQuery.of(context).size.width / 2,
                    //           child: StreamBuilder<String>(
                    //               stream: _bloc.usernameStream,
                    //               builder: (context, snapshot) {
                    //                 return Text(
                    //                     snapshot.hasData ? snapshot.data : '',
                    //                     style: TextStyle(
                    //                         fontSize: 18,
                    //                         color: Color.fromARGB(255, 0, 0, 128)),
                    //                     overflow: TextOverflow.clip);
                    //               }),
                    //         ),
                    //       ],
                    //     )
                    //   ],
                    // )

                    // ),
                    // ),
                    ),
              ),
              // logout
              Container(
                padding: EdgeInsets.fromLTRB(0, 1, 0, 10),
                child: Container(
                    child: GestureDetector(
                  onTap: () {
                    _logout();
                  },
                  child: Material(
                    color: Colors.white,
                    elevation: 1,
                    // borderRadius: BorderRadius.circular(5),
                    shadowColor: Color(0x802196F3),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.red),
                          )
                        ],
                      )),
                    ),
                  ),
                )),
              ),

              // rating us, Help, Term of use
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                decoration: new BoxDecoration(color: Colors.white, boxShadow: [
                  new BoxShadow(color: Color(0x802196F3), blurRadius: 1.0)
                ]),
                child: Column(
                  children: <Widget>[
                    // rating us
                    GestureDetector(
                        onTap: () {
                          // // _bloc.ratingApp(context);
                          // AppReview.requestReview.then((onValue) {
                          //   print(onValue);
                          // });
                          showToast('AppReview');
                        },
                        child: Material(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                            child: Container(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                          'lib/assets/icons/ic-star.png'),
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(width: 30),
                                    Text(
                                      'Đánh giá chúng tôi',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color:
                                              Color.fromARGB(255, 52, 52, 52)),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    color: Color.fromARGB(255, 151, 151, 151),
                                    size: 17),
                              ],
                            )),
                          ),
                        )),
                    Container(
                      width: _mediaQuery.size.width,
                      height: 1,
                      margin: EdgeInsets.fromLTRB(70, 0, 0, 0),
                      decoration:
                          new BoxDecoration(color: Colors.white, boxShadow: [
                        new BoxShadow(color: Color(0x802196F3), blurRadius: 1.0)
                      ]),
                    ),

                    // Help
                    GestureDetector(
                        onTap: () {
                          _bloc.getHelpDocument();
                          // Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) =>
                          //               PagePolicy(mode: 'HELP', profileBloc: _bloc)),
                          //     );
                        },
                        child: Material(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                            child: Container(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage(
                                          'lib/assets/icons/ic-help.png'),
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(width: 30),
                                    Text(
                                      'Trợ giúp',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color:
                                              Color.fromARGB(255, 52, 52, 52)),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    color: Color.fromARGB(255, 151, 151, 151),
                                    size: 17),
                              ],
                            )),
                          ),
                        )),
                    Container(
                        width: _mediaQuery.size.width,
                        height: 0.5,
                        margin: EdgeInsets.fromLTRB(70, 0, 0, 0),
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              new BoxShadow(
                                  color: Color(0x802196F3), blurRadius: 1.0)
                            ])),

                    // Terms of use
                    // GestureDetector(
                    //     onTap: () {
                    //       _bloc.getPolicy();
                    //     },
                    //     child: Material(
                    //       color: Colors.white,
                    //       child: Padding(
                    //         padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    //         child: Container(
                    //             child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: <Widget>[
                    //             Row(
                    //               children: <Widget>[
                    //                 Image(
                    //                   image: AssetImage(
                    //                       'lib/assets/icons/ic-term.png'),
                    //                   width: 25,
                    //                   height: 25,
                    //                 ),
                    //                 SizedBox(width: 30),
                    //                 Text(
                    //                   'Điều khoản sử dụng',
                    //                   style: TextStyle(
                    //                       fontSize: 15,
                    //                       fontWeight: FontWeight.normal,
                    //                       color:
                    //                           Color.fromARGB(255, 52, 52, 52)),
                    //                 ),
                    //               ],
                    //             ),
                    //             Icon(Icons.arrow_forward_ios,
                    //                 color: Color.fromARGB(255, 151, 151, 151),
                    //                 size: 17),
                    //           ],
                    //         )),
                    //       ),
                    //     )),

                    Container(
                        width: _mediaQuery.size.width,
                        height: 0.5,
                        margin: EdgeInsets.fromLTRB(70, 0, 0, 0),
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              new BoxShadow(
                                  color: Color(0x802196F3), blurRadius: 1.0)
                            ])),
                    // // QR Code
                    // GestureDetector(
                    //   child: Material(
                    //     color: Colors.white,
                    //     child: Padding(
                    //       padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    //       child: Container(
                    //           child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: <Widget>[
                    //           Row(
                    //             children: <Widget>[
                    //               Stack(
                    //                 alignment: Alignment.center,
                    //                 children: <Widget>[
                    //                   Container(
                    //                     width: 25,
                    //                     height: 25,
                    //                     decoration: BoxDecoration(
                    //                         color: Colors.red,
                    //                         borderRadius: BorderRadius.circular(8)),
                    //                   ),
                    //                   Image(
                    //                     image:
                    //                         AssetImage('lib/assets/icons/scan.png'),
                    //                     fit: BoxFit.fill,
                    //                     width: 12,
                    //                     height: 12,
                    //                   ),
                    //                 ],
                    //               ),
                    //               SizedBox(width: 30),
                    //               Text(
                    //                 'Quét mã QR',
                    //                 style: TextStyle(
                    //                     fontSize: 15,
                    //                     fontWeight: FontWeight.normal,
                    //                     color: Color.fromARGB(255, 52, 52, 52)),
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       )),
                    //     ),
                    //   ),
                    //   onTap: () {
                    //     _checkin();
                    //   },
                    // ),
                  ],
                ),
              ),
              // version
              Container(
                  margin: EdgeInsets.fromLTRB(15, 5, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      StreamBuilder<String>(
                        stream: _bloc.appVersionStream,
                        builder: (context, snapshot) {
                          final version = snapshot.data ?? '';
                          return Text(
                            version.isNotEmpty ? 'Phiên bản $version' : '',
                            style: TextStyle(
                              color: Color.fromARGB(255, 128, 128, 128),
                              fontSize: 13,
                            ),
                          );
                        },
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
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

  Widget _userInfo() {
    final _mediaQuery = MediaQuery.of(context);
    return (Stack(
      children: <Widget>[
        Container(
            width: _mediaQuery.size.width,
            height: _mediaQuery.size.height * 0.3,
            child: Container(
                child: Column(
              children: <Widget>[
                Container(
                  width: _mediaQuery.size.width,
                  height: _mediaQuery.size.height * 0.15,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 30, 217, 239),
                      Color.fromARGB(255, 27, 220, 220),
                      Color.fromARGB(255, 25, 222, 204),
                      Color.fromARGB(255, 22, 224, 186),
                      Color.fromARGB(255, 20, 226, 172),
                      Color.fromARGB(255, 18, 228, 158),
                      Color.fromARGB(255, 16, 230, 144)
                    ],
                  )),
                ),
                Container(
                  width: _mediaQuery.size.width,
                  height: _mediaQuery.size.height * 0.15,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Column(children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                            //           PageProfileDetail(bloc: _bloc)),
                            // );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageProfileWebview()),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              StreamBuilder<String>(
                                stream: _bloc.nameStream,
                                builder: (context, snapshot) {
                                  final name = snapshot.data ?? '';
                                  return Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 10),
                              Image(
                                  image: AssetImage(
                                      'lib/assets/icons/ic-edit.png'),
                                  width: 15,
                                  height: 15)
                            ],
                          )),
                      SizedBox(height: 5),
                      StreamBuilder<String>(
                        stream: _bloc.usernameStream,
                        builder: (context, snapshot) {
                          final username = snapshot.data ?? '';
                          return Text(
                            username,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 175, 175, 175),
                            ),
                          );
                        },
                      )
                    ]),
                  ),
                ),
              ],
            ))),
        Positioned(
            top: _mediaQuery.size.height * 0.15 - 50,
            left: _mediaQuery.size.width * 0.5 - 35,
            child: Container(
              decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    new BoxShadow(color: Colors.grey, blurRadius: 1.0)
                  ]),
              child: StreamBuilder<String>(
                  stream: _bloc.avatarStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data != '') {
                      return ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                              errorWidget: (context, url, error) => Icon(
                                    Icons.error_outline,
                                    size: 35,
                                  ),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              imageUrl: snapshot.data!));
                    }
                    return CircleAvatar(
                        radius: 37,
                        backgroundColor: Colors.white,
                        child: StreamBuilder<String>(
                            stream: _bloc.nameStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data != '') {
                                return CircleAvatar(
                                    radius: 35,
                                    backgroundColor:
                                        Color.fromARGB(255, 28, 126, 191),
                                    child: Text(
                                        (snapshot.data.toString())
                                            .substring(0, 1),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40)));
                              }
                              return CircleAvatar(
                                  radius: 35,
                                  backgroundImage: AssetImage(
                                      'lib/assets/images/no-avatar.png'));
                            }));
                  }),
            )),
      ],
    ));
  }

  _onPressLogout() {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        Future<TResult> _resultFuture = _loginBloc.onLogout();
        _resultFuture.then((res) async {
          var prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', false);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => PageLogin(),
              ),
              (Route<dynamic> route) => false);
        });
      } else {
        showToast(errorMessage.networkError);
        Navigator.of(context).pop();
      }
    });
  }

  _logout() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: VNPTDialogType.question,
            title: 'Đăng xuất',
            styleTitle: TextStyle(
                fontSize: _sizeFontTitle,
                color: Color.fromARGB(255, 0, 0, 128),
                fontWeight: FontWeight.bold),
            description: 'Bạn có muốn đăng xuất?',
            actions: <Widget>[
              SizedBox(
                width: _sizeBtn,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color.fromARGB(255, 0, 0, 128),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Color.fromARGB(255, 0, 0, 128)),
                    ),
                  ),
                  child: Text(
                    'Huỷ',
                    style: TextStyle(
                        fontSize: _sizeFont, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(
                width: _sizeBtn,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 108, 183),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Color.fromARGB(255, 0, 108, 183)),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                        fontSize: _sizeFont, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async => _onPressLogout(),
                ),
              ),
            ],
          );
        });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    if (_channelCheckin != null) {
      _channelCheckin.sink.close();
    }
    if (_channelLogin != null) {
      _channelLogin.sink.close();
    }
  }
}
