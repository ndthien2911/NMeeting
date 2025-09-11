import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';
import 'package:nmeeting/bloc/eventBloc.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/bloc/notifyBloc.dart';
import 'package:nmeeting/models/calendar.dart';
import 'package:nmeeting/models/event.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/ui/home/event/page-event-reminder.dart';
import 'package:nmeeting/ui/home/event/page-event-tags.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:nmeeting/configs/constants.dart' as constants;
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class PageCreateEvent extends StatefulWidget {
  final MeetingBloc meetingBloc;
  final String? eventId;
  PageCreateEvent({Key? key, this.eventId, required this.meetingBloc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageCreateEventState();
}

class _PageCreateEventState extends State<PageCreateEvent> {
  final _bloc = EventBloc();
  final _notifyBloc = NotifyBloc();
  late IOWebSocketChannel _notifyChannel;

  late String _eventDateToServer;
  final _eventNameInputController = TextEditingController();
  final _eventDateInputController = TextEditingController();
  final _eventDateStartInputController = TextEditingController();
  final _eventDateEndInputController = TextEditingController();
  final _eventTimerInputController = TextEditingController();
  final _eventTagsInputController = TextEditingController();

  DateTime eventDt = DateTime.now();
  DateTime? startDt = null;
  DateTime? endDt = null;
  int reminderVal = 0;

  String resultRespond = constants.STATUS_ERROR;
  int actionFlg = constants.ACTION_CREATE;

  @override
  void initState() {
    super.initState();
    _bloc.getTimeline('');

    if (!StringUtils.isNullOrEmpty(widget.eventId)) {
      setState(() => actionFlg = constants.ACTION_EDIT);
      initValue(widget.eventId ?? '');
    } else {
      _eventDateInputController.text =
          DateFormat(constants.DATE_FORMAT_CLIENT).format(eventDt);
      _eventDateToServer =
          DateFormat(constants.DATE_FORMAT_SERVER).format(eventDt).toString();
      _eventTagsInputController.text = 'Chọn nhãn';
      _bloc.onSetEventTagIDInput('N');
      _bloc.getTimeline(_eventDateToServer);
    }

    _openNotifyWebSocketChannel();
  }

  @override
  void dispose() {
    super.dispose();
    if (_notifyChannel != null) {
      _notifyChannel.sink.close();
    }
  }

  initValue(String id) async {
    //get event detail info
    Future<TResult> _resultFuture = _bloc.getEventDetail(id);
    _resultFuture.then((res) async {
      if (res.status == 1) {
        EventObj _eventObj = res.data;
        _eventNameInputController.text = _eventObj.name;
        _eventDateInputController.text = StringUtils.convertTimeFromString(
            _eventObj.eventDate, constants.DATE_FORMAT_DATE_TYPE_1);
        _eventDateToServer = _eventObj.eventDate;
        _eventDateStartInputController.text = StringUtils.convertTimeFromString(
            _eventObj.startAt, constants.DATE_FORMAT_TIME_TYPE_1);
        _eventDateEndInputController.text = StringUtils.convertTimeFromString(
            _eventObj.endAt, constants.DATE_FORMAT_TIME_TYPE_1);
        _eventTimerInputController.text = (_eventObj.reminderVal != 0)
            ? "Nhắc trước ${_eventObj.reminderVal} phút"
            : "";
        _eventTagsInputController.text = _eventObj.tagNm ?? '';

        _bloc.onSetEventReminderInput(_eventObj.reminderID);
        _bloc.onSetEventTagIDInput(_eventObj.tagID!);

        setState(() {
          eventDt = DateTime.parse(_eventObj.eventDate);
          startDt = DateTime.parse(_eventObj.startAt);
          endDt = DateTime.parse(_eventObj.endAt);
        });

        _bloc.getTimeline(_eventObj.eventDate);
      }
    });
  }

  _openNotifyWebSocketChannel() async {
    _notifyChannel = await _notifyBloc.openNotifyWebSocketChannel();
  }

  _removeReminder(String reminder) {
    if (reminder == "") {
      _setReminder();
    } else {
      _bloc.onSetEventReminderInput(null);
      setState(() {
        _eventTimerInputController.text = "";
        reminderVal = 0;
      });
    }
  }

  _setReminder() {
    Future<dynamic> _resultFuture = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageReminderEvent(
          eventBloc: _bloc,
          reminderID: (actionFlg == constants.ACTION_EDIT)
              ? _bloc.onGetEventReminderInput()
              : null,
        ),
      ),
    );
    _resultFuture.then((res) async {
      if (res != null) {
        if (res != "" && res != null && res != 0) {
          setState(() {
            reminderVal = res;
            _eventTimerInputController.text =
                "Alert ${res.toString()} minutes before";
          });
          //add new reminder
          if (reminderVal != 0) {
            DateTime eventDtRe = (startDt != null) ? startDt! : DateTime.now();
            DateTime startAtRe = (startDt != null) ? startDt! : DateTime.now();
            String name = (_bloc.onGetEventNameInput() != null)
                ? _bloc.onGetEventNameInput()
                : "Meeting schedule";
            _addEventToCalendar(eventDtRe, startAtRe, reminderVal, name, name);
          }
        }
      }
    });
  }

  _confirmEvent(int actionFlg) {
    if (StringUtils.isNullOrEmpty(_eventNameInputController.text)) {
      showToast("Nội dung không được để trống!");
    } else if (StringUtils.isNullOrEmpty(_eventDateInputController.text)) {
      showToast("Ngày diễn ra không được để trống!");
    } else if (StringUtils.isNullOrEmpty(_eventDateStartInputController.text)) {
      showToast("Thời gian bắt đầu không được để trống!!");
    } else if (StringUtils.isNullOrEmpty(_eventDateEndInputController.text)) {
      showToast("Thời gian kết thúc không được để trống!!");
    } else if (startDt!.isAfter(endDt!) ||
        _eventDateStartInputController.text ==
            _eventDateEndInputController.text) {
      showToast("Thời gian bắt đầu sau thời gian kết thúc!");
    } else if (StringUtils.isNullOrEmpty(_eventTagsInputController.text)) {
      showToast("Nhãn không được để trống!");
    } else {
      _submitEvent(actionFlg);
      // Future<List<EventByDayOutput>> _resultFuture =
      //     _bloc.getTimeline(_eventDateToServer);
      // _resultFuture.then((res) async {
      //   if (res != null && res.length > 0) {
      //     bool flg = _checkDuplicateEvent(res, startDt, endDt, widget.eventId);
      //     if (flg == true) {
      //       return showDialog(
      //           context: context,
      //           builder: (BuildContext context) {
      //             return VNPTDialog(
      //               type: VNPTDialogType.normal,
      //               title: 'Trùng thời gian',
      //               description:
      //                   'Lịch cá nhân của bạn bị trùng thời gian với lịch khác. Bạn có muốn tiếp tục tạo lịch này không?',
      //               actions: <Widget>[
      //                 ButtonTheme(
      //                   minWidth: 65,
      //                   height: 40,
      //                   child: RaisedButton(
      //                     shape: new RoundedRectangleBorder(
      //                         borderRadius: new BorderRadius.circular(20),
      //                         side: BorderSide(
      //                           color: Color.fromARGB(255, 0, 0, 128),
      //                         )),
      //                     color: Colors.white,
      //                     textColor: Color.fromARGB(255, 0, 0, 128),
      //                     child: Text("Đóng",
      //                         style: TextStyle(
      //                             fontSize: 17, fontWeight: FontWeight.bold)),
      //                     onPressed: () {
      //                       Navigator.of(context).pop();
      //                     },
      //                   ),
      //                 ),
      //                 ButtonTheme(
      //                   minWidth: 65,
      //                   height: 40,
      //                   child: RaisedButton(
      //                     shape: new RoundedRectangleBorder(
      //                         borderRadius: new BorderRadius.circular(20),
      //                         side: BorderSide(
      //                           color: Color.fromARGB(255, 0, 108, 183),
      //                         )),
      //                     color: Color.fromARGB(255, 0, 108, 183),
      //                     textColor: Colors.white,
      //                     child: Text("Xác nhận",
      //                         style: TextStyle(
      //                             fontSize: 17, fontWeight: FontWeight.bold)),
      //                     onPressed: () {
      //                       _submitEvent(actionFlg);
      //                       Navigator.of(context).pop();
      //                     },
      //                   ),
      //                 )
      //               ],
      //             );
      //           });
      //     } else {
      //       _submitEvent(actionFlg);
      //     }
      //   } else {
      //     _submitEvent(actionFlg);
      //   }
      // });
    }
  }

  confirmDeleteEvent(String id) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return VNPTDialog(
          type: VNPTDialogType.normal,
          title: 'Xoá lịch cá nhân',
          description: 'Bạn có chắc chắn muốn xoá sự kiện này không?',
          actions: <Widget>[
            SizedBox(
              width: 65,
              height: 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: const BorderSide(color: Color.fromARGB(255, 0, 0, 128)),
                  foregroundColor: Color.fromARGB(255, 0, 0, 128),
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Huỷ"),
              ),
            ),
            SizedBox(
              width: 65,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Color.fromARGB(255, 0, 108, 183),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  _deleteEvent(id);
                  Navigator.of(context).pop();
                },
                child: const Text("Xoá"),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _checkDuplicateEvent(List<EventByDayOutput> list, DateTime startAt,
      DateTime endAt, String id) {
    bool isFlagDup = false;
    for (var i = 0; i < list.length; i++) {
      if (!StringUtils.isNullOrEmpty(list[i].from) &&
          !StringUtils.isNullOrEmpty(list[i].to)) {
        DateTime fromAt = DateTime.parse(list[i].from!);
        DateTime toAt = DateTime.parse(list[i].to!);
        if (((fromAt.isBefore(startAt) && startAt.isBefore(toAt)) ||
                (fromAt.isBefore(endAt) && endAt.isBefore(toAt))) &&
            (id.toString() == "" || list[i].id != id.toString())) {
          isFlagDup = true;
          break;
        }
      } else if (!StringUtils.isNullOrEmpty(list[i].from)) {
        DateTime fromAt = DateTime.parse(list[i].from!);
        if (((fromAt == startAt) ||
                (fromAt.isBefore(endAt) && fromAt.isAfter(startAt))) &&
            (id.toString() == "" || list[i].id != id.toString())) {
          isFlagDup = true;
          break;
        }
      }
    }

    return isFlagDup;
  }

  _submitEvent(int actionFlg) async {
    Future<TResult> _resultFuture;
    EventObj dataReq = EventObj(
      id: '', // tạm thời gán rỗng, sẽ cập nhật khi edit
      name: '',
      admin: '',
      eventDate: '',
      startAt: '',
      endAt: '',
      type: constants.CALENDAR_TYPE_PERSONAL,
    );

    // sau đó gán từng giá trị
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dataReq.name = _eventNameInputController.text;
    dataReq.admin = prefs.getString('personalID') ?? '';
    dataReq.eventDate = _eventDateToServer;
    dataReq.startAt = _eventDateStartInputController.text;
    dataReq.endAt = _eventDateEndInputController.text;
    dataReq.reminderID = _bloc.onGetEventReminderInput()!;
    dataReq.tagID = _bloc.onGetEventTagIDInput();

    if (actionFlg == constants.ACTION_EDIT) {
      String id = widget.eventId ?? '';
      dataReq.id = id;
      _resultFuture = _bloc.updateEvent(dataReq);
    } else {
      _resultFuture = _bloc.createEvent(dataReq);
    }

    _resultFuture.then((res) async {
      int type = res.status;
      String mes = res.msg;
      setState(() => resultRespond =
          (type == 1) ? constants.STATUS_SUCCESS : constants.STATUS_ERROR);
      String actionStr = (actionFlg == constants.ACTION_EDIT)
          ? 'Lịch cá nhân đã được cập nhật thành công!'
          : 'Lịch cá nhân đã được tạo thành công!';

      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: (type == 1) ? VNPTDialogType.success : VNPTDialogType.warning,
            title: (type == 1) ? "Thành công" : "Cảnh báo",
            description: (type == 1) ? actionStr : mes,
            actions: <Widget>[
              SizedBox(
                width: 134,
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (resultRespond == constants.STATUS_SUCCESS) {
                      // send notify
                      EventObj _data = res.data;
                      List<String> listEventID = [];
                      listEventID.add(_data.id);
                      Future<TResult> _notifyFu =
                          _notifyBloc.getUsersByMeetingIDs(listEventID);
                      _notifyFu.then((res) {
                        if (res.status == 1) {
                          _notifyChannel.sink.add(res.data);
                        }
                      });

                      Navigator.pop(context, resultRespond);
                    }
                  },
                  child: const Text(
                    "Đồng ý",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  _deleteEvent(String id) async {
    Future<String> _resultFuture = _bloc.deleteItem(id);
    _resultFuture.then((res) async {
      if (res == constants.STATUS_SUCCESS) {
        Navigator.pop(context, res);
      } else {
        showToast(res);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            // ListView contains a group of widgets that scroll inside the drawer
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
                              color: Color.fromARGB(255, 122, 122, 122)),
                          height: 50,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30),
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
                                  child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20))),
                                      alignment: new FractionalOffset(1.0, 0.0),
                                      child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(20, 5, 20, 5),
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 241, 243, 244),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                          child: new Text(
                                            'Hủy',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal),
                                          )))),
                              Text(
                                (actionFlg == constants.ACTION_EDIT)
                                    ? 'Kế hoạch cá nhân'
                                    : 'Kế hoạch cá nhân',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    _confirmEvent(actionFlg);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20))),
                                    alignment: new FractionalOffset(1.0, 0.0),
                                    child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 5, 20, 5),
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 52, 168, 83),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        child: new Text('Lưu',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.normal))),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    )),

                StreamBuilder<String>(
                    stream: _bloc.eventNameInputStream,
                    builder: (context, snapshot) {
                      return Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 99, 204, 127),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: TextField(
                            maxLines: 8,
                            minLines: 1,
                            keyboardType: TextInputType.text,
                            style: TextStyle(fontSize: 17, color: Colors.white),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Nhập nội dung',
                              hintStyle: TextStyle(
                                  fontSize: 17, color: Colors.white54),
                              contentPadding: (!StringUtils.isNullOrEmpty(
                                      _eventNameInputController.text))
                                  ? EdgeInsets.only(top: 0)
                                  : EdgeInsets.only(top: 0),
                            ),
                            onChanged: (value) =>
                                _bloc.onChangedEventNameInput(value),
                            controller: _eventNameInputController,
                          ));
                    }),

                Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  // padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      // color: Colors.black54,
                      border: Border(
                          top: BorderSide(
                              color: Color.fromARGB(255, 241, 243, 244)),
                          bottom: BorderSide(
                              color: Color.fromARGB(255, 241, 243, 244)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Ngày',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          DateTime current = DateTime.now();
                          DateTime start = current.subtract(Duration(days: 1));
                          var res = showDatePicker(
                            context: context,
                            initialDate: current,
                            firstDate: start,
                            lastDate: DateTime(2200),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light(),
                                child: child!,
                              );
                            },
                          );

                          res.then((onValue) {
                            print(onValue);
                            if (onValue != null) {
                              // date display
                              setState(() {
                                eventDt = onValue;
                                _eventDateInputController.text =
                                    DateFormat(constants.DATE_FORMAT_CLIENT)
                                        .format(onValue);
                                _eventDateToServer =
                                    DateFormat(constants.DATE_FORMAT_SERVER)
                                        .format(onValue)
                                        .toString();
                              });
                              _bloc.getTimeline(onValue.toString());
                              _bloc.onChangedEventDateInput(onValue.toString());
                            }
                          });
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 0, 0, 0)),
                            decoration: InputDecoration(
                                // prefixIcon: Icon(Icons.calendar_today,
                                //     color: Color.fromARGB(255, 0, 0, 0)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                hintText: 'dd/MM/yyyy',
                                hintStyle: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 0, 0, 0)),
                            controller: _eventDateInputController,
                          ),
                        ),
                      ))
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  // padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      // color: Colors.black54,
                      border: Border(
                          bottom: BorderSide(
                              color: Color.fromARGB(255, 241, 243, 244)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Thời gian bắt đầu',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            DateTime currDt = DateTime.now();
                            DateTime defaultDt = DateTime(
                                eventDt.year,
                                eventDt.month,
                                eventDt.day,
                                currDt.hour,
                                currDt.minute);
                            if (startDt != null) {
                              defaultDt = defaultDt = DateTime(
                                  eventDt.year,
                                  eventDt.month,
                                  eventDt.day,
                                  startDt!.hour,
                                  startDt!.minute);
                            }
                            picker.DatePicker.showTimePicker(context,
                                theme: picker.DatePickerTheme(
                                  containerHeight: 250.0,
                                ),
                                showTitleActions: true, onConfirm: (time) {
                              setState(() {
                                startDt = time;
                                _eventDateStartInputController.text =
                                    StringUtils.convertFormatD2(
                                        time.hour, time.minute);
                              });

                              if (time.hour < 23) {
                                setState(() {
                                  endDt = new DateTime(time.year, time.month,
                                      time.day, time.hour + 1, time.minute);
                                  _eventDateEndInputController.text =
                                      StringUtils.convertFormatD2(
                                          endDt!.hour, endDt!.minute);
                                });
                              } else {
                                setState(() {
                                  endDt = new DateTime(
                                      time.year, time.month, time.day, 23, 59);
                                  _eventDateEndInputController.text =
                                      StringUtils.convertFormatD2(
                                          endDt!.hour, endDt!.minute);
                                });
                              }
                            },
                                showSecondsColumn: false,
                                currentTime: defaultDt,
                                locale: picker.LocaleType.en);
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 0, 0, 0)),
                              decoration: InputDecoration(
                                  // prefixIcon: Icon(Icons.access_time,
                                  //     color: Color.fromARGB(255, 0, 0, 0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent)),
                                  hintText: 'HH:mm',
                                  hintStyle: TextStyle(
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 0, 0, 0)),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 0, 0, 0)),
                              controller: _eventDateStartInputController,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  // padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      // color: Colors.black54,
                      border: Border(
                          bottom: BorderSide(
                              color: Color.fromARGB(255, 241, 243, 244)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Thời gian kết thúc',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            DateTime currDt = DateTime.now();
                            DateTime defaultDt = DateTime(
                                eventDt.year,
                                eventDt.month,
                                eventDt.day,
                                currDt.hour,
                                currDt.minute);
                            if (endDt != null) {
                              defaultDt = DateTime(eventDt.year, eventDt.month,
                                  eventDt.day, endDt!.hour, endDt!.minute);
                            }
                            picker.DatePicker.showTimePicker(context,
                                theme: picker.DatePickerTheme(
                                  containerHeight: 250.0,
                                ),
                                showTitleActions: true, onConfirm: (time) {
                              setState(() {
                                endDt = time;
                                _eventDateEndInputController.text =
                                    StringUtils.convertFormatD2(
                                        time.hour, time.minute);
                              });
                            },
                                showSecondsColumn: false,
                                currentTime: defaultDt,
                                locale: picker.LocaleType.en);
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 0, 0, 0)),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent)),
                                  hintText: 'HH:mm',
                                  hintStyle: TextStyle(
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 0, 0, 0)),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 0, 0, 0)),
                              controller: _eventDateEndInputController,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // Container(
                //   padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                //   alignment: Alignment.center,
                //   decoration: BoxDecoration(
                //       color: Colors.white,
                //       border: Border(
                //         bottom: BorderSide(
                //             width: 1.0,
                //             color: Color.fromARGB(255, 187, 187, 187)),
                //       )),
                //   height: 50,
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: <Widget>[
                //       Expanded(
                //         flex: 10,
                //         child: Row(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                //           children: <Widget>[
                //             GestureDetector(
                //               onTap: () {
                //                 _setReminder();
                //               },
                //               child: Container(
                //                   width: MediaQuery.of(context).size.width - 75,
                //                   child: AbsorbPointer(
                //                     child: TextField(
                //                       style: TextStyle(
                //                           fontSize: 17,
                //                           color: Color.fromARGB(255, 0, 0, 0)),
                //                       decoration: InputDecoration(
                //                           prefixIcon: Icon(Icons.notifications,
                //                               color:
                //                                   Color.fromARGB(255, 0, 0, 0)),
                //                           enabledBorder: OutlineInputBorder(
                //                               borderSide: BorderSide(
                //                                   color: Colors.transparent)),
                //                           hintText: 'Nhắc hẹn',
                //                           hintStyle: TextStyle(
                //                               fontSize: 17,
                //                               color:
                //                                   Color.fromARGB(255, 0, 0, 0)),
                //                           contentPadding:
                //                               EdgeInsets.fromLTRB(20, 0, 0, 0)),
                //                       controller: _eventTimerInputController,
                //                     ),
                //                   )),
                //             ),
                //             Container(
                //                 alignment: Alignment.centerRight,
                //                 // decoration: BoxDecoration(
                //                 //     color: Colors.redAccent,
                //                 //     border: Border.all(),
                //                 //   ),
                //                 width: 45,
                //                 child: (_eventTimerInputController.text == "")
                //                     ? IconButton(
                //                         icon: Icon(Icons.navigate_next),
                //                         color: Color.fromARGB(255, 0, 0, 0),
                //                         iconSize: 25,
                //                         onPressed: () => _removeReminder(
                //                             _eventTimerInputController.text),
                //                       )
                //                     : IconButton(
                //                         icon: Icon(Icons.close),
                //                         color: Color.fromARGB(255, 0, 0, 0),
                //                         iconSize: 15,
                //                         onPressed: () => _removeReminder(
                //                             _eventTimerInputController.text),
                //                       )),
                //           ],
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                // Container(
                //   padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                //   alignment: Alignment.center,
                //   decoration: BoxDecoration(
                //       color: Colors.white,
                //       border: Border(
                //         bottom: BorderSide(
                //             width: 1.0,
                //             color: Color.fromARGB(255, 187, 187, 187)),
                //       )),
                //   height: 50,
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: <Widget>[
                //       Expanded(
                //         flex: 10,
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                //           children: <Widget>[
                //             GestureDetector(
                //               onTap: () {
                //                 Future<dynamic> _resultFuture = Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                     builder: (context) => PageTagEvent(
                //                       eventBloc: _bloc,
                //                       tagID:
                //                           (actionFlg == constants.ACTION_EDIT)
                //                               ? _bloc.onGetEventTagIDInput()
                //                               : null,
                //                     ),
                //                   ),
                //                 );
                //                 _resultFuture.then((res) async {
                //                   if (res != null) {
                //                     if (res.toString() != "") {
                //                       setState(() {
                //                         _eventTagsInputController.text =
                //                             res.toString();
                //                       });
                //                     }
                //                   }
                //                 });
                //               },
                //               child: AbsorbPointer(
                //                 child: TextField(
                //                   style: TextStyle(
                //                       fontSize: 17,
                //                       color: Color.fromARGB(255, 0, 0, 0)),
                //                   decoration: InputDecoration(
                //                       prefixIcon: Icon(Icons.flag,
                //                           color: Color.fromARGB(255, 0, 0, 0)),
                //                       suffixIcon: Icon(Icons.navigate_next,
                //                           color: Color.fromARGB(255, 0, 0, 0)),
                //                       enabledBorder: OutlineInputBorder(
                //                           borderSide: BorderSide(
                //                               color: Colors.transparent)),
                //                       hintText: 'Nhãn',
                //                       hintStyle: TextStyle(
                //                           fontSize: 17,
                //                           color: Color.fromARGB(255, 0, 0, 0)),
                //                       contentPadding:
                //                           EdgeInsets.fromLTRB(20, 0, 20, 0)),
                //                   controller: _eventTagsInputController,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       )
                //     ],
                //   ),
                // ),

                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                                child: Text(
                                  'Thời gian biểu',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                )),
                            Container(
                              child: _renderSchedule(),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          if (actionFlg == constants.ACTION_EDIT)
            // This container holds the align
            Container(
                // This align moves the children to the bottom
                child: GestureDetector(
                    onTap: () {
                      print("test");
                      confirmDeleteEvent(widget.eventId ?? '');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 237, 235, 234),
                          border: Border(
                            top: BorderSide(
                                width: 1.0,
                                color: Color.fromARGB(255, 237, 235, 234)),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Xóa bỏ',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal),
                            )
                          ],
                        ))))
        ],
      ),
    );
  }

  Widget _renderSchedule() {
    return StreamBuilder<List<EventByDayOutput>>(
        stream: _bloc.eventTimelineStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            List<Widget> listW = [];
            for (var item in snapshot.data!) {
              listW.add(Padding(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Container(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Container(
                          height: 10,
                          width: 10,
                          color: (item.type == 0)
                              ? constants.TYPE_MEETING_COLOR
                              : constants.TYPE_PERSONAL_COLOR,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          StringUtils.convertTimeFromString(item.from, "hh:mm"),
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        if (!StringUtils.isNullOrEmpty(item.to) &&
                            item.to != item.from)
                          Text(
                            " - ",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        if (!StringUtils.isNullOrEmpty(item.to) &&
                            StringUtils.convertTimeFromString(
                                    item.to, "hh:mm") !=
                                "00:00" &&
                            item.to != item.from)
                          Text(
                            StringUtils.convertTimeFromString(item.to, "hh:mm"),
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        Text(
                          '  Bận',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
              ));
            }

            return Column(children: listW);
          }
          return _nodata();
        });
  }

  Widget _nodata() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: <Widget>[
          Text(
            'Chưa có kế hoạch cá nhân hoặc lịch họp liên quan đến tôi!',
            style: TextStyle(
                fontSize: 15, color: Color.fromARGB(255, 184, 134, 11)),
          ),
        ],
      ),
    );
  }

  Future<bool> _addEventToCalendar(DateTime dateEvent, DateTime startAt,
      int minuteBefore, String eventTitle, String eventDes) {
    int day = dateEvent.day;
    int month = dateEvent.month;
    int year = dateEvent.year;
    int hour = startAt.hour;
    int minute = startAt.minute;
    DateTime startDate = new DateTime(year, month, day, hour, minute);
    Event event = Event(
      title: eventTitle,
      description: eventDes,
      location: 'Meeting schedule',
      startDate: startDate.subtract(Duration(minutes: minuteBefore)),
      endDate: startDate,
    );
    return Add2Calendar.addEvent2Cal(event);
  }
}
