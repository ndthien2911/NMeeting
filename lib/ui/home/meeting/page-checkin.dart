import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:nmeeting/bloc/in-meeting/in-meetingBloc.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/bloc/progressBloc.dart';
import 'package:nmeeting/models/in-meeting/in-meeting.dart';
import 'package:nmeeting/models/in-meeting/join-meeting.dart';
import 'package:nmeeting/ui/home/control-meeting/page-control-meeting-webview.dart';
import 'package:nmeeting/ui/home/progress/page-progress.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:flutter/material.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:dotted_border/dotted_border.dart';

class PageCheckIn extends StatefulWidget {
  final InMeetingBloc inmeetingBloc;
  final MeetingBloc meetingBloc;
  final TargetPlatform platform;
  bool isChecked;

  PageCheckIn({
    Key? key,
    required this.inmeetingBloc,
    required this.meetingBloc,
    required this.platform,
    required this.isChecked,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageCheckInState();
}

class _PageCheckInState extends State<PageCheckIn> {
  String eventTitle = '';
  String eventDes = '';
  bool isDublicate = false;
  String? userId;
  String? qrCode;
  String _meetingNm = '';

  final _progressBloc = ProgressBloc();

  IOWebSocketChannel? _channelCheckin;
  IOWebSocketChannel? _channelJoinAbsent;

  @override
  void initState() {
    super.initState();
    initValue();

    widget.inmeetingBloc.onSetIsLoading(false);
    widget.inmeetingBloc.onSetIsPermissionReady(false);

    widget.inmeetingBloc.onGetMeetingDetailById();
    widget.inmeetingBloc.isMeetingEnd();

    _openCheckinWebSocketChannel();
    _openJoinAbsentWebSocketChannel();
  }

  _openCheckinWebSocketChannel() async {
    _channelCheckin = await widget.meetingBloc.openCheckinWebSocketChannel();
    _listenCheckinWebSocketChannel();
  }

  _listenCheckinWebSocketChannel() {
    _channelCheckin?.stream.listen((message) {
      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) {
        if (isConnected) {
          widget.meetingBloc.onNetworkChanged(true);
          Future<TResult> _resFuture = _progressBloc
              .checkIsInMeeting(widget.meetingBloc.onGetMeetingId());
          _resFuture.then((res) {
            if (res.status == 1) {
              if (res.data == 2) {
                setState(() {
                  widget.isChecked = false;
                });
              }
              if (res.data == 3) {
                setState(() {
                  widget.isChecked = true;
                });
              }
              if (res.data == 4) {
                widget.inmeetingBloc.onSetMeetingName(_meetingNm);
                _progressBloc
                    .onSetMeetingId(widget.meetingBloc.onGetMeetingId());
                _progressBloc.onSetMeetingName(_meetingNm);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageProgress(
                      progressBloc: _progressBloc,
                    ),
                  ),
                );
              }
            } else {
              showToast("Bạn không còn là thành viên của cuộc họp!");
            }
          });
        } else {
          widget.meetingBloc.onNetworkChanged(false);
        }
      });
    }, onDone: () {
      Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        NetworkCheck _networkCheck = NetworkCheck();
        _networkCheck.check().then((isConnected) {
          if (isConnected) {
            timer.cancel();
            _openCheckinWebSocketChannel();
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
      Timer.periodic(const Duration(seconds: 3), (timer) {
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
    _channelCheckin?.sink.close();
    _channelJoinAbsent?.sink.close();
    super.dispose();
  }

  initValue() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          "Chuẩn bị",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[_meetingInfo()],
        ),
      ),
    );
  }

  _onJoinMeeting() {
    Future<TResult> _resultFuture = widget.inmeetingBloc.onJoinMeeting();
    _resultFuture.then((res) async {
      if (res.status == 1) {
        final _message = {
          'meetingID': widget.meetingBloc.onGetMeetingId(),
          'actionType': 'Join'
        };
        _channelJoinAbsent?.sink.add(jsonEncode(_message));
      }
    });
  }

  Widget _meetingInfo() {
    final _mediaQuery = MediaQuery.of(context);
    return StreamBuilder<InMeetingOutput?>(
        stream: widget.inmeetingBloc.meetingStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _meetingNm = snapshot.data!.name ?? '';
            eventTitle = snapshot.data!.name ?? '';
            eventDes = StringUtils.convertTimeFromString(
                    snapshot.data!.startAt, 'dd/MM/yyyy hh:mm') +
                ((!StringUtils.isNullOrEmpty(snapshot.data!.endAt!))
                    ? ' - ' +
                        StringUtils.convertTimeFromString(
                            snapshot.data!.endAt!, 'dd/MM/yyyy hh:mm')
                    : "");
            return Center(
              child: Container(
                width: _mediaQuery.size.width,
                color: Colors.white,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: SingleChildScrollView(
                  child: SizedBox(
                    child: Column(children: <Widget>[
                      const SizedBox(height: 20),
                      Text(
                        snapshot.data!.name ?? '',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: <TextSpan>[
                          const TextSpan(
                            text: "Sẽ diễn ra vào lúc ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          TextSpan(
                            text: StringUtils.convertTimeFromString(
                                snapshot.data!.startAt, 'hh:mm'),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      if (!widget.isChecked) _qrView(snapshot.data),
                      if (widget.isChecked)
                        const Image(
                          image: AssetImage(
                              'lib/assets/icons/checked-success.png'),
                          width: 200,
                          height: 200,
                        ),
                      const SizedBox(height: 20),
                      if (!widget.isChecked)
                        const Text(
                          "Vui lòng quét mã QR bên trên để điểm danh",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (widget.isChecked)
                        const Text(
                          "Bạn đã điểm danh tham gia cuộc họp",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      const SizedBox(height: 40),
                      Container(
                        height: 100,
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[100]!),
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.grey[100],
                        ),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 25),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: <TextSpan>[
                                const TextSpan(
                                  text: "Địa điểm: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: snapshot.data!.address ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 7),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: <TextSpan>[
                                if (snapshot.data!.seatPosition != null)
                                  const TextSpan(
                                    text: "Vị trí ngồi: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                TextSpan(
                                  text: snapshot.data!.seatPosition ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      if (widget.isChecked &&
                          (snapshot.data!.memberRole == 1 ||
                              snapshot.data!.memberRole == 0))
                        Column(
                          children: [
                            SizedBox(
                              height: 70,
                              width: 70,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  shape: const CircleBorder(),
                                ),
                                onPressed: _onClickControlMeeting,
                                child: Image.asset(
                                  'lib/assets/icons/icons_meeting_room.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                            TextButton(
                              child: const Text(
                                "Điều hành cuộc họp",
                                style: TextStyle(color: Colors.black54),
                              ),
                              onPressed: _onClickControlMeeting,
                            ),
                          ],
                        ),
                    ]),
                  ),
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
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
              size: _mediaQuery.size.width * 0.6,
            );
          } else {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _handleDataJoin(snapshot.data));
            return GestureDetector(
              child: Container(
                width: 140,
                height: 140,
                child: DottedBorder(
                  dashPattern: const [3, 3, 3, 3],
                  radius: const Radius.circular(10),
                  strokeWidth: 1,
                  strokeCap: StrokeCap.square,
                  borderType: BorderType.RRect,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 248, 248, 248),
                    ),
                    child: const Center(
                      child: Text(
                        'Click vào đây để nhận mã QR và xác nhận tham gia cuộc họp',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 88, 88, 88),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              onTap: () {
                _showConfirmJoinDialog();
              },
            );
          }
        });
  }

  _onClickControlMeeting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageControlMeetingWebview(
          meetingID: widget.meetingBloc.onGetMeetingId(),
        ),
      ),
    );
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
                child: const Text('Huỷ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 30, 37, 239),
                      Color.fromARGB(255, 16, 116, 230)
                    ],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Xác nhận',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _onJoinMeeting();
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
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
      _showWarnMeetingDialog(
          VNPTDialogType.warning, data, 'Trùng lịch họp', '${data.msg}');
    } else if (data.code == 2) {
      _showWarnMeetingDialog(
          VNPTDialogType.error, data, 'Từ chối tham dự', '${data.msg}');
    }
  }

  _showWarnMeetingDialog(type, data, title, description) {
    if (data == null) return;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: type,
            title: title,
            description: description,
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 14)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
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
