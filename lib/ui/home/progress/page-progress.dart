import 'dart:async';
import 'dart:convert';

import 'package:nmeeting/bloc/documentBloc.dart';
import 'package:nmeeting/bloc/ideaBloc.dart';
import 'package:nmeeting/bloc/in-meeting/in-meetingBloc.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/bloc/progressBloc.dart';
import 'package:nmeeting/bloc/votingBloc.dart';
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:nmeeting/models/progress.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-progress-dialog.dart';
import 'package:nmeeting/ui/home/control-meeting/page-control-meeting-webview.dart';
import 'package:nmeeting/ui/home/meeting/page-meeting-detail.dart';
import 'package:nmeeting/ui/home/member-join-meeting/page-member-join-meeting-webview.dart';
import 'package:nmeeting/ui/home/progress/page-document.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:speech_to_text/speech_to_text.dart' as STT;

class PageProgress extends StatefulWidget {
  final ProgressBloc progressBloc;

  PageProgress({Key? key, required this.progressBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageProgressState();
  }
}

enum VotingViewMode { none, open, complete, declare }

class _PageProgressState extends State<PageProgress> {
  late IOWebSocketChannel _channel;
  late IOWebSocketChannel _ideaChannel;
  late IOWebSocketChannel _startVotingChannel;
  late IOWebSocketChannel _endVotingChannel;
  late IOWebSocketChannel _declareVotingChannel;

  final _votingBloc = VotingBloc();
  final _ideaBloc = IdeaBloc();
  final _documentBloc = DocumentBloc();
  final _inMeetingData = InMeetingBloc();
  late STT.SpeechToText _speechToText;
  bool _isListening = false;
  String _textSpeech = "";

  bool _isOpenFi = false;
  bool _isOpenCo = false;

  int _flexSize = 1;

  //String _inviteIdeaText = '';
  //bool _isInviteMeIdea = false;
  //bool _isUserIdeaDisplay = false;
  //bool _isVotingDisplay = false;

  static const meetingInfo = 'Thông tin cuộc họp';
  static const memberJoin = 'Thành viên tham gia';
  static const controlMeeting = 'Điều hành cuộc họp';

  void handleStartSpeech() async {
    _textSpeech = '';
    setState(() {
      _isListening = true;
    });
    if (_isListening) {
      await _speechToText.initialize(
          onStatus: (val) => print("onStatus: $val"),
          onError: (err) => print("onError: $err"));

      _speechToText.listen(
          onResult: (val) => setState(() => {
                _textSpeech = val.recognizedWords,
              }));
    } else {
      setState(() {
        _speechToText.stop();
      });
    }
  }

  void handleEndSpeech() async {
    setState(() {
      _isListening = false;
    });
    if (_isListening) {
      await _speechToText.initialize(
          onStatus: (val) => print("onStatus: $val"),
          onError: (err) => print("onError: $err"));

      _speechToText.listen(
          onResult: (val) => setState(() => {
                _textSpeech = val.recognizedWords,
              }));
    } else {
      setState(() {
        _speechToText.stop();
      });
    }
  }

  @override
  void initState() {
    // if (widget.pageIndex != constants.PAGE_PROGRESS) {
    //   return;
    // }
    super.initState();
    _speechToText = STT.SpeechToText();
    _ideaBloc.onSetMeetingId(widget.progressBloc.onGetMeetingId());
    _votingBloc.onSetMeetingId(widget.progressBloc.onGetMeetingId());
    _inMeetingData.onSetMeetingId(widget.progressBloc.onGetMeetingId());
    _inMeetingData.onGetMeetingDetailById();
    this._getAllProgress();
    this._openProgressWebSocketChannel();
    this._openIdeaWebSocketChannel();
    this._openVotingStartWebSocketChannel();
    this._openVotingEndWebSocketChannel();
    this._openVotingDeclareWebSocketChannel();

    // _ideaBloc.startCheck();
    // _registCheck();
  }

