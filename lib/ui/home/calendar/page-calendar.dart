import 'dart:async';
import 'dart:io';
import 'package:nmeeting/base/api-provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:nmeeting/bloc/calendarBloc.dart';
import 'package:nmeeting/bloc/in-meeting/in-meetingBloc.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/configs/constants.dart' as constants;
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:nmeeting/models/calendar.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/vnpt_calendar/lib/calendar.dart';
// import 'package:nmeeting/ui/common-widgets/vnpt_year_calendar/year_view.dart';
import 'package:nmeeting/ui/home/calendar/page-year-list.dart';
import 'package:nmeeting/ui/home/event/page-event-create.dart';
import 'package:nmeeting/ui/home/meeting/page-meeting-detail.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart' as tc;

import '../../common-widgets/vnpt_calendar/lib/calendar.dart';

enum CalendarViewMode { year, month, week }

class PageCalendar extends StatefulWidget {
  final InMeetingBloc inmeetingBloc;
  final UnitBloc unitBloc;
  final MeetingBloc meetingBloc = new MeetingBloc();
  //final void Function(int) onSetPageViewIndex;
  //final int pageIndex;

  PageCalendar({
    Key? key,
    required this.inmeetingBloc,
    required this.unitBloc,
    //@required this.onSetPageViewIndex
    // @required this.pageIndex
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageCalendarState();
  }
}

class _PageCalendarState extends State<PageCalendar> {
  //static const all = 'VTTP';
  static const myUnit = 'Đơn vị';
  static const mySelf = 'Cá nhân';
  static const other = 'Khác';
  late int _selected;
  String _unitName = '';
  bool otherPopupCancel = false;

  String _calendarSelectedFilterValue = '';

  CalendarViewMode _calendarViewMode = CalendarViewMode.month;
  DateTime _initialDisplayDate = DateTime.now();
  DateTime _dateMonthViewChanged = DateTime.now();
  DateTime _initialDayTimelineDisplayDate = DateTime.now();
  //String _monthYearHeaderView = '';

  final _calendarBloc = new CalendarBloc();
  //final _unitBloc = new UnitBloc();

  late CalendarDataSource _dataSourceMonth;
  CalendarDataSource _dataSourceDay = EventByDayDataSource([]);

  late DateTime _dateSeletedCurrent;
  late DateTime _dateSeletedFrom;
  late DateTime _dateSeletedTo;

  static const _vttp = '__VTTP__';
  static const _personal = '__Personal__';

  @override
  void initState() {
    // if (widget.pageIndex != constants.PAGE_CALENDAR) {
    //   return;
    // }

    //getSelectedFilterValue();
    //_calendarSelectedFilterValue = widget.menuList[0];
    _dataSourceMonth = EventByMonthDataSource([]);
    //_unitBloc.getUnitList();
    //widget.unitBloc.setUnitListStreamController();
    super.initState();
  }

  // getSelectedFilterValue() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   _calendarSelectedFilterValue =
  //       prefs.getString('calendarSelectedFilterValue') ?? myUnit;
  // }

  @override
  Widget build(BuildContext context) {
    // if (widget.pageIndex != constants.PAGE_CALENDAR) {
    //   return Container();
    // }

    // if (_calendarViewMode == CalendarViewMode.year) {
    //   return _buildYearView();
    // }
    if (_calendarViewMode == CalendarViewMode.month) {
      return _buildMonthView();
    }

    return _buildWeekView();
  }

