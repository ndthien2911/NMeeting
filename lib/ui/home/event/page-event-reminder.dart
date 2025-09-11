import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nmeeting/bloc/eventBloc.dart';
import 'package:nmeeting/models/event.dart';
import 'package:nmeeting/configs/constants.dart' as constants;

class PageReminderEvent extends StatefulWidget {
  final EventBloc eventBloc;
  final int? reminderID;
  PageReminderEvent({Key? key, this.reminderID, required this.eventBloc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageReminderEventState();
}

class _PageReminderEventState extends State<PageReminderEvent> {
  String resultRespond = constants.STATUS_ERROR;
  int actionFlg = constants.ACTION_CREATE;
  late List<EventReminder> listReminder;
  int? reminderSelected;

  @override
  void initState() {
    super.initState();

    if (widget.reminderID != null) {
      initValue(widget.reminderID.toString());
      setState(() => {
            actionFlg = constants.ACTION_EDIT,
            reminderSelected = widget.reminderID!
          });
    } else {
      widget.eventBloc.getListReminders();
      setState(() =>
          {reminderSelected = widget.eventBloc.onGetEventReminderInput()});
    }
  }

  initValue(String id) async {
    widget.eventBloc.getListReminders();
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
                            'Nhắc hẹn',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (reminderSelected == null) {
                                Navigator.of(context).pop();
                              } else {
                                int reSultReminderVal = 0;
                                for (var i = 0; i < listReminder.length; i++) {
                                  if (listReminder[i].id == reminderSelected) {
                                    widget.eventBloc.onSetEventReminderInput(
                                        listReminder[i].id);
                                    reSultReminderVal = listReminder[i].value;
                                  }
                                }
                                Navigator.pop(context, reSultReminderVal);
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
              child: StreamBuilder<List<EventReminder>>(
                  stream: widget.eventBloc.eventReminderListStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false ||
                        snapshot.data!.length == 0) {
                      return _nodata();
                    }
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        listReminder = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: listReminder.length,
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
                                                    Icon(Icons.access_time,
                                                        color: Color.fromARGB(
                                                            255, 0, 0, 0)),
                                                    SizedBox(width: 20),
                                                    Text(
                                                      "${listReminder[index].value} phút",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 0, 0, 0),
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ])),
                                          if (listReminder[index].id ==
                                              this.reminderSelected)
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
                                setState(() => {
                                      reminderSelected = listReminder[index].id
                                    });
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
