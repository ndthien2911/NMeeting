import 'dart:async';
import 'dart:convert';

import 'package:nmeeting/bloc/votingBloc.dart';
import 'package:nmeeting/models/voting.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/ui/home/progress/page-voting-detail-result-BC.dart';
import 'package:nmeeting/ui/home/progress/page-voting-detail-result-BQ.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web_socket_channel/io.dart';

class PageVotingDetail extends StatefulWidget {
  final VotingBloc votingBloc;
  final int groupId;

  const PageVotingDetail(
      {Key key, @required this.votingBloc, @required this.groupId})
      : super(key: key);

  @override
  _PageVotingDetailState createState() => _PageVotingDetailState();
}

class _PageVotingDetailState extends State<PageVotingDetail> {
  var _pageViewcontroller = new PageController(initialPage: 0);
  IOWebSocketChannel _channelVotingDeclare;
  IOWebSocketChannel _channelVotingEnd;

  @override
  void initState() {
    super.initState();
    _initValue();
  }

  _initValue() async {
    widget.votingBloc.onSetCompleteProblem(null);
    Future<TResult> _fRes = widget.votingBloc.checkCompleteProblem();
    _fRes.then((res) async {
      if (res.status == 1 && !res.data.isComplete && !res.data.isEndFlg) {
        await widget.votingBloc.getQuestionByProblemId();
        _pageViewcontroller = new PageController(
            initialPage: widget.votingBloc.firstIndexQuestionNoAnwser);
      }
    });

    _openVotingEndWebSocketChannel();
  }

  // listen admin declare voting
  _openVotingDeclareWebSocketChannel() async {
    _channelVotingDeclare =
        await widget.votingBloc.openVotingDeclareWebSocketChannel();
    _listenVotingDeclareWebSocketChannel();
  }

  _reopenVotingDeclareWebSocketChannel() async {
    _channelVotingDeclare =
        await widget.votingBloc.openVotingDeclareWebSocketChannel();
    _listenVotingDeclareWebSocketChannel();
  }

