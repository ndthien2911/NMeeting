import 'package:cached_network_image/cached_network_image.dart';
import 'package:nmeeting/bloc/votingBloc.dart';
import 'package:nmeeting/models/voting.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/material.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;

class PageVotingDetailResultBC extends StatefulWidget {
  final VotingBloc votingBloc;

  const PageVotingDetailResultBC({Key key, @required this.votingBloc})
      : super(key: key);

  @override
  _PageVotingDetailResultBCState createState() =>
      _PageVotingDetailResultBCState();
}

class _PageVotingDetailResultBCState extends State<PageVotingDetailResultBC> {
  final _pageViewcontroller = new PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _initValue();
  }

  _initValue() async {
    await widget.votingBloc.getBCResultByProblemId();
    widget.votingBloc.onSetbcQuestionName(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Container(
          //color: Color.fromARGB(255, 218, 37, 29),
          child: Column(
            children: <Widget>[
              Container(
                //color: Color.fromARGB(255, 218, 37, 29),
                padding: EdgeInsets.fromLTRB(20, 45, 20, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Image(
                    //   image: AssetImage('lib/assets/images/communist-flag.png'),
                    //   width: 50,
                    //   height: 50,
                    //   fit: BoxFit.cover,
                    // ),
                    
                    Flexible(
                      child: StreamBuilder<String>(
                          stream: widget.votingBloc.bcQuestionNameStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                // 'KẾT QUẢ ' + snapshot.data.toUpperCase(),
                                'Kết quả của ' + snapshot.data.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              );
                            }
                            return Center(child: CircularProgressIndicator());
                          }),
                    ),
                    // Image(
                    //   image: AssetImage('lib/assets/images/vietnam-flag.png'),
                    //   width: 65,
                    //   height: 65,
                    //   fit: BoxFit.cover,
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<BCResultOutput>>(
                    stream: widget.votingBloc.bcResultListStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: <Widget>[
                            Material(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                                  child: _generateIndicator(),
                                )),
                            Expanded(
                              child: Container(
                                // decoration: BoxDecoration(
                                //     gradient: LinearGradient(
                                //         begin: Alignment.topLeft,
                                //         end: Alignment.bottomRight,
                                //         stops: [
                                //       0.5,
                                //       0.5
                                //     ],
                                //         colors: [
                                //       Color.fromARGB(255, 218, 37, 29),
                                //       Colors.white
                                //     ])),
                                child: PageView.builder(
                                  onPageChanged: (_pageIndex) {
                                    widget.votingBloc
                                        .onSetbcQuestionName(_pageIndex);
                                    widget.votingBloc
                                        .onChangedPageView(_pageIndex);
                                  },
                                  controller: _pageViewcontroller,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    var resultItem = snapshot.data[index];
                                    return Column(children: <Widget>[
                                      Expanded(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: <Widget>[
                                            Wrap(
                                              children: _buildList(
                                                  resultItem.accounts),
                                            ),
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  100, 10, 100, 10),
                                              child: RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    side: BorderSide(
                                                        color: Colors.grey)),
                                                color: Colors.grey,
                                                textColor: Colors.white,
                                                child: Text('Trở lại',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]);
                                  },
                                ),
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
            children: snapshot.hasData ? snapshot.data : [],
          );
        });
  }

  List<Widget> _buildList(data) {
    List<Widget> lines = [];
    for (var item in data) {
      lines.add(
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          height: 220,
          child: Container(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Container(
                child: Material(
                  color: Colors.green[50],
                  elevation: 2,
                  shadowColor: Color(0x802196F3),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: !StringUtils.isNullOrEmpty(item.avatarUrl)
                              ? CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  errorWidget: (context, url, error) => Icon(
                                        Icons.error_outline,
                                        size: 80,
                                      ),
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  imageUrl: '${api.BASE_URL}${item.avatarUrl}')
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundImage: AssetImage(
                                      'lib/assets/images/no-avatar.png')),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Flexible(
                          child: Center(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Flexible(
                          child: Center(
                            child: Text(
                              StringUtils.isNullOrEmpty(item.position)
                                  ? ''
                                  : item.position,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return lines;
  }
}