  _openProgressWebSocketChannel() async {
    _channel = await widget.progressBloc.openProgressWebSocketChannel();
    _listenProgressWebSocketChannel();
  }

  _reopenProgressWebSocketChannel() async {
    _channel = await widget.progressBloc.openProgressWebSocketChannel();
    _listenProgressWebSocketChannel();
  }

  _listenProgressWebSocketChannel() {
    _channel.stream.listen((message) {
      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) {
        if (isConnected) {
          if (StringUtils.isNullOrEmpty(message)) {
            return;
          }
          Map<String, dynamic> res = jsonDecode(message);
          if (widget.progressBloc.onGetMeetingId().toLowerCase() ==
              res['meetingID'].toLowerCase()) {
            this._getAllProgress();
          }
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

  _openIdeaWebSocketChannel() async {
    _ideaChannel = await _ideaBloc.openIdeaWebSocketChannel();
    _listenIdeaWebSocketChannel();
  }

  _listenIdeaWebSocketChannel() {
    _ideaChannel.stream.listen((message) {
      if (StringUtils.isNullOrEmpty(message)) {
        return;
      }
      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) async {
        if (isConnected) {
          Map<String, dynamic> resWs = jsonDecode(message);
          if (resWs['meetingID'].toLowerCase() ==
              widget.progressBloc.onGetMeetingId().toLowerCase()) {
            // admin start idea
            if (resWs['type'] == 0) {
              this._getAllProgress();
            } else if (resWs['type'] == 1) {
              // admin invite user idea
              this._getAllProgress();

              final prefs = await SharedPreferences.getInstance();
              if (resWs['meetingID'].toLowerCase() ==
                      widget.progressBloc.onGetMeetingId() &&
                  resWs['personalID'].toLowerCase() !=
                      prefs.getString('personalID')) {
                _showInviteToAllMember(resWs['inviteMessage']);
              }
            }
          }
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
            _openIdeaWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  _openVotingStartWebSocketChannel() async {
    _startVotingChannel = await _votingBloc.openVotingStartWebSocketChannel();
    _listenVotingStartWebSocketChannel();
  }

  _listenVotingStartWebSocketChannel() {
    _startVotingChannel.stream.listen((message) {
      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) {
        if (isConnected) {
          if (StringUtils.isNullOrEmpty(message)) {
            return;
          }
          Map<String, dynamic> resWs = jsonDecode(message);
          if (resWs['meetingID'].toLowerCase() ==
              widget.progressBloc.onGetMeetingId().toLowerCase()) {
            this._getAllProgress();
          }
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
            _openVotingStartWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  // listen admin end voting
  _openVotingEndWebSocketChannel() async {
    _endVotingChannel = await _votingBloc.openVotingEndWebSocketChannel();
    _listenVotingEndWebSocketChannel();
  }

  _reopenVotingEndWebSocketChannel() async {
    _endVotingChannel = await _votingBloc.openVotingEndWebSocketChannel();
    _listenVotingEndWebSocketChannel();
  }

  _listenVotingEndWebSocketChannel() {
    _endVotingChannel.stream.listen((message) {
      if (StringUtils.isNullOrEmpty(message)) {
        return;
      }
      Map<String, dynamic> resWs = jsonDecode(message);
      if (widget.progressBloc.onGetMeetingId().toLowerCase() !=
          resWs['meetingID']) {
        return;
      }

      this._getAllProgress();
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
            _reopenVotingEndWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  // listen admin declare voting
  _openVotingDeclareWebSocketChannel() async {
    _declareVotingChannel =
        await _votingBloc.openVotingDeclareWebSocketChannel();
    _listenVotingDeclareWebSocketChannel();
  }

  _reopenVotingDeclareWebSocketChannel() async {
    _declareVotingChannel =
        await _votingBloc.openVotingDeclareWebSocketChannel();
    _listenVotingDeclareWebSocketChannel();
  }

  _listenVotingDeclareWebSocketChannel() {
    _declareVotingChannel.stream.listen((message) {
      if (StringUtils.isNullOrEmpty(message)) {
        return;
      }

      if (_votingBloc.onGetMeetingId().toLowerCase() != message.toLowerCase()) {
        return;
      }

      this._getAllProgress();
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
            _reopenVotingDeclareWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  _getAllProgress() {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        widget.progressBloc.getAllProgress();
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  String getInviteMessage(msg) {
    List<String> msgList = [];
    // has next member
    if (msg.contains(';')) {
      msgList = msg.split(';');

      return msgList[0] + msgList[1];
    }

    return msg;
  }

  choiceAction(String choice) async {
    if (choice == meetingInfo) {
      final _inmeetingBloc = InMeetingBloc();
      final _meetingBloc = MeetingBloc();
      _meetingBloc.onSetMeetingId(widget.progressBloc.onGetMeetingId());
      _inmeetingBloc.onSetMeetingId(widget.progressBloc.onGetMeetingId());

      // DateTime tempDate = DateTime.parse(DateTime.now().toString());
      // _inmeetingBloc.onSetMeetingTime(tempDate);
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
    } else if (choice == memberJoin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PageMemberJoinMeetingWebview(
            meetingID: widget.progressBloc.onGetMeetingId(),
          ),
        ),
      );
    } else if (choice == controlMeeting) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PageControlMeetingWebview(
            meetingID: widget.progressBloc.onGetMeetingId(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.pageIndex != constants.PAGE_PROGRESS) {
    //   return Container();
    // }
    final _mediaQuery = MediaQuery.of(context);

    double _timeWidthForFinishUpcomming = 0;

    if (_mediaQuery.size.width <= 320) {
      _flexSize = 6;
      _timeWidthForFinishUpcomming = _mediaQuery.size.width * 0.3;
    } else if (_mediaQuery.size.width <= 420) {
      _flexSize = 7;
      _timeWidthForFinishUpcomming = _mediaQuery.size.width * 0.32;
    } else {
      _timeWidthForFinishUpcomming = _mediaQuery.size.width * 0.42;
      _flexSize = 10;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: StreamBuilder<String>(
            stream: widget.progressBloc.meetingNameStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Text(
                  snapshot.data!,
                  style: TextStyle(color: Colors.black, fontSize: 22),
                );
              }
              return Center(child: CircularProgressIndicator());
            }),
        actions: <Widget>[
          StreamBuilder<int>(
            stream: _inMeetingData.memberRoleStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == 1 || snapshot.data == 0)
                  return Container(
                    alignment: Alignment.topRight,
                    child: PopupMenuButton<String>(
                        child: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                            padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Icon(Icons.more_vert,
                                    size: 25, color: Colors.black)
                              ],
                            )),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.transparent,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8)),
                        offset: Offset(0, 50),
                        padding: EdgeInsets.all(0),
                        onSelected: choiceAction,
                        itemBuilder: (BuildContext context) {
                          return [
                            meetingInfo,
                            memberJoin,
                            controlMeeting,
                          ].map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        }),
                  );
              }
              return Container(
                alignment: Alignment.topRight,
                child: PopupMenuButton<String>(
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                        padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(Icons.more_vert, size: 25, color: Colors.black)
                          ],
                        )),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8)),
                    offset: Offset(0, 50),
                    padding: EdgeInsets.all(0),
                    onSelected: choiceAction,
                    itemBuilder: (BuildContext context) {
                      return [
                        meetingInfo,
                        memberJoin,
                      ].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    }),
              );
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(5),
          child: StreamBuilder<ProgressIdea>(
              stream: widget.progressBloc.progressListStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final List<ProgressOutput> _progressData =
                      snapshot.data!.progressOutput!;
                  final Idea _ideaData = snapshot.data!.idea!;
                  if (_progressData.length == 0) {
                    return _nodata('No information');
                  }

                  return Column(
                    children: <Widget>[
                      if (_isOpenCo == false)
                        _isOpenFi == true
                            ? _buildFinishExpand(
                                _timeWidthForFinishUpcomming, _progressData)
                            : _buildFinishCollapse(
                                _timeWidthForFinishUpcomming, _progressData),
                      SizedBox(
                        height: _isOpenFi || _isOpenCo ? 0 : 5,
                      ),
                      if (_isOpenFi == false && _isOpenCo == false)
                        _buildCurrentProgress(_progressData, _ideaData),
                      SizedBox(
                        height: _isOpenFi || _isOpenCo ? 0 : 5,
                      ),
                      if (_isOpenFi == false)
                        _isOpenCo == true
                            ? _buildUpCommingExpand(
                                _timeWidthForFinishUpcomming, _progressData)
                            : _buildUpCommingCollapse(
                                _timeWidthForFinishUpcomming, _progressData)
                    ],
                  );
                }
                return Center(child: CircularProgressIndicator());
              }),
        ),
      ),
    );
  }

  //bool _isDialogShowing = false;
  // _registCheck() {
  //   setState(() {
  //     _inviteIdeaText = '';
  //   });
  //   Future<String> _fuRes = _ideaBloc.registCheck();
  //   _fuRes.then((msg) {
  //     if (!StringUtils.isNullOrEmpty(msg)) {
  //       List<String> msgList = [];
  //       // has next member
  //       if (msg.contains(';')) {
  //         msgList = msg.split(';');

  //         setState(() {
  //           _inviteIdeaText = msgList[0] + msgList[1];
  //         });
  //       } else {
  //         setState(() {
  //           _inviteIdeaText = msg;
  //         });
  //       }
  //     }
  //   });
  // }

  _sendRegist(ideaId) async {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        // setState(() {
        //   _inviteIdeaText = '';
        // });

        final _vnptProgress = VNPTProgressDialog(context);
        _vnptProgress.show();
        Future<TResult> _fuRes = widget.progressBloc.sendRegist(ideaId);
        _fuRes.then((res) {
          _vnptProgress.hide();
          if (!StringUtils.isNullOrEmpty(res.msg)) {
            showToast(res.msg);
          }

          if (res.status == 1) {
            this._getAllProgress();
            // send notification to socket
            final _message = {
              'meetingID': widget.progressBloc.onGetMeetingId(),
              'actionType': 'RegistIdea',
            };
            _ideaChannel.sink.add(jsonEncode(_message));
          }
        });
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  _userEndIdea(ideaDetailID, description) {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        Future<TResult> _futureRes =
            _ideaBloc.endIdea(ideaDetailID, description);

        _futureRes.then((res) async {
          if (res.status == 1) {
            // send notification to socket
            final prefs = await SharedPreferences.getInstance();
            final _message = {
              'meetingID': widget.progressBloc.onGetMeetingId(),
              'actionType': 'EndIdea',
              'personalID': prefs.getString('personalID')
            };
            _ideaChannel.sink.add(jsonEncode(_message));

            showToast('Bạn đã hoàn thành bài phát biểu');
          }

          this._getAllProgress();
        });
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  _ideaRender(Idea _idea) {
    if (_idea == null) {
      return Container();
    }

    if ((!(_idea.accountHasRegist ?? false) ||
            (_idea.isUserEndIdea ?? false)) &&
        !(_idea.accountHasInviteByAdmin ?? false)) {
      return Container(
        width: double.infinity,
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: <Widget>[
              Text(
                'Vui lòng nhấn vào nút bên dưới để đăng ký phát biểu!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    Image(
                      image: AssetImage('lib/assets/icons/idea-active.png'),
                      fit: BoxFit.fill,
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
                onTap: () {
                  // regist or cancel idea
                  _sendRegist(_idea.id);
                },
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Đăng ký phát biểu',
                style: TextStyle(fontSize: 18, color: Colors.red),
              )
            ],
          ),
        ),
      );
    }

    if ((_idea.accountHasRegist ?? false) &&
        !(_idea.accountHasInviteByAdmin ?? false)) {
      return Container(
          width: double.infinity,
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: <Widget>[
                Text(
                  'Bạn có thể hủy đăng ký phát biểu bằng cách nhấn vào nút bên dưới!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      Image(
                        image: AssetImage('lib/assets/icons/idea-cancel.png'),
                        fit: BoxFit.fill,
                        width: 40,
                        height: 40,
                      )
                    ],
                  ),
                  onTap: () {
                    // regist or cancel idea
                    _sendRegist(_idea.id);
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Hủy đăng ký',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                )
              ],
            ),
          ));
    }

    if (_idea.accountHasInviteByAdmin ?? false) {
      // if admin invite
      return Container(
        width: double.infinity,
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: <Widget>[
                  Text(
                    _isListening
                        ? 'Bài phát biểu của bạn đang được ghi âm để chuyển sang văn bản!'
                        : 'Vui lòng nhấn vào nút bên dưới để chuyển giọng nói thành văn bản',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  _isListening
                      ? Image(
                          image:
                              AssetImage('lib/assets/icons/current-idea.gif'),
                          fit: BoxFit.fill,
                          width: 120,
                          height: 60,
                        )
                      : GestureDetector(
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    color: Colors.grey[500],
                                    borderRadius: BorderRadius.circular(28)),
                              ),
                              Image(
                                image: AssetImage(
                                    'lib/assets/icons/speech-2-text.png'),
                                fit: BoxFit.fill,
                                width: 40,
                                height: 40,
                              )
                            ],
                          ),
                          onTap: () => handleStartSpeech(),
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    _isListening ? '' : 'Chuyển giọng nói thành văn bản',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 10,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Text(
                    _idea.memberInvited != null
                        ? getInviteMessage(_idea.memberInvited!.message)
                        : '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Sau khi phát biểu ý kiến, vui lòng nhấn vào nút bên dưới để kết thúc!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        Image(
                          image:
                              AssetImage('lib/assets/icons/idea-complete.png'),
                          fit: BoxFit.fill,
                          width: 40,
                          height: 40,
                        )
                      ],
                    ),
                    onTap: () {
                      //handle end speech to text
                      handleEndSpeech();
                      // call API
                      _userEndIdea(_idea.ideaDetailID, _textSpeech);
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Kết thúc phát biểu',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  bool _isDialogShowing = false;
  _showInviteToAllMember(msg) {
    if (!StringUtils.isNullOrEmpty(msg)) {
      if (_isDialogShowing) {
        Navigator.of(context).pop();
      }

      List<String> msgList = [];
      // has next member
      if (msg.contains(';')) {
        msgList = msg.split(';');
      }

      _isDialogShowing = true;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                // listen Android Back Button Pressed
                _isDialogShowing = false;
                Navigator.of(context).pop();
                return true;
              },
              child: VNPTDialog(
                type: VNPTDialogType.success,
                title: 'Thông tin',
                description: msgList.length == 0 ? msg : null,
                descriptionWidget: msgList.length == 2
                    ? Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Image(
                                image: AssetImage(
                                    'lib/assets/icons/current-idea.gif'),
                                height: 45,
                              ),
                              Flexible(
                                  child: Text(
                                msgList[0],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ))
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 5,
                              ),
                              Image(
                                image: AssetImage(
                                    'lib/assets/icons/next-idea.png'),
                                height: 35,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                  child: Text(
                                msgList[1],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ))
                            ],
                          ),
                        ],
                      )
                    : null,
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Thay cho color
                      foregroundColor: Colors.white, // Thay cho textColor
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                    onPressed: () {
                      _isDialogShowing = false;
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK'.toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          });
    }
  }

  _votingRender(
      CurrentQuestion currentQuestion, ResultQuestion resultQuestion) {
    if (currentQuestion == null) {
      return Container();
    }
    bool _isChosen = (currentQuestion.answers ?? [])
        .any((element) => element.isChosen == true);

    if (currentQuestion != null &&
        (currentQuestion.startFlg ?? false) &&
        !_isChosen &&
        !(currentQuestion.endFlg ?? false) &&
        !(currentQuestion.declareFlg ?? false)) {
      return Container(
        width: double.infinity,
        color: Colors.grey[200],
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: <Widget>[
                Text(
                  currentQuestion.questionName!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _onAnswer(
                              currentQuestion.questionID!,
                              currentQuestion.answers![0].id!,
                            );
                          },
                          child: Text(
                            currentQuestion.answers![0].name!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _onAnswer(
                              currentQuestion.questionID!,
                              currentQuestion.answers![1].id!,
                            );
                          },
                          child: Text(
                            currentQuestion.answers![1].name!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )),
      );
    }

    if ((_isChosen || (currentQuestion.endFlg ?? false)) &&
        !(currentQuestion.declareFlg ?? false)) {
      return Container(
        width: double.infinity,
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: <Widget>[
              Text(_isChosen ? 'Đã hoàn thành' : 'Đã kết thúc',
                  style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 38, 61, 117),
                      fontWeight: FontWeight.bold)),
              Image(
                image: AssetImage('lib/assets/images/voting-completed.gif'),
                width: 120,
              ),
              Text(
                'Vui lòng đợi trong giây lát',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
    if (currentQuestion.declareFlg ?? false) {
      return Container(
        width: double.infinity,
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 252, 224),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              height: 80,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'KẾT QUẢ BIỂU QUYẾT',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      resultQuestion.questionName!
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 252, 224),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              height: 60,
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Thời gian',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 252, 224),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              height: 60,
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  resultQuestion.hh! + ':' + resultQuestion.mm!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: resultQuestion.answers!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(0),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 252, 224),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    height: 60,
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        resultQuestion.answers![index].name!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 252, 224),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    height: 60,
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        resultQuestion
                                            .answers![index].numberChosen
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 252, 224),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    height: 60,
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        '${((resultQuestion.answers![index].numberChosen! * 100) / resultQuestion.totalUserJoin!).toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      );
    }
  }

  _onAnswer(String _questionID, String answerID) {
    Future<TResult> _fu =
        widget.progressBloc.onAnwserSelected(_questionID, answerID, true);
    _fu.then((res) {
      if (res.status == 1) {
        this._getAllProgress();
      }
    });
  }

  _buildCurrentProgress(List<ProgressOutput> _progressData, Idea _ideaData) {
    ProgressOutput? _currentProgressData = _progressData.firstWhere(
      (element) => element.isActiveNewest == true,
      orElse: () => ProgressOutput(), // hoặc tạo một instance mặc định
    );

    // _isVotingDisplay =
    //     !StringUtils.isNullOrEmpty(_currentProgressData.problemNameNewest);

    return Expanded(
      flex: _flexSize,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.orange, width: 7))),
        child: Material(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: <Widget>[
                if (_currentProgressData != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          StringUtils.convertTimeFromString(
                              _currentProgressData.time, 'hh:mm'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 35),
                        child: Text(
                          'Đang diễn ra',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      _currentProgressData != null &&
                              _currentProgressData.isHasDocument!
                          ? GestureDetector(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    height: 25,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                                    child: Text(
                                      'Xem tài liệu',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _documentBloc.onSetMeetingId(
                                    widget.progressBloc.onGetMeetingId());
                                _documentBloc
                                    .onSetProgressId(_currentProgressData.id!);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PageDocument(
                                          documentBloc: _documentBloc),
                                    ));
                              },
                            )
                          : Container(
                              width: 100,
                            )
                    ],
                  ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: _currentProgressData == null
                      ? Column(
                          children: <Widget>[_nodata('Không có tiến trình')],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      _currentProgressData.name!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // if (!StringUtils.isNullOrEmpty(
                              //     _currentProgressData.problemNameNewest))
                              //   Container(
                              //     padding: EdgeInsets.only(
                              //         top: 20, left: 5, bottom: 10),
                              //     child: Row(
                              //       children: <Widget>[
                              //         Flexible(
                              //           child: Container(
                              //             padding: EdgeInsets.only(left: 15),
                              //             decoration: BoxDecoration(
                              //               border: Border(
                              //                 left: BorderSide(
                              //                   color: Colors.black,
                              //                   width: 1,
                              //                 ),
                              //               ),
                              //             ),
                              //             child: Text(
                              //               _currentProgressData
                              //                   .problemNameNewest,
                              //               style: TextStyle(
                              //                 fontSize: 18,
                              //                 fontWeight: FontWeight.bold,
                              //                 color: Colors.grey[600],
                              //               ),
                              //             ),
                              //           ),
                              //         )
                              //       ],
                              //     ),
                              //   ),
                              SizedBox(
                                height: 10,
                              ),
                              if (_ideaData != null) _ideaRender(_ideaData),
                              if (_ideaData == null &&
                                  _currentProgressData.currentQuestion != null)
                                _votingRender(
                                    _currentProgressData.currentQuestion!,
                                    _currentProgressData.resultQuestion!)
                            ],
                          ),
                        ),
                ),
                // Container(
                //   padding: EdgeInsets.only(top: 10),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: <Widget>[
                //       _currentProgressData != null &&
                //               _currentProgressData.isHasDocument
                //           ? GestureDetector(
                //               child: Padding(
                //                 padding: const EdgeInsets.only(left: 15),
                //                 child: Image(
                //                   image: AssetImage(
                //                       'lib/assets/icons/document-active.png'),
                //                   fit: BoxFit.fill,
                //                   width: 45,
                //                   height: 45,
                //                 ),
                //               ),
                //               onTap: () {
                //                 _documentBloc.onSetMeetingId(
                //                     widget.progressBloc.onGetMeetingId());
                //                 _documentBloc
                //                     .onSetProgressId(_currentProgressData.id);
                //                 Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                       builder: (context) => PageDocument(
                //                           documentBloc: _documentBloc),
                //                     ));
                //               },
                //             )
                //           : Padding(
                //               padding: const EdgeInsets.only(left: 15),
                //               child: Image(
                //                 image: AssetImage(
                //                     'lib/assets/icons/document-inactive.png'),
                //                 fit: BoxFit.fill,
                //                 width: 45,
                //                 height: 45,
                //               ),
                //             ),
                // _currentProgressData != null &&
                //         _currentProgressData.isHasQuestion
                //     ? GestureDetector(
                //         child: Padding(
                //           padding: const EdgeInsets.only(left: 15),
                //           child: Image(
                //             image: AssetImage(
                //                 'lib/assets/icons/voting-active.png'),
                //             fit: BoxFit.fill,
                //             width: 45,
                //             height: 45,
                //           ),
                //         ),
                //         onTap: () {
                //           _votingBloc.onSetMeetingId(
                //               widget.progressBloc.onGetMeetingId());
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => PageVoting(
                //                   votingBloc: _votingBloc,
                //                 ),
                //               ));
                //         },
                //       )
                //     : Padding(
                //         padding: const EdgeInsets.only(left: 15),
                //         child: Image(
                //           image: AssetImage(
                //               'lib/assets/icons/voting-inactive.png'),
                //           fit: BoxFit.fill,
                //           width: 45,
                //           height: 45,
                //         ),
                //       ),
                //     ],
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nodata(String _msg) {
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
            _msg,
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  _buildFinishCollapse(
      double _timeWidthForFinishUpcomming, List<ProgressOutput> _data) {
    List<ProgressOutput> _fiCollapseData =
        _data.where((element) => element.activeFlg == true).toList();
    return Expanded(
      flex: 1,
      child: GestureDetector(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.red, width: 7))),
          child: Material(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: _timeWidthForFinishUpcomming,
                    child: Text(
                      _fiCollapseData.length == 0
                          ? ''
                          : StringUtils.convertTimeFromString(
                              _fiCollapseData[0].time, 'hh:mm'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text(''),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                'Đã điễn ra',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Image(
                            image: AssetImage('lib/assets/icons/down.png'),
                            fit: BoxFit.fill,
                            width: 20,
                            height: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 3) {
            print('Down Swipe');
            setState(() {
              _isOpenFi = true;
            });
          }
        },
      ),
    );
  }

  _buildFinishExpand(
      double _timeWidthForFinishUpcomming, List<ProgressOutput> _data) {
    List<ProgressOutput> _fiExpandData = _data
        .where((element) =>
            element.activeFlg == true && !(element.isActiveNewest ?? false))
        .toList();

    return Expanded(
      flex: 1,
      child: GestureDetector(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.red, width: 7))),
            child: Material(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: _fiExpandData.length == 0
                          ? ListView(
                              children: <Widget>[
                                _nodata('Không có tiến trình')
                              ],
                            )
                          : ListView.builder(
                              itemCount: _fiExpandData.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return Container(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      StringUtils.convertTimeFromString(
                                          _fiExpandData[index].time, 'hh:mm'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 5, 0, 5),
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                            child: Container(
                                              padding:
                                                  EdgeInsets.only(left: 25),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(
                                                    color: Colors.black,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                _fiExpandData[index].name!,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ));
                              }),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Image(
                        image: AssetImage('lib/assets/icons/up.png'),
                        fit: BoxFit.fill,
                        width: 20,
                        height: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < -3) {
              print('Up Swipe');
              setState(() {
                _isOpenFi = false;
              });
            }
          }),
    );
  }

  _buildUpCommingCollapse(
      double _timeWidthForFinishUpcomming, List<ProgressOutput> _data) {
    List<ProgressOutput> _upCollapseData =
        _data.where((element) => element.activeFlg != true).toList();
    return Expanded(
      flex: 1,
      child: GestureDetector(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.blue, width: 7))),
            child: Material(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: _timeWidthForFinishUpcomming - 15,
                      child: Text(
                        _upCollapseData.length == 0
                            ? ''
                            : StringUtils.convertTimeFromString(
                                _upCollapseData[0].time, 'hh:mm'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Image(
                              image: AssetImage('lib/assets/icons/up.png'),
                              fit: BoxFit.fill,
                              width: 20,
                              height: 8,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'Sắp diễn ra',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            child: Text(''),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < -3) {
              print('yellow up');
              setState(() {
                _isOpenCo = true;
              });
            }
          }),
    );
  }

  _buildUpCommingExpand(
      double _timeWidthForFinishUpcomming, List<ProgressOutput> _data) {
    List<ProgressOutput> _upExpandData =
        _data.where((element) => element.activeFlg != true).toList();

    return Expanded(
      flex: 1,
      child: GestureDetector(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.blue, width: 7))),
            child: Material(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Image(
                        image: AssetImage('lib/assets/icons/down.png'),
                        fit: BoxFit.fill,
                        width: 20,
                        height: 8,
                      ),
                    ),
                    Expanded(
                      child: _upExpandData.length == 0
                          ? ListView(
                              children: <Widget>[
                                _nodata('Không có tiến trình')
                              ],
                            )
                          : ListView.builder(
                              itemCount: _upExpandData.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return Container(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      StringUtils.convertTimeFromString(
                                          _upExpandData[index].time, 'hh:mm'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 5, 0, 5),
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                            child: Container(
                                              padding:
                                                  EdgeInsets.only(left: 25),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(
                                                    color: Colors.black,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                _upExpandData[index].name!,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ));
                              }),
                    )
                  ],
                ),
              ),
            ),
          ),
          onVerticalDragUpdate: (details) {
            if (details.delta.dy > 3) {
              print('yellow down');
              setState(() {
                _isOpenCo = false;
              });
            }
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_channel != null) {
      _channel.sink.close();
    }

    if (_ideaChannel != null) {
      _ideaChannel.sink.close();
    }

    if (_startVotingChannel != null) {
      _startVotingChannel.sink.close();
    }

    if (_endVotingChannel != null) {
      _endVotingChannel.sink.close();
    }

    if (_declareVotingChannel != null) {
      _declareVotingChannel.sink.close();
    }
  }
}