  Widget _buildWeekView() {
    final _mediaQuery = MediaQuery.of(context);
    double _widthTableCalendar = 400;

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
                height: 50,
                //color: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: Container(
                        //padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.arrow_back_ios,
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _calendarViewMode = CalendarViewMode.month;
                        });
                      },
                    ),
                    StreamBuilder<String>(
                        stream: _calendarBloc.monthYearHeaderViewStream,
                        builder: (context, snapshot) {
                          return Container(
                            child: Text(
                              snapshot.data ?? '',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                    Container()
                  ],
                ),
              ),
              Container(height: 2, color: Colors.grey[200]),
              StreamBuilder<List<UnitList>>(
                  stream: widget.unitBloc.unitListStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.length > 0)
                      return Container(
                        height: 65,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        //color: Colors.green,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 100,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _getselectedColor(
                                            snapshot.data![index].selected!,
                                            snapshot.data![index].id!),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 90,
                                      child: Text(
                                        snapshot.data![index].name!,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                snapshot.data![index].selected!
                                                    ? Colors.white
                                                    : Colors.black),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                widget.unitBloc.updateSelectedUnitList(index);

                                _getEventByDay(_initialDisplayDate);
                              },
                            );
                          },
                        ),
                      );
                    return Container();
                  }),
              Container(height: 8, color: Colors.grey[200]),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      top: 10,
                      child: Column(
                        children: [
                          Expanded(
                            child: _timeline(),
                          ),
                        ],
                      ),
                    ),
                    _tableCalendar(_mediaQuery, _widthTableCalendar),
                  ],
                ),
              ),
              // Container(
              //   padding: EdgeInsets.fromLTRB(8, 8, 80, 8),
              //   child: Row(
              //     children: <Widget>[
              //       Container(
              //         width: 22,
              //         height: 22,
              //         decoration: BoxDecoration(
              //             color: constants
              //                 .MONTH_APPOINTMENT_MEETING_BACKGROUND_COLOR,
              //             borderRadius: BorderRadius.circular(5)),
              //       ),
              //       SizedBox(
              //         width: 8,
              //       ),
              //       Flexible(
              //         child: Text(
              //           _unitName,
              //           style: TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // if (_calendarSelectedFilterValue == mySelf)
              //   Container(
              //     padding: EdgeInsets.fromLTRB(8, 8, 80, 8),
              //     child: Row(
              //       children: <Widget>[
              //         Container(
              //           width: 22,
              //           height: 22,
              //           decoration: BoxDecoration(
              //               color: constants
              //                   .MONTH_APPOINTMENT_PERSONAL_BACKGROUND_COLOR,
              //               borderRadius: BorderRadius.circular(5)),
              //         ),
              //         SizedBox(
              //           width: 8,
              //         ),
              //         Text(
              //           'Kế hoạch cá nhân',
              //           style: TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //       ],
              //     ),
              //   )
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<List<UnitList>>(
          stream: widget.unitBloc.unitListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.length > 0 &&
                snapshot.data!
                    .any((i) => i.id == _personal && i.selected == true)) {
              return Container(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: constants.MONTH_PERSONAL_BACKGROUND_COLOR,
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      )
                    ],
                  ),
                  onTap: () {
                    _goToEventDetail(null);
                  },
                ),
              );
            }
            return Container();
          }),
    );
  }

  _timeline() {
    return Container(
      child: SfCalendar(
        view: CalendarView.day,
        // remove border when selection
        selectionDecoration: BoxDecoration(),
        firstDayOfWeek: 1,
        todayHighlightColor: Colors.red,
        headerStyle: CalendarHeaderStyle(textAlign: TextAlign.left),
        headerHeight: 0,
        appointmentTextStyle:
            TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        dataSource: _dataSourceDay,
        // minDate: _initialDayTimelineDisplayDate,
        // maxDate: _initialDayTimelineDisplayDate,
        onTap: (CalendarTapDetails value) {
          if (value.targetElement == CalendarElement.appointment) {
            if (value.appointments![0].groupID ==
                    constants.CALENDAR_GROUP_VTTP ||
                value.appointments![0].groupID ==
                    constants.CALENDAR_GROUP_UNITS) {
              _goToMeetingDetail(value);
            } else if (value.appointments![0].groupID ==
                constants.CALENDAR_GROUP_PERSONAL) {
              _goToEventDetail(value);
            }
          }
        },
      ),
    );
  }

  _tableCalendar(_mediaQuery, _widthTableCalendar) {
    return Container(
      alignment: Alignment.center,
      width: _mediaQuery.size.width,
      height: 80,
      child: Container(
        width: _widthTableCalendar,
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: tc.TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _initialDisplayDate,
            locale: 'vi_VN',
            startingDayOfWeek: tc.StartingDayOfWeek.monday,
            calendarFormat: tc.CalendarFormat.week,
            headerVisible: false,
            calendarStyle: tc.CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              defaultTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              outsideTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            daysOfWeekStyle: tc.DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.black87),
            ),
            onFormatChanged: (format) {
              // nếu bạn cần đổi format (tuần/tháng/ngày)
              setState(() {});
            },
            onPageChanged: (focusedDay) {
              _initialDisplayDate = focusedDay;
              _calendarBloc.setMonthYearHeaderView(
                  DateFormat('MM/yyyy').format(focusedDay));
              _getEventByDay(focusedDay);
            },
            selectedDayPredicate: (day) {
              return tc.isSameDay(_dateSeletedCurrent, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _dateSeletedCurrent = selectedDay;
                _initialDisplayDate = focusedDay;
              });
              _getEventByDay(selectedDay);
            },
          ),
        ),
      ),
    );
  }

  Color _getselectedColor(bool _selected, String _id) {
    Color _color = Colors.white;
    if (_selected) {
      if (_id == _vttp) {
        return constants.MONTH_VTTP_BACKGROUND_COLOR;
      }

      if (_id == _personal) {
        return constants.MONTH_PERSONAL_BACKGROUND_COLOR;
      }
      return constants.MONTH_UNITS_BACKGROUND_COLOR;
    }
    return _color;
  }

  Widget _buildMonthView() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                // margin: EdgeInsets.only(top: 7),
                //padding: EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      //color: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: Container(
                              //padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.arrow_back_ios,
                                    size: 25,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              // setState(() {
                              //   _calendarViewMode = CalendarViewMode.year;
                              //   _initialDisplayDate = _dateMonthViewChanged;
                              // });

                              Navigator.of(context).pop();
                            },
                          ),
                          StreamBuilder<String>(
                            stream: _calendarBloc.monthYearHeaderViewStream,
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          Container()
                        ],
                      ),
                    ),
                    Container(height: 2, color: Colors.grey[200]),
                    StreamBuilder<List<UnitList>>(
                        stream: widget.unitBloc.unitListStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.length > 0)
                            return Container(
                              height: 65,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              //color: Colors.green,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: 100,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: _getselectedColor(
                                                  snapshot
                                                      .data![index].selected!,
                                                  snapshot.data![index].id!),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 90,
                                            child: Text(
                                              snapshot.data![index].name!,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: snapshot.data![index]
                                                          .selected!
                                                      ? Colors.white
                                                      : Colors.black),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      widget.unitBloc
                                          .updateSelectedUnitList(index);
                                      _getEventByMonth(
                                          _dateSeletedFrom, _dateSeletedTo);
                                    },
                                  );
                                },
                              ),
                            );
                          return Container();
                        }),
                    Container(height: 8, color: Colors.grey[200]),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: SfCalendar(
                        // isShowHeader: false,
                        initialDisplayDate: _initialDisplayDate,
                        view: CalendarView.month,
                        firstDayOfWeek: 1,
                        todayHighlightColor: Colors.red,
                        headerStyle: CalendarHeaderStyle(
                            textAlign: TextAlign.center,
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black)),
                        appointmentTextStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        monthViewSettings: MonthViewSettings(
                          monthCellStyle: MonthCellStyle(
                              todayTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18),
                              trailingDatesTextStyle:
                                  TextStyle(color: Colors.black, fontSize: 18),
                              leadingDatesTextStyle:
                                  TextStyle(color: Colors.black, fontSize: 18),
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18)),
                          dayFormat: 'EEE',
                          appointmentDisplayMode:
                              MonthAppointmentDisplayMode.appointment,
                          appointmentDisplayCount: 4,
                        ),
                        dataSource: _dataSourceMonth,
                        onViewChanged: (ViewChangedDetails viewDeatils) {
                          _calendarBloc.setMonthYearHeaderView(
                              DateFormat('MM/yyyy')
                                  .format(viewDeatils.visibleDates[15]));

                          _dateSeletedFrom = viewDeatils.visibleDates[0];
                          _dateSeletedTo = viewDeatils.visibleDates[
                              viewDeatils.visibleDates.length - 1];
                          _getEventByMonth(
                              viewDeatils.visibleDates[0],
                              viewDeatils.visibleDates[
                                  viewDeatils.visibleDates.length - 1]);

                          _dateMonthViewChanged = new DateTime(
                              viewDeatils.visibleDates[15].year,
                              viewDeatils.visibleDates[15].month,
                              1);
                        },
                        onTap: (CalendarTapDetails _cDetails) {
                          if (_cDetails.targetElement ==
                              CalendarElement.calendarCell) {
                            _initialDisplayDate = _cDetails.date!;
                            _initialDayTimelineDisplayDate = _cDetails.date!;

                            _calendarBloc.setMonthYearHeaderView(
                                DateFormat('MM/yyyy').format(_cDetails.date!));

                            setState(() {
                              _dateSeletedCurrent = _initialDisplayDate;
                              _calendarViewMode = CalendarViewMode.week;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                // GestureDetector(
                //   child: Container(
                //     padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: <Widget>[
                //         Icon(
                //           Icons.arrow_back_ios,
                //           size: 25,
                //         ),
                //       ],
                //     ),
                //   ),
                //   onTap: () {
                //     // setState(() {
                //     //   _calendarViewMode = CalendarViewMode.year;
                //     //   _initialDisplayDate = _dateMonthViewChanged;
                //     // });

                //     Navigator.of(context).pop();
                //   },
                // ),
                // Container(
                //   alignment: Alignment.topRight,
                //   child: PopupMenuButton<String>(
                //     child: Container(
                //         margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                //         padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                //         width: 95,
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(15),
                //             color: Color.fromARGB(255, 66, 133, 244)),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                //           children: <Widget>[
                //             Text(_calendarSelectedFilterValue,
                //                 style: TextStyle(
                //                     fontSize: 15,
                //                     fontWeight: FontWeight.bold,
                //                     color: Colors.white)),
                //             Icon(Icons.arrow_drop_down,
                //                 size: 20, color: Colors.white)
                //           ],
                //         )),
                //     shape: RoundedRectangleBorder(
                //         side: BorderSide(
                //             color: Colors.transparent,
                //             width: 1,
                //             style: BorderStyle.solid),
                //         borderRadius: BorderRadius.circular(8)),
                //     offset: Offset(0, 50),
                //     padding: EdgeInsets.all(0),
                //     onSelected: choiceAction,
                //     itemBuilder: (BuildContext context) {
                //       return widget.menuList.map((String choice) {
                //         return PopupMenuItem<String>(
                //           value: choice,
                //           child: Row(
                //             children: <Widget>[
                //               Text(choice),
                //               if (_calendarSelectedFilterValue == choice)
                //                 Padding(
                //                   padding: const EdgeInsets.only(left: 3),
                //                   child: Icon(
                //                     Icons.check,
                //                     size: 20,
                //                   ),
                //                 )
                //             ],
                //           ),
                //         );
                //       }).toList();
                //     },
                //   ),
                // ),
              ),
            ),
            // Container(
            //   padding: EdgeInsets.fromLTRB(8, 8, 80, 8),
            //   child: Row(
            //     children: <Widget>[
            //       Container(
            //         width: 22,
            //         height: 22,
            //         decoration: BoxDecoration(
            //             color: constants
            //                 .MONTH_APPOINTMENT_MEETING_BACKGROUND_COLOR,
            //             borderRadius: BorderRadius.circular(5)),
            //       ),
            //       SizedBox(
            //         width: 8,
            //       ),
            //       Flexible(
            //         child: Text(
            //           _unitName,
            //           style: TextStyle(fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // if (_calendarSelectedFilterValue == mySelf)
            //   Container(
            //     padding: EdgeInsets.fromLTRB(8, 8, 80, 8),
            //     child: Row(
            //       children: <Widget>[
            //         Container(
            //           width: 22,
            //           height: 22,
            //           decoration: BoxDecoration(
            //               color: constants
            //                   .MONTH_APPOINTMENT_PERSONAL_BACKGROUND_COLOR,
            //               borderRadius: BorderRadius.circular(5)),
            //         ),
            //         SizedBox(
            //           width: 8,
            //         ),
            //         Text(
            //           'Kế hoạch cá nhân',
            //           style: TextStyle(fontWeight: FontWeight.bold),
            //         ),
            //       ],
            //     ),
            //   )
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<List<UnitList>>(
          stream: widget.unitBloc.unitListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.length > 0 &&
                snapshot.data!
                    .any((i) => i.id == _personal && i.selected == true)) {
              return Container(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: constants.MONTH_PERSONAL_BACKGROUND_COLOR,
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      )
                    ],
                  ),
                  onTap: () {
                    _goToEventDetail(null);
                  },
                ),
              );
            }
            return Container();
          }),
    );
  }

  // choiceAction(String choice) async {
  //   otherPopupCancel = false;

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('calendarSelectedFilterValue', choice);
  //   if (choice == other) await _openOtherPopup();
  //   if (!otherPopupCancel) _calendarSelectedFilterValue = choice;

  //   if (_calendarViewMode == CalendarViewMode.month) {
  //     _getEventByMonth(_dateSeletedFrom, _dateSeletedTo);
  //   } else if (_calendarViewMode == CalendarViewMode.week) {
  //     _getEventByDay(_initialDisplayDate);
  //   }
  // }

  _goToEventDetail(value) async {
    String _resultStr = "";
    if (value != null) {
      _resultStr = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PageCreateEvent(
            eventId: value.appointments[0].id,
            meetingBloc: widget.meetingBloc,
          ),
        ),
      );
    } else {
      _resultStr = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PageCreateEvent(
            meetingBloc: widget.meetingBloc,
          ),
        ),
      );
    }

    if (!StringUtils.isNullOrEmpty(_resultStr) &&
        _resultStr == constants.STATUS_SUCCESS) {
      if (_calendarViewMode == CalendarViewMode.month) {
        _getEventByMonth(_dateSeletedFrom, _dateSeletedTo);
      } else if (_calendarViewMode == CalendarViewMode.week) {
        _getEventByDay(_dateSeletedCurrent);
      }
    }
  }

  // Widget _buildYearView() {
  //   return Scaffold(
  //     body: SingleChildScrollView(
  //       child: VNPTYearView(
  //         context: context,
  //         year: _initialDisplayDate.year,
  //         currentDateColor: Colors.red,
  //         onMonthTap: (int year, int month) {
  //           setState(() {
  //             _calendarViewMode = CalendarViewMode.month;
  //             _initialDisplayDate = new DateTime(year, month, 1);
  //           });
  //         },
  //         onYearTap: (int val) async {
  //           final year = await Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => PageYearList(
  //                   selectedDate: DateTime(_initialDisplayDate.year),
  //                   firstDate: DateTime(2020),
  //                   lastDate: DateTime(2050),
  //                 ),
  //               ));
  //
  //           if (year != null) {
  //             setState(() {
  //               _initialDisplayDate = DateTime(year);
  //             });
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }

  _getEventByDay(DateTime _date) {
    var _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        // int _filterValue = 0;
        // if (_calendarSelectedFilterValue == myUnit) {
        //   _unitID = null;
        //   _unitName = 'Lịch họp đơn vị';
        //   _filterValue = 1;
        // } else if (_calendarSelectedFilterValue == mySelf) {
        //   _unitName = 'Lịch họp liên quan đến tôi';
        //   _filterValue = 2;
        // } else if (_calendarSelectedFilterValue == other) {
        //   _filterValue = 1;
        // } else {
        //   _unitName = 'Lịch tuần VTTP';
        // }

        List<String> _searchValue = widget.unitBloc.getUnitListSelect();
        Future<TResult> _fu = _calendarBloc.getEventByDay(
            DateTime(_date.year, _date.month, _date.day).toString(),
            _searchValue);

        _fu.then((res) {
          if (res.status == 1) {
            setState(() {
              // set duration min 35 minutes if duration < 35 minutes for show appointment text
              List<EventByDayOutput> data = res.data;
              if (data.length > 0) {
                for (EventByDayOutput item in data) {
                  DateTime from = DateTime.parse(item.from!);
                  DateTime to = DateTime.parse(
                      StringUtils.isNullOrEmpty(item.to)
                          ? item.from!
                          : item.to!);

                  int diffMinutes = to.difference(from).inMinutes;
                  if (diffMinutes < 35) {
                    to = from.add(Duration(minutes: 60));

                    if (DateTime(to.year, to.month, to.day, 23, 59, 59)
                            .difference(from)
                            .inDays >
                        0) {
                      from = from.subtract(Duration(minutes: 60));
                    }
                  }

                  item.from = from.toString();
                  item.to = to.toString();

                  // DateTime startDate =
                  //     DateTime(from.year, from.month, from.day, 05, 0, 0);
                  // DateTime endDate =
                  //     DateTime(from.year, from.month, from.day, 23, 59, 59);

                  // int diffMinutes = to.difference(from).inMinutes;

                  // if (diffMinutes < 35) {
                  //   int minutesNeedAdd = 35 - diffMinutes;

                  //   DateTime fromTemp = from.subtract(
                  //       Duration(minutes: (minutesNeedAdd / 2).round()));

                  //   DateTime toTemp =
                  //       to.add(Duration(minutes: (minutesNeedAdd / 2).round()));

                  //   if (startDate.isAfter(fromTemp)) {
                  //     item.to =
                  //         to.add(Duration(minutes: minutesNeedAdd)).toString();
                  //   } else if (endDate.isBefore(toTemp)) {
                  //     item.from = from
                  //         .subtract(Duration(minutes: minutesNeedAdd))
                  //         .toString();
                  //   } else {
                  //     item.from = fromTemp.toString();
                  //     item.to = toTemp.toString();
                  //   }
                  // }
                }
              }

              _dataSourceDay = EventByDayDataSource(data);
              _initialDisplayDate =
                  DateTime(_date.year, _date.month, _date.day);
              _initialDayTimelineDisplayDate =
                  DateTime(_date.year, _date.month, _date.day);
            });
          }
        });
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  _getEventByMonth(DateTime _dtFrom, DateTime _dtTo) {
    var _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        String _from = DateFormat(constants.DATE_FORMAT_SERVER).format(_dtFrom);
        String _to = DateFormat(constants.DATE_FORMAT_SERVER).format(_dtTo);
        // int _filterValue = 0;

        // if (_calendarSelectedFilterValue == myUnit) {
        //   _unitID = null;
        //   _unitName = 'Lịch họp đơn vị';
        //   _filterValue = 1;
        // } else if (_calendarSelectedFilterValue == mySelf) {
        //   _unitName = 'Lịch họp liên quan đến tôi';
        //   _filterValue = 2;
        // } else if (_calendarSelectedFilterValue == other) {
        //   _filterValue = 1;
        // } else {
        //   _unitName = 'Lịch tuần VTTP';
        // }

        List<String> _searchValue = widget.unitBloc.getUnitListSelect();
        Future<TResult> _fu =
            _calendarBloc.getEventByMonth(_from, _to, _searchValue);
        _fu.then(((res) {
          if (res.status == 1) {
            setState(() {
              _dataSourceMonth = EventByMonthDataSource(res.data);
            });
          }
        }));
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  _goToMeetingDetail(value) async {
    widget.meetingBloc.onSetMeetingId(value.appointments[0].id);
    widget.inmeetingBloc.onSetMeetingId(value.appointments[0].id);
    //2020-08-01 13:01:17.000
    widget.inmeetingBloc.onSetMeetingTime(value.date); // Column MeetingDate
    final TargetPlatform platform = Theme.of(context).platform;
    final _returnData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageMeetingDetail(
            inmeetingBloc: widget.inmeetingBloc,
            meetingBloc: widget.meetingBloc,
            platform: platform),
      ),
    );

    _getEventByDay(this._dateSeletedCurrent);

    // if (_returnData == true) {
    //   widget.onSetPageViewIndex(1);
    // }
  }

