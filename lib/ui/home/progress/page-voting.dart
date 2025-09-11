import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nmeeting/bloc/votingBloc.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/models/voting.dart';
import 'package:nmeeting/ui/home/progress/page-voting-detail-result-BC.dart';
import 'package:nmeeting/ui/home/progress/page-voting-detail-result-BQ.dart';
import 'package:nmeeting/ui/home/progress/page-voting-detail.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:oktoast/oktoast.dart';
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:web_socket_channel/io.dart';

class PageVoting extends StatefulWidget {
  final VotingBloc votingBloc;
  const PageVoting({Key key, @required this.votingBloc}) : super(key: key);
  @override
  _PageVotingState createState() => _PageVotingState();
}

class _PageVotingState extends State<PageVoting> {
  IOWebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _initValue();
  }

  _initValue() async {
    this._getProlems();
    _openProgressWebSocketChannel();
  }

  _openProgressWebSocketChannel() async {
    _channel = await widget.votingBloc.openProgressWebSocketChannel();
    _listenProgressWebSocketChannel();
  }

  _reopenProgressWebSocketChannel() async {
    _channel = await widget.votingBloc.openProgressWebSocketChannel();
    _listenProgressWebSocketChannel();
  }

  _listenProgressWebSocketChannel() {
    _channel.stream.listen((message) {
      NetworkCheck _networkCheck = NetworkCheck();
      _networkCheck.check().then((isConnected) {
        if (isConnected) {
          this._getProlems();
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
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(
          'Biểu quyết',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        child: StreamBuilder<List<ProblemOutput>>(
            stream: widget.votingBloc.problemListStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return _nodata();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    var _problemIndexText = snapshot.data[index].problemIndex;
                    return GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: Container(
                          child: Material(
                            color: Colors.white,
                            elevation: 4,
                            borderRadius: BorderRadius.circular(5),
                            shadowColor: Color(0x802196F3),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Text(
                                          _problemIndexText,
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (snapshot.data[index].endFlg)
                                        Stack(
                                          children: <Widget>[
                                            Container(
                                              width: 60,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(0)),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 3, left: 10),
                                              child: Text(
                                                'Đã xong',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 15, top: 5),
                                    child: Text(
                                      snapshot.data[index].name,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        // set groupId, number selection, problem Id, name, index
                        widget.votingBloc
                            .onSetGroupId(snapshot.data[index].groupID);
                        widget.votingBloc
                            .onSetProlemId(snapshot.data[index].id);
                        widget.votingBloc
                            .onSetProlemName(snapshot.data[index].name);
                        widget.votingBloc.onSetProlemIndex(_problemIndexText);

                        // biểu quyết
                        if (snapshot.data[index].groupID == 0) {
                          // if declare, transfer result page
                          Future<TResult> _futureRes =
                              widget.votingBloc.checkDeclareVoting();
                          _futureRes.then((res) async {
                            if (res.status == 1) {
                              // open result page
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PageVotingDetailResultBQ(
                                            votingBloc: widget.votingBloc),
                                  ));
                              this._getProlems();
                            } else {
                              this._openVotingDetail(
                                  snapshot.data[index].groupID,
                                  snapshot.data[index].id,
                                  snapshot.data[index].name,
                                  _problemIndexText);
                            }
                          });
                          // bầu cử
                        } else if (snapshot.data[index].groupID == 1) {
                          // if declare, transfer result page
                          Future<TResult> _futureRes =
                              widget.votingBloc.checkDeclareVoting();
                          _futureRes.then((res) async {
                            if (res.status == 1) {
                              // open result page //bầu cử
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PageVotingDetailResultBC(
                                            votingBloc: widget.votingBloc),
                                  ));
                              this._getProlems();
                            } else {
                              this._openVotingDetail(
                                  snapshot.data[index].groupID,
                                  snapshot.data[index].id,
                                  snapshot.data[index].name,
                                  _problemIndexText);
                            }
                          });
                        }
                      },
                    );
                  },
                );
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }

  _openVotingDetail(
      int _groupId, String _problemId, String _problemName, String _indexText) {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        // check voting is start by admin
        Future<TResult> _futureRes = widget.votingBloc.checkAllowVoting();
        _futureRes.then((res) async {
          if (res.status == 1) {
            // open detail page
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageVotingDetail(
                    votingBloc: widget.votingBloc,
                    groupId: _groupId,
                  ),
                ));
            this._getProlems();
          } else {
            showToast(res.msg);
          }
        });
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  _getProlems() {
    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        widget.votingBloc.getProblems();
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  Widget _nodata() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            'No information',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_channel != null) {
      _channel.sink.close();
    }
  }
}
