import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nmeeting/bloc/eventBloc.dart';
import 'package:nmeeting/models/event.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:nmeeting/configs/constants.dart' as constants;
import 'package:oktoast/oktoast.dart';

class PageTagEvent extends StatefulWidget {
  final EventBloc eventBloc;
  final String tagID;
  PageTagEvent({Key? key, required this.tagID, required this.eventBloc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageTagEventState();
}

class _PageTagEventState extends State<PageTagEvent> {
  String resultRespond = constants.STATUS_ERROR;
  int actionFlg = constants.ACTION_CREATE;
  List<EventTag> listTag = [];
  String? tagIDSelected;

  @override
  void initState() {
    super.initState();

    if (!StringUtils.isNullOrEmpty(widget.tagID)) {
      initValue(widget.tagID);
      setState(() =>
          {actionFlg = constants.ACTION_EDIT, tagIDSelected = widget.tagID});
    } else {
      widget.eventBloc.getListTags();
      setState(() => {tagIDSelected = widget.eventBloc.onGetEventTagIDInput()});
    }
  }

  initValue(String id) async {
    widget.eventBloc.getListTags();
  }

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    return Scaffold(
        body: Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      alignment: Alignment.topCenter,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(0),
                alignment: Alignment.topCenter,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 122, 122, 122),
                          border: Border.all()),
                      height: 50,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.arrow_back_ios,
                                color: Color.fromARGB(255, 151, 151, 151)),
                          ),
                          Text(
                            'Nhãn',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (tagIDSelected == null) {
                                showToast("Vui lòng chọn 1 nhãn");
                              } else {
                                widget.eventBloc
                                    .onSetEventTagIDInput(tagIDSelected!);
                                String reSultTagNm = "";
                                for (var i = 0; i < listTag.length; i++) {
                                  if (listTag[i].id == tagIDSelected) {
                                    reSultTagNm = listTag[i].name;
                                  }
                                }
                                Navigator.pop(context, reSultTagNm);
                              }
                            },
                            child: Text(
                              'Hoàn tất',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 30, 37, 239),
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            Container(
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.all(0),
              child: StreamBuilder<List<EventTag>>(
                  stream: widget.eventBloc.eventTagListStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false ||
                        snapshot.data == null ||
                        snapshot.data!.length == 0) {
                      return _nodata();
                    }
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        listTag = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: listTag.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 10, 20, 10),
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border(
                                            //top: BorderSide(width: 1.0, color: Color.fromARGB(255, 187, 187, 187)),
                                            bottom: BorderSide(
                                                width: 1.0,
                                                color: Color.fromARGB(
                                                    255, 187, 187, 187)),
                                          )),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                              flex: 9,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      '${listTag[index].id}',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 0, 0, 0),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 50),
                                                    Text(
                                                      '${listTag[index].name}',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 0, 0, 0),
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ])),
                                          if (listTag[index].id ==
                                              this.tagIDSelected)
                                            Container(
                                                child: Icon(
                                              Icons.check,
                                              color: Color.fromARGB(
                                                  255, 30, 37, 239),
                                              size: 15,
                                            )),
                                        ],
                                      ))
                                ],
                              ),
                              onTap: () async {
                                setState(
                                    () => {tagIDSelected = listTag[index].id});
                              },
                            );
                          },
                        );
                      }
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            )
          ],
        ),
      ),
    ));
  }
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
          'Không có dữ liệu',
          style:
              TextStyle(fontSize: 20, color: Color.fromARGB(255, 184, 134, 11)),
        ),
      ],
    ),
  );
}