//   Future<bool> _openOtherPopup() async {
//     _unitBloc.getUnitList();
//     String id;
//     String name;
//     return (await showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return StatefulBuilder(builder: (context, setState) {
//                 return AlertDialog(
//                   insetPadding:
//                       EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),

//                   title: Text("Chọn đơn vị cần xem lịch"),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(5))),
//                   actions: <Widget>[
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.3,
//                           child: FlatButton(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(7))),
//                             color: Colors.black12,
//                             child: const Text('Hủy'),
//                             materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                             textColor: Colors.black,
//                             onPressed: () {
//                               setState(() {
//                                 otherPopupCancel = true;
//                               });
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.3,
//                           child: FlatButton(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(7))),
//                             color: Colors.green,
//                             child: const Text('Đồng ý'),
//                             materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                             textColor: Colors.white,
//                             onPressed: () {
//                               setState(() {
//                                 _unitID = id;
//                                 _unitName = 'Lịch họp ' + name;
//                               });

//                               Navigator.of(context).pop(true);
//                             },
//                           ),
//                         ),
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.115,
//                         )
//                       ],
//                     ),
//                   ],
//                   //content: Text("Abc"),
//                   content: SingleChildScrollView(
//                     child: Container(
//                       width: double.maxFinite,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: <Widget>[
//                           Divider(),
//                           StreamBuilder<List<UnitList>>(
//                             stream: _unitBloc.unitListStream,
//                             builder: (context, snapshot) {
//                               if (snapshot.hasData) {
//                                 var _unitData = snapshot.data;
//                                 return Column(
//                                   children: <Widget>[
//                                     if (_unitData.length == 0)
//                                       Text("Không có danh sách đơn vị"),
//                                     if (_unitData.length > 0)
//                                       ConstrainedBox(
//                                         constraints: BoxConstraints(
//                                           maxHeight: MediaQuery.of(context)
//                                                   .size
//                                                   .height *
//                                               0.6,
//                                         ),
//                                         child: ListView.builder(
//                                             shrinkWrap: true,
//                                             itemCount: _unitData.length,
//                                             itemBuilder: (BuildContext context,
//                                                 int index) {
//                                               return Column(
//                                                 children: [
//                                                   SizedBox(
//                                                     height:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .height *
//                                                             0.06,
//                                                     child: RadioListTile(
//                                                         controlAffinity:
//                                                             ListTileControlAffinity
//                                                                 .trailing,
//                                                         title: Text(
//                                                             _unitData[index]
//                                                                 .name),
//                                                         value: index,
//                                                         groupValue: _selected,
//                                                         onChanged: (value) {
//                                                           setState(() {
//                                                             _selected = value;
//                                                             id =
//                                                                 _unitData[index]
//                                                                     .id;
//                                                             name =
//                                                                 _unitData[index]
//                                                                     .name;
//                                                           });
//                                                         }),
//                                                   ),
//                                                   Divider(),
//                                                 ],
//                                               );
//                                             }),
//                                       ),
//                                   ],
//                                 );
//                               }
//                               return Center(child: CircularProgressIndicator());
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               });
//             })) ??
//         false;
//   }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

