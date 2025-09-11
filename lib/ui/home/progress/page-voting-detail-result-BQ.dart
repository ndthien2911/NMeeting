import 'package:nmeeting/bloc/votingBloc.dart';
import 'package:nmeeting/models/voting.dart';
import 'package:flutter/material.dart';

class PageVotingDetailResultBQ extends StatefulWidget {
  final VotingBloc votingBloc;

  const PageVotingDetailResultBQ({Key? key, required this.votingBloc})
      : super(key: key);

  @override
  _PageVotingDetailResultBQState createState() =>
      _PageVotingDetailResultBQState();
}

class _PageVotingDetailResultBQState extends State<PageVotingDetailResultBQ> {
  final _pageViewcontroller = new PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _initValue();
  }

  _initValue() async {
    widget.votingBloc.getBQResultByProblemId();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.black),
          title: StreamBuilder<String>(
              stream: widget.votingBloc.problemIndexStream,
              builder: (context, snapshot) {
                final text = snapshot.data ?? '';
                return Text(
                  text,
                  style: const TextStyle(color: Colors.black),
                );
              }),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: StreamBuilder<String>(
                    stream: widget.votingBloc.problemNameStream,
                    builder: (context, snapshot) {
                      return Text(
                        (snapshot.hasData && snapshot.data != null)
                            ? snapshot.data!.toUpperCase()
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
                child: StreamBuilder<QuestionFinalResultOutput>(
                    stream: widget.votingBloc.questionResultStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Column(
                          children: <Widget>[
                            _generateIndicator(),
                            SizedBox(height: 5),
                            Expanded(
                              child: PageView.builder(
                                onPageChanged: (_pageIndex) {
                                  widget.votingBloc
                                      .onChangedPageView(_pageIndex);
                                },
                                controller: _pageViewcontroller,
                                itemCount:
                                    snapshot.data!.questionResults.length,
                                itemBuilder: (context, index) {
                                  var questionResultItem =
                                      snapshot.data!.questionResults[index];
                                  var totalUserJoin =
                                      snapshot.data!.totalUserJoin;
                                  return Column(children: <Widget>[
                                    Text(
                                      questionResultItem.questionName,
                                      style: TextStyle(
                                          fontSize: 22,
                                          color:
                                              Color.fromARGB(255, 38, 61, 117),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    StreamBuilder<int>(
                                        stream: widget.votingBloc.groupIdStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            // biểu quyết
                                            if (snapshot.data == 0) {
                                              return Expanded(
                                                child: _generateAnswersGr0(
                                                    questionResultItem
                                                        .questionID,
                                                    questionResultItem.answers,
                                                    questionResultItem.total,
                                                    totalUserJoin),
                                              );
                                            }
                                          }
                                          return Expanded(
                                            child: _generateAnswersGr1(
                                                questionResultItem.questionID,
                                                questionResultItem.answers,
                                                questionResultItem.total,
                                                totalUserJoin),
                                          );
                                        }),
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

  _generateIndicator() {
    return StreamBuilder<List<Widget>>(
      stream: widget.votingBloc.indicatorListStream,
      builder: (context, snapshot) {
        return Wrap(
          runSpacing: 5,
          spacing: 8,
          children: snapshot.data ?? [],
        );
      },
    );
  }

  _generateAnswersGr0(String _questionId, List<AnswerResult> _answers,
      int _totalAnwserd, int _totalUserJoin) {
    return ListView.builder(
        itemCount: _answers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              child: Material(
                color: Colors.white,
                elevation: 1,
                shadowColor: Color(0x802196F3),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        children: <Widget>[
                          Text(
                            _answers[index].name,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(children: <TextSpan>[
                              TextSpan(
                                // text: 'Số người bầu chọn: ',
                                text: 'Số người bầu chọn: ',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              TextSpan(
                                  text:
                                      '${_answers[index].numberChosen}/$_totalUserJoin',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 38, 61, 117),
                                      fontWeight: FontWeight.bold)),
                            ]),
                          ),
                          Text.rich(
                            TextSpan(children: <TextSpan>[
                              TextSpan(
                                // text: 'Tỉ lệ: ',
                                text: 'Tỉ lệ: ',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              TextSpan(
                                  text:
                                      '${((_answers[index].numberChosen * 100) / _totalUserJoin).toStringAsFixed(2)}%',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 38, 61, 117),
                                      fontWeight: FontWeight.bold)),
                            ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  _generateAnswersGr1(String _questionId, List<AnswerResult> _answers,
      int _totalAnwserd, int _totalUserJoin) {
    int originalLength = _answers.length;
    int summaryLength = originalLength + 4;
    return ListView.builder(
        itemCount: summaryLength,
        itemBuilder: (context, index) {
          if (index < originalLength) {
            return Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                child: Material(
                  color: Colors.white,
                  elevation: 1,
                  shadowColor: Color(0x802196F3),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Wrap(
                          children: <Widget>[
                            Text(
                              _answers[index].name,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text.rich(
                              TextSpan(children: <TextSpan>[
                                TextSpan(
                                  // text: 'Số phiếu bầu chọn: ',
                                  text: 'Số phiếu bầu chọn: ',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                TextSpan(
                                    text:
                                        '${_answers[index].numberChosen}/$_totalUserJoin',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 38, 61, 117),
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                            Text.rich(
                              TextSpan(children: <TextSpan>[
                                TextSpan(
                                  // text: 'Tỉ lệ: ',
                                  text: 'Tỉ lệ: ',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                TextSpan(
                                    text:
                                        '${((_answers[index].numberChosen * 100) / _totalUserJoin).toStringAsFixed(2)}%',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 38, 61, 117),
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // summary
          if (_summaryIndex > 3) {
            _summaryIndex = 0;
          }
          return _generateSummary(_totalUserJoin, _totalAnwserd);
        });
  }

  int _summaryIndex = 0;
  _generateSummary(int _totalUserJoin, int _totalAnwserd) {
    Widget _summaryItem = Padding(
      padding: _summaryIndex == 0
          ? const EdgeInsets.fromLTRB(1, 20, 1, 1)
          : const EdgeInsets.all(1),
      child: Container(
        child: Material(
          color: Colors.white,
          elevation: 1,
          shadowColor: Color(0x802196F3),
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _genarateSummaryDetail(
                      _summaryIndex, _totalUserJoin, _totalAnwserd),
                )
              ],
            ),
          ),
        ),
      ),
    );

    _summaryIndex++;

    return _summaryItem;
  }

  _genarateSummaryDetail(int _index, int _totalUserJoin, int _totalAnwserd) {
    switch (_index) {
      case 0:
        return [
          Text(
            // 'Tổng số phiếu phát ra: ',
            'Tổng số phiếu phát ra: ',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            // '$_totalUserJoin phiếu',
            '$_totalUserJoin votes',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ];
      case 1:
        return [
          Text(
            // 'Tổng số phiếu thu vào: ',
            'Tổng số phiếu thu vào: ',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            // '$_totalAnwserd phiếu',
            '$_totalAnwserd phiếu',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ];
      case 2:
        return [
          Text(
            'Số phiếu hợp lệ: ',
            // 'Number of valid votes: ',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            '$_totalAnwserd phiếu',
            // '$_totalAnwserd votes',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ];
      case 3:
        return [
          Text(
            'Số phiếu không hợp lệ: ',
            // 'Number of invalid votes: ',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            '${_totalUserJoin - _totalAnwserd} phiếu',
            // '${_totalUserJoin - _totalAnwserd} votes',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ];
      default:
    }
  }
}