  _listenVotingDeclareWebSocketChannel() {
    _channelVotingDeclare.stream.listen((message) {
      if (StringUtils.isNullOrEmpty(message)) {
        return;
      }

      if (widget.votingBloc.onGetMeetingId().toLowerCase() !=
          message.toLowerCase()) {
        return;
      }

      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) {
        if (isConnected) {
          this._transferToResultPage();
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
            _reopenVotingDeclareWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  // listen admin end voting
  _openVotingEndWebSocketChannel() async {
    _channelVotingEnd = await widget.votingBloc.openVotingEndWebSocketChannel();
    _listenVotingEndWebSocketChannel();
  }

  _reopenVotingEndWebSocketChannel() async {
    _channelVotingEnd = await widget.votingBloc.openVotingEndWebSocketChannel();
    _listenVotingEndWebSocketChannel();
  }

  _listenVotingEndWebSocketChannel() {
    _channelVotingEnd.stream.listen((message) {
      if (StringUtils.isNullOrEmpty(message)) {
        return;
      }
      Map<String, dynamic> resWs = jsonDecode(message);
      if (widget.votingBloc.onGetMeetingId() != resWs['meetingID']) {
        return;
      }

      if (widget.votingBloc.onGetProlemId() != resWs['topicID']) {
        return;
      }

      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) {
        if (isConnected) {
          if (_isConfirmDialogShowing) {
            Navigator.of(context).pop();
          }
          widget.votingBloc.checkCompleteProblem();
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
            _reopenVotingEndWebSocketChannel();
          }
        });
      });
    }, onError: (err, StackTrace stackTrace) {
      print(err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompleteOutput>(
        stream: widget.votingBloc.isCompleteProblemStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isComplete) {
              return _buildVotingComplete(true);
            }
            if (snapshot.data.isEndFlg) {
              return _buildVotingComplete(false);
            }
            return Container(
              child: Scaffold(
                appBar: AppBar(
                    leading: BackButton(color: Colors.black),
                    title: StreamBuilder<String>(
                        stream: widget.votingBloc.problemIndexStream,
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.hasData ? snapshot.data : '',
                            style: TextStyle(color: Colors.black),
                          );
                        }),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0),
                body: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: StreamBuilder<String>(
                            stream: widget.votingBloc.problemNameStream,
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.hasData
                                    ? snapshot.data.toUpperCase()
                                    : '',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 38, 61, 117)),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                              );
                            }),
                      ),
                      Expanded(
                        child: StreamBuilder<List<QuestionOutput>>(
                            stream: widget.votingBloc.questionListStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: <Widget>[
                                    _generateIndicator(),
                                    SizedBox(height: 5),
                                    Expanded(
                                      child: PageView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        onPageChanged: (_pageIndex) {
                                          widget.votingBloc
                                              .onChangedPageView(_pageIndex);
                                        },
                                        controller: _pageViewcontroller,
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          return Column(children: <Widget>[
                                            Text(
                                              snapshot.data[index].questionName,
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color: Color.fromARGB(
                                                      255, 38, 61, 117),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(
                                              child: _generateAnswers(
                                                  snapshot
                                                      .data[index].questionID,
                                                  snapshot.data[index].answers,
                                                  index ==
                                                      snapshot.data.length - 1),
                                            ),
                                          ]);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  _generateAnswers(
      String _questionId, List<Answer> _answers, bool _isLastPage) {
    // biểu quyết
    if (widget.groupId == 0) {
      if (_answers.length != 2) {
        return Container(
          child: null,
        );
      }
      return ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ButtonTheme(
                      height: 50,
                      child: RaisedButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text(_answers[0].name,
                            style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          widget.votingBloc
                              .onChoosen(_questionId, _answers[0].id);
                          _answerSelected(_questionId, _answers);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ButtonTheme(
                      height: 50,
                      child: RaisedButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text(_answers[1].name,
                            style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          widget.votingBloc
                              .onChoosen(_questionId, _answers[1].id);
                          _answerSelected(_questionId, _answers);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    }

    // bầu cử
    return ListView.builder(
        // + 1 for 'Xác nhận' button
        itemCount: _answers.length + 1,
        itemBuilder: (context, index) {
          if (index == _answers.length) {
            return Container(
              margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 29, 40, 238),
                    Color.fromARGB(255, 16, 113, 230)
                  ],
                ),
              ),
              child: MaterialButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                minWidth: double.infinity,
                height: 50,
                child: Text(
                  'Tiếp tục',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _answerSelected(_questionId, _answers);
                },
              ),
            );
          }
          return Container(
            padding: EdgeInsets.only(top: 15),
            child: FlatButton(
              padding: EdgeInsets.all(10),
              color: _answers[index].isChosen
                  ? Color.fromARGB(255, 255, 207, 212)
                  : Colors.grey[100],
              textColor: _answers[index].isChosen ? Colors.red : Colors.black54,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _answers[index].isChosen
                    ? Container(
                        child: Text(
                          _answers[index].name,
                          style: TextStyle(fontSize: 20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  'lib/assets/images/strikethrough.png'),
                              fit: BoxFit.fitWidth),
                        ),
                      )
                    : Text(
                        _answers[index].name,
                        style: TextStyle(fontSize: 20),
                      ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: Colors.grey)),
              onPressed: () {
                widget.votingBloc.onChoosen(_questionId, _answers[index].id);
              },
            ),
          );
        });
  }

  bool _isConfirmDialogShowing = false;
  _answerSelected(String _questionId, List<Answer> _anwsers) {
    final _mediaQuery = MediaQuery.of(context);
    _isConfirmDialogShowing = true;
    bool _isShowWarning = widget.groupId == 1 &&
        !widget.votingBloc.checkBCAnwserIsValid(_anwsers);
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              // listen Android Back Button Pressed
              _isConfirmDialogShowing = false;
              Navigator.of(context).pop();
            },
            child: VNPTDialog(
              type: _isShowWarning
                  ? VNPTDialogType.warning
                  : VNPTDialogType.question,
              title: _isShowWarning ? 'Cảnh báo' : 'Xác nhận',
              description: _isShowWarning
                  ? 'Bạn đã gạch tất cả hoặc không gạch, phiếu sẽ được xem là không hợp lệ. Bạn có đồng ý không?'
                  : 'Bạn có chắc không?',
              actions: <Widget>[
                SizedBox(
                  width: _mediaQuery.size.width / 4,
                  child: Container(
                    child: RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey[400])),
                      color: Colors.grey[400],
                      textColor: Colors.black,
                      child: Text('Không', style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        _isConfirmDialogShowing = false;
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: _mediaQuery.size.width / 4,
                  child: Container(
                    child: RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15),
                          side: BorderSide(color: Colors.green)),
                      color: Colors.green,
                      textColor: Colors.white,
                      child: Text('Có', style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        // close dialog
                        _isConfirmDialogShowing = false;
                        Navigator.of(context).pop();

                        // check complete status before anwser
                        Future<TResult> _futureRes =
                            widget.votingBloc.checkCompleteProblem();
                        _futureRes.then((res) {
                          if (res.status == 1 &&
                              !res.data.isComplete &&
                              !res.data.isEndFlg) {
                            // anwser
                            _futureRes = widget.votingBloc.onAnwserSelected(
                                _questionId,
                                _anwsers,
                                _isShowWarning ? false : true);
                            _futureRes.then((res) {
                              if (res.status == 1) {
                                _futureRes =
                                    widget.votingBloc.checkCompleteProblem();
                                // if not complete
                                _futureRes.then((res) {
                                  if (res.status == 1 &&
                                      !res.data.isComplete &&
                                      !res.data.isEndFlg) {
                                    _pageViewcontroller.nextPage(
                                        duration: kTabScrollDuration,
                                        curve: Curves.ease);
                                  }
                                });
                              } else {
                                showToast(res.msg);
                              }
                            });
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  _generateIndicator() {
    return StreamBuilder<List<Widget>>(
        stream: widget.votingBloc.indicatorListStream,
        builder: (context, snapshot) {
          return Wrap(
            runSpacing: 5,
            spacing: 8,
            children: snapshot.hasData ? snapshot.data : [],
          );
        });
  }

  _buildVotingComplete(bool _isByAnwseredAllQuestion) {
    _openVotingDeclareWebSocketChannel();

    return Container(
      child: Scaffold(
          appBar: AppBar(
            leading: BackButton(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 35, 20, 30),
              child: Column(
                children: <Widget>[
                  Text(
                      _isByAnwseredAllQuestion
                          ? 'Đã kết thúc'
                          : widget.groupId == 0
                              ? 'Đã kết thúc bởi chủ trì'
                              : 'Đã kết thúc bởi chủ trì',
                      style: TextStyle(
                          fontSize: 26,
                          color: Color.fromARGB(255, 38, 61, 117),
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 10,
                  ),
                  Image(
                    image: AssetImage('lib/assets/images/voting-completed.gif'),
                    width: 200,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Vui lòng đợi trong giây lát',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15),
                        side: BorderSide(color: Colors.green)),
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text('Xem kết quả', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      _transferToResultPage();
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }

  _transferToResultPage() {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        Future<TResult> _futureRes = widget.votingBloc.checkDeclareVoting();
        _futureRes.then((res) {
          if (res.status == 1) {
            if (widget.groupId == 0) {
              // open result BQ page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PageVotingDetailResultBQ(votingBloc: widget.votingBloc),
                  ));
            } else if (widget.groupId == 1) {
              // open result BC page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PageVotingDetailResultBC(votingBloc: widget.votingBloc),
                  ));
            }
          } else {
            showToast(res.msg);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_channelVotingDeclare != null) {
      _channelVotingDeclare.sink.close();
    }

    if (_channelVotingEnd != null) {
      _channelVotingEnd.sink.close();
    }
  }
}