class EventByMonthDataSource extends CalendarDataSource {
  EventByMonthDataSource(List<EventByMonthOutput> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return DateTime.parse(appointments![index].from);
  }

  @override
  DateTime getEndTime(int index) {
    return DateTime.parse(appointments![index].to);
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    if (appointments![index].groupID == constants.CALENDAR_GROUP_VTTP) {
      return constants.MONTH_VTTP_BACKGROUND_COLOR;
    }
    if (appointments![index].groupID == constants.CALENDAR_GROUP_UNITS) {
      return constants.MONTH_UNITS_BACKGROUND_COLOR;
    }

    if (appointments![index].groupID == constants.CALENDAR_GROUP_PERSONAL) {
      return constants.MONTH_PERSONAL_BACKGROUND_COLOR;
    }
    return Colors.white;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}

class EventByDayDataSource extends CalendarDataSource {
  EventByDayDataSource(List<EventByDayOutput> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return DateTime.parse(appointments![index].from);
  }

  @override
  DateTime getEndTime(int index) {
    return DateTime.parse(appointments![index].to);
  }

  @override
  String getSubject(int index) {
    return StringUtils.convertTimeFromString(
            appointments![index].from, 'hh:mm') +
        ': ' +
        appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    if (appointments![index].groupID == constants.CALENDAR_GROUP_VTTP) {
      return constants.DAY_VTTP_BACKGROUND_COLOR;
    }
    if (appointments![index].groupID == constants.CALENDAR_GROUP_UNITS) {
      return constants.DAY_UNITS_BACKGROUND_COLOR;
    }

    if (appointments![index].groupID == constants.CALENDAR_GROUP_PERSONAL) {
      return constants.DAY_PERSONAL_BACKGROUND_COLOR;
    }
    return Colors.white;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}
