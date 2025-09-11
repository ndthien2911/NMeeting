import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/models/in-meeting/user-meeting.dart';
import 'package:nmeeting/models/meeting.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:nmeeting/configs/constants.dart' as constants;

class PageCreateMeeting extends StatefulWidget {
  final MeetingBloc meetingBloc;
  final String meetingId;
  PageCreateMeeting({Key key, this.meetingId, @required this.meetingBloc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageCreateMeetingState();
}

class _PageCreateMeetingState extends State<PageCreateMeeting> {
  ScrollController _controller;
  String _meetingDateResToServer;
  String _meetingFileUrlInput;
  bool _meetingPublicFlg = false;
  String _meetingEndDateResToServer;

  final _meetingNameInputController = TextEditingController();
  final _meetingAddressInputController = TextEditingController();
  final _meetingDateResInputController = TextEditingController();
  final _meetingAdminJoinInputController = TextEditingController();
  final _meetingMemberJoinInputController = TextEditingController();
  final _meetingDateStartInputController = TextEditingController();
  final _meetingDateEndInputController = TextEditingController();
  final _meetingAdminInputController = TextEditingController();
  final _meetingElementInputController = TextEditingController();
  final _meetingNoteInputController = TextEditingController();
  final _meetingGuestInputController = TextEditingController();
  final _meetingEndDateResInputController = TextEditingController();

  String resultRespond = constants.STATUS_ERROR;
  int actionFlg = constants.ACTION_CREATE;

  //show list selected
  String unitNmList = "";
  String adminNmList = "";
  String roomNmList = "";
  String memberNmList = "";
  String fileNmList = "";

  @override
  void initState() {
    super.initState();

    if (!StringUtils.isNullOrEmpty(widget.meetingId)) {
      initValue(widget.meetingId);
      setState(() => actionFlg = constants.ACTION_EDIT);
    }
  }

  initValue(String id) async {
    Future<TResult> _resultFuture = widget.meetingBloc.getMeetingById(id);
    _resultFuture.then((res) async {
      if (res.status == 1) {
        MeetingObjInput _meetingObjInput = res.data;

        _meetingNameInputController.text = _meetingObjInput.name; // ten
        _meetingAddressInputController.text =
            _meetingObjInput.address; // dia diem
        _meetingAdminInputController.text = _meetingObjInput.admin; // chu tri
        _meetingElementInputController.text =
            _meetingObjInput.element; // thanh phan
        _meetingNoteInputController.text = _meetingObjInput.note; // chuan bi
        _meetingGuestInputController.text = _meetingObjInput.guest; // khach moi
        _meetingDateStartInputController.text = '07:00';
        _meetingDateEndInputController.text = '19:00';

        //widget.meetingBloc.onSetMeetingAdminInput(_meetingObjInput.admin);
        //widget.meetingBloc.onSetMeetingMemberInput(_meetingObjInput.memberList);
        _meetingDateResInputController.text = StringUtils.convertTimeFromString(
            _meetingObjInput.meetingDate, constants.DATE_FORMAT_DATE_TYPE_1);
        _meetingDateResToServer = _meetingObjInput.meetingDate;

        _meetingEndDateResInputController.text =
            StringUtils.convertTimeFromString(_meetingObjInput.meetingEndDate,
                constants.DATE_FORMAT_DATE_TYPE_1);
        _meetingEndDateResToServer = _meetingObjInput.meetingEndDate;

        _meetingDateStartInputController.text =
            StringUtils.convertTimeFromString(
                _meetingObjInput.startAt, constants.DATE_FORMAT_TIME_TYPE_1);
        _meetingDateEndInputController.text =
            (!StringUtils.isNullOrEmpty(_meetingObjInput.endAt))
                ? StringUtils.convertTimeFromString(
                    _meetingObjInput.endAt, constants.DATE_FORMAT_TIME_TYPE_1)
                : "";
        if (!StringUtils.isNullOrEmpty(_meetingObjInput.adminListObj)) {
          List<MemberVM> adList = new List<MemberVM>();
          dynamic adListTmp = jsonDecode(_meetingObjInput.adminListObj);
          final tmp = adListTmp.cast<Map<String, dynamic>>();
          adList = tmp.map<MemberVM>((event) {
            return MemberVM.fromJson(event);
          }).toList();
          widget.meetingBloc.onSetMeetingAdminToServer(adList);
        } else {
          widget.meetingBloc.onSetMeetingAdminToServer(new List<MemberVM>());
        }
        if (!StringUtils.isNullOrEmpty(_meetingObjInput.adminListObj)) {
          List<MemberVM> userList = new List<MemberVM>();
          dynamic userListd = jsonDecode(_meetingObjInput.memberListObj);
          final tmp2 = userListd.cast<Map<String, dynamic>>();
          userList = tmp2.map<MemberVM>((event) {
            return MemberVM.fromJson(event);
          }).toList();
          widget.meetingBloc.onSetMeetingUserToServer(userList);
        } else {
          widget.meetingBloc.onSetMeetingUserToServer(new List<MemberVM>());
        }

        setState(() {
          unitNmList = _meetingObjInput.unitNmList;
          adminNmList = _meetingObjInput.adminNmList;
          roomNmList = _meetingObjInput.roomNmList;
          memberNmList = _meetingObjInput.memberNmList;
          fileNmList = _meetingObjInput.fileNmList ?? '';
          _meetingPublicFlg =
              (_meetingObjInput.publicFlg != true) ? false : true;
        });
      }
    });
  }

  _submitMeeting(int actionFlg) {
    // String adminList = widget.meetingBloc.onGetMeetingAdminInput();
    // String memberList = widget.meetingBloc.onGetMeetingMemberInput();

    MeetingObjInput _dataMeeting = MeetingObjInput(
        name: _meetingNameInputController.text,
        // adminList: adminList,
        // memberList: memberList,
        //adminList: jsonEncode(widget.meetingBloc.onGetMeetingAdminToServer()),
        //memberList: jsonEncode(widget.meetingBloc.onGetMeetingUserToServer()),
        meetingDate: this._meetingDateResToServer,
        meetingEndDate: this._meetingEndDateResToServer,
        startAt: _meetingDateStartInputController.text,
        endAt: _meetingDateEndInputController.text,
        address: _meetingAddressInputController.text,
        admin: _meetingAdminInputController.text,
        element: _meetingElementInputController.text,
        note: _meetingNoteInputController.text,
        guest: _meetingGuestInputController.text,
        publicFlg: _meetingPublicFlg);

    MeetingObjRequest _data = MeetingObjRequest(
        meeting: _dataMeeting, typeRequest: constants.PAGE_ID_FOR_APP);

    Future<TResult> _resultFuture;
    if (actionFlg == constants.ACTION_EDIT) {
      String id = widget.meetingId;
      _data.meeting.id = id;
      _resultFuture = widget.meetingBloc.updateMeeting(_data);
    } else {
      _resultFuture = widget.meetingBloc.createMeeting(_data);
    }

    _resultFuture.then((res) async {
      int type = res.status;
      String mes = res.msg;
      setState(() => resultRespond =
          (type == 1) ? constants.STATUS_SUCCESS : constants.STATUS_ERROR);
      String actionStr = (actionFlg == constants.ACTION_EDIT)
          ? 'Cuộc họp đã được cập nhật'
          : 'Cuộc họp đã được tạo';

      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return VNPTDialog(
              type:
                  (type == 1) ? VNPTDialogType.success : VNPTDialogType.warning,
              title: (type == 1) ? "Thành công" : "Cảnh báo",
              description: (type == 1) ? actionStr : mes,
              actions: <Widget>[
                ButtonTheme(
                  minWidth: 134,
                  height: 40,
                  child: RaisedButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20),
                        side: BorderSide(
                          color: Color.fromARGB(255, 0, 108, 183),
                        )),
                    color: Color.fromARGB(255, 0, 108, 183),
                    textColor: Colors.white,
                    child: Text("Đồng ý",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (resultRespond == constants.STATUS_SUCCESS) {
                        Navigator.pop(context, resultRespond);
                      }
                    },
                  ),
                )
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: Color.fromARGB(255, 133, 146, 158)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            (actionFlg == constants.ACTION_CREATE)
                ? 'Đăng ký lịch họp'
                : 'Cập nhật lịch họp',
            style: TextStyle(fontSize: 25, color: Color.fromARGB(255, 0, 0, 0)),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(0),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                StreamBuilder<String>(
                    stream: widget.meetingBloc.meetingNameInputStream,
                    builder: (context, snapshot) {
                      return TextField(
                        maxLines: 8,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 0, 0, 128)),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên cuộc họp',
                          hintStyle: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 133, 146, 158)),
                          contentPadding: (!StringUtils.isNullOrEmpty(
                                  _meetingNameInputController.text))
                              ? EdgeInsets.only(top: 0)
                              : EdgeInsets.only(top: 0),
                        ),
                        onChanged: (value) =>
                            widget.meetingBloc.onChangedMeetingNameInput(value),
                        controller: _meetingNameInputController,
                      );
                    }),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Tên cuộc họp (*)",
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 139, 0, 0)),
                ),
                SizedBox(
                  height: 5,
                ),
                StreamBuilder<String>(
                    stream: widget.meetingBloc.meetingAddressInputStream,
                    builder: (context, snapshot) {
                      return TextField(
                        maxLines: 15,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 0, 0, 128)),
                        decoration: InputDecoration(
                          hintText: 'Nhập địa điểm họp',
                          hintStyle: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 133, 146, 158)),
                          contentPadding: (!StringUtils.isNullOrEmpty(
                                  _meetingAddressInputController.text))
                              ? EdgeInsets.only(top: 0)
                              : EdgeInsets.only(top: 0),
                        ),
                        onChanged: (value) => widget.meetingBloc
                            .onChangedMeetingAddressInput(value),
                        controller: _meetingAddressInputController,
                      );
                    }),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Địa điểm họp (*)',
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 139, 0, 0)),
                ),
                SizedBox(
                  height: 5,
                ),

                // GestureDetector(
                //   onTap: () {
                //     Future<dynamic> _resultFuture = Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => PageMeetingAdmin(
                //             listAdminSelected:
                //                 widget.meetingBloc.onGetMeetingAdminInput(),
                //             meetingBloc: widget.meetingBloc),
                //       ),
                //     );
                //     _resultFuture.then((res) async {
                //       if (res != null) {
                //         if (res.toString() != "") {
                //           List<String> memberNmTmp =
                //               StringUtils.convertStringToListWithCharacter(
                //                   memberNmList, ",");
                //           String memberNmTmpNew = "";
                //           for (var i = 0; i < memberNmTmp.length; i++) {
                //             if (res.toString().indexOf(memberNmTmp[i]) < 0) {
                //               if (memberNmTmpNew == "") {
                //                 memberNmTmpNew = memberNmTmp[i];
                //               } else {
                //                 memberNmTmpNew =
                //                     memberNmTmpNew + ", " + memberNmTmp[i];
                //               }
                //             }
                //           }
                //           setState(() {
                //             memberNmList = memberNmTmpNew;
                //           });
                //         }
                //         setState(() {
                //           adminNmList = res.toString();
                //         });
                //       }
                //     });
                //   },
                //   child: AbsorbPointer(
                //     child: TextField(
                //       keyboardType: TextInputType.number,
                //       maxLines: 4,
                //       minLines: 1,
                //       style: TextStyle(
                //           fontSize: 17, color: Color.fromARGB(255, 133, 146, 158)),
                //       decoration: InputDecoration(
                //         hintText: (adminNmList != "" && adminNmList != null)
                //             ? adminNmList
                //             : 'Chủ trì',
                //         hintStyle: TextStyle(
                //             fontSize: 17,
                //             color: Color.fromARGB(255, 133, 146, 158)),
                //         suffixIcon: IconButton(
                //             onPressed: () {},
                //             icon: Icon(
                //               Icons.add,
                //               size: 15,
                //               color: Color.fromARGB(255, 139, 0, 0),
                //             ),
                //             padding: EdgeInsets.only(right: 5),
                //             alignment: Alignment.centerRight),
                //       ),
                //       controller: _meetingAdminJoinInputController,
                //     ),
                //   ),
                // ),

                StreamBuilder<String>(
                    stream: widget.meetingBloc.meetingAdminInputStream,
                    builder: (context, snapshot) {
                      return TextField(
                        maxLines: 15,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 0, 0, 128)),
                        decoration: InputDecoration(
                          hintText: 'Nhập chủ trì cuộc họp',
                          hintStyle: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 133, 146, 158)),
                          contentPadding: (!StringUtils.isNullOrEmpty(
                                  _meetingAdminInputController.text))
                              ? EdgeInsets.only(top: 0)
                              : EdgeInsets.only(top: 0),
                        ),
                        onChanged: (value) => widget.meetingBloc
                            .onChangedMeetingAdminTextInput(value),
                        controller: _meetingAdminInputController,
                      );
                    }),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Chủ trì cuộc họp (*)',
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 139, 0, 0)),
                ),
                SizedBox(
                  height: 5,
                ),

                StreamBuilder<String>(
                    stream: widget.meetingBloc.meetingNoteInputStream,
                    builder: (context, snapshot) {
                      return TextField(
                        maxLines: 15,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 0, 0, 128)),
                        decoration: InputDecoration(
                          hintText: 'Nhập chuẩn bị',
                          hintStyle: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 133, 146, 158)),
                          contentPadding: (!StringUtils.isNullOrEmpty(
                                  _meetingNoteInputController.text))
                              ? EdgeInsets.only(top: 0)
                              : EdgeInsets.only(top: 0),
                        ),
                        onChanged: (value) => widget.meetingBloc
                            .onChangedMeetingNoteTextInput(value),
                        controller: _meetingNoteInputController,
                      );
                    }),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Chuẩn bị',
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 139, 0, 0)),
                ),
                SizedBox(
                  height: 5,
                ),

                StreamBuilder<String>(
                    stream: widget.meetingBloc.meetingElementInputStream,
                    builder: (context, snapshot) {
                      return TextField(
                        maxLines: 15,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 0, 0, 128)),
                        decoration: InputDecoration(
                          hintText: 'Nhập thành phần cuộc họp',
                          hintStyle: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 133, 146, 158)),
                          contentPadding: (!StringUtils.isNullOrEmpty(
                                  _meetingElementInputController.text))
                              ? EdgeInsets.only(top: 0)
                              : EdgeInsets.only(top: 0),
                        ),
                        onChanged: (value) => widget.meetingBloc
                            .onChangedMeetingElementTextInput(value),
                        controller: _meetingElementInputController,
                      );
                    }),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Thành phần cuộc họp (*)',
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 139, 0, 0)),
                ),
                SizedBox(
                  height: 5,
                ),

                StreamBuilder<String>(
                    stream: widget.meetingBloc.meetingGuestInputStream,
                    builder: (context, snapshot) {
                      return TextField(
                        maxLines: 15,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 0, 0, 128)),
                        decoration: InputDecoration(
                          hintText: 'Nhập Khách mời',
                          hintStyle: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 133, 146, 158)),
                          contentPadding: (!StringUtils.isNullOrEmpty(
                                  _meetingGuestInputController.text))
                              ? EdgeInsets.only(top: 0)
                              : EdgeInsets.only(top: 0),
                        ),
                        onChanged: (value) => widget.meetingBloc
                            .onChangedMeetingGuestTextInput(value),
                        controller: _meetingGuestInputController,
                      );
                    }),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Khách mời',
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 139, 0, 0)),
                ),
                SizedBox(
                  height: 5,
                ),

                // GestureDetector(
                //   onTap: () {
                //     Future<dynamic> _resultFuture = Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => PageMeetingUser(
                //             listUserSelected:
                //                 widget.meetingBloc.onGetMeetingMemberInput(),
                //             meetingBloc: widget.meetingBloc),
                //       ),
                //     );
                //     _resultFuture.then((res) async {
                //       if (res != null) {
                //         setState(() {
                //           memberNmList = res.toString();
                //         });
                //       }
                //     });
                //   },
                //   child: AbsorbPointer(
                //     child: TextField(
                //       keyboardType: TextInputType.number,
                //       maxLines: 6,
                //       minLines: 1,
                //       style: TextStyle(
                //           fontSize: 17, color: Color.fromARGB(255, 133, 146, 158)),
                //       decoration: InputDecoration(
                //         hintText: (memberNmList != "" && memberNmList != null)
                //             ? memberNmList
                //             : 'Thành phần',
                //         hintStyle: TextStyle(
                //             fontSize: 17,
                //             color: Color.fromARGB(255, 133, 146, 158)),
                //         suffixIcon: IconButton(
                //             onPressed: () {},
                //             icon: Icon(
                //               Icons.add,
                //               size: 15,
                //               color: Color.fromARGB(255, 139, 0, 0),
                //             ),
                //             padding: EdgeInsets.only(right: 5),
                //             alignment: Alignment.centerRight),
                //       ),
                //       controller: _meetingMemberJoinInputController,
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                // Row(
                //   children: <Widget>[
                //     Text(
                //       'Thành phần cuộc họp',
                //       style: TextStyle(
                //           fontSize: 12, color: Color.fromARGB(255, 139, 0, 0)),
                //     ),
                //     // Text(
                //     //   '(*)',
                //     //   style: TextStyle(
                //     //       fontSize: 10,
                //     //       color: Colors.red,
                //     //       fontStyle: FontStyle.italic
                //     //   ),
                //     // ),
                //   ],
                // ),
                SizedBox(
                  height: 5,
                ),
                Container(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      flex: 35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              DateTime current = DateTime.now();
                              DateTime start =
                                  current.subtract(Duration(days: 1));
                              var res = showDatePicker(
                                context: context,
                                initialDate: current,
                                firstDate: start,
                                lastDate: DateTime(2200),
                                builder: (BuildContext context, Widget child) {
                                  return Theme(
                                    data: ThemeData.light(),
                                    child: child,
                                  );
                                },
                              );
                              res.then((onValue) {
                                print(onValue);
                                if (onValue != null) {
                                  // date display
                                  setState(() {
                                    _meetingDateResInputController.text =
                                        DateFormat(constants.DATE_FORMAT_CLIENT)
                                            .format(onValue);
                                    _meetingDateResToServer =
                                        DateFormat(constants.DATE_FORMAT_SERVER)
                                            .format(onValue)
                                            .toString();
                                    _meetingEndDateResInputController.text =
                                        _meetingDateResInputController.text;
                                    _meetingEndDateResToServer =
                                        _meetingDateResToServer;
                                  });
                                  widget.meetingBloc
                                      .onChangedMeetingDateResInput(
                                          onValue.toString());
                                  widget.meetingBloc
                                      .onChangedMeetingEndDateResInput(
                                          onValue.toString());
                                }
                              });
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 0, 0, 128)),
                                decoration: InputDecoration(
                                  hintText: 'dd/MM/yyyy',
                                  hintStyle: TextStyle(
                                      fontSize: 17,
                                      color:
                                          Color.fromARGB(255, 133, 146, 158)),
                                  contentPadding: EdgeInsets.only(bottom: -10),
                                ),
                                controller: _meetingDateResInputController,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Từ ngày (*)',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 139, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            ' - ',
                            style: TextStyle(
                                fontSize: 17,
                                color: Color.fromARGB(255, 0, 0, 128)),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              DateTime current = DateTime.now();
                              DateTime start =
                                  current.subtract(Duration(days: 1));
                              var res = showDatePicker(
                                context: context,
                                initialDate: current,
                                firstDate: start,
                                lastDate: DateTime(2200),
                                builder: (BuildContext context, Widget child) {
                                  return Theme(
                                    data: ThemeData.light(),
                                    child: child,
                                  );
                                },
                              );
                              res.then((onValue) {
                                print(onValue);
                                if (onValue != null) {
                                  // date display
                                  setState(() {
                                    _meetingEndDateResInputController.text =
                                        DateFormat(constants.DATE_FORMAT_CLIENT)
                                            .format(onValue);
                                    _meetingEndDateResToServer =
                                        DateFormat(constants.DATE_FORMAT_SERVER)
                                            .format(onValue)
                                            .toString();
                                  });
                                  widget.meetingBloc
                                      .onChangedMeetingEndDateResInput(
                                          onValue.toString());
                                }
                              });
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 0, 0, 128)),
                                decoration: InputDecoration(
                                  hintText: 'dd/MM/yyyy',
                                  hintStyle: TextStyle(
                                      fontSize: 17,
                                      color:
                                          Color.fromARGB(255, 133, 146, 158)),
                                  contentPadding: EdgeInsets.only(bottom: -10),
                                ),
                                controller: _meetingEndDateResInputController,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Đến ngày (*)',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 139, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
                Container(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      flex: 35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              DatePicker.showTimePicker(context,
                                  theme: DatePickerTheme(
                                    containerHeight: 250.0,
                                  ),
                                  showTitleActions: true, onConfirm: (time) {
                                setState(() {
                                  _meetingDateStartInputController.text =
                                      StringUtils.convertFormatD2(
                                          time.hour, time.minute);
                                });
                                print('confirm $time');
                              },
                                  showSecondsColumn: false,
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 0, 0, 128)),
                                decoration: InputDecoration(
                                  hintText: 'HH:mm',
                                  hintStyle: TextStyle(
                                      fontSize: 17,
                                      color:
                                          Color.fromARGB(255, 133, 146, 158)),
                                  contentPadding: EdgeInsets.only(bottom: -10),
                                ),
                                controller: _meetingDateStartInputController,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Thời gian bắt đầu (*)',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 139, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            ' - ',
                            style: TextStyle(
                                fontSize: 17,
                                color: Color.fromARGB(255, 0, 0, 128)),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              DatePicker.showTimePicker(context,
                                  theme: DatePickerTheme(
                                    containerHeight: 250.0,
                                  ),
                                  showTitleActions: true, onConfirm: (time) {
                                // date display
                                setState(() {
                                  _meetingDateEndInputController.text =
                                      StringUtils.convertFormatD2(
                                          time.hour, time.minute);
                                });
                              },
                                  showSecondsColumn: false,
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 0, 0, 128)),
                                decoration: InputDecoration(
                                  hintText: 'HH:mm',
                                  hintStyle: TextStyle(
                                      fontSize: 17,
                                      color:
                                          Color.fromARGB(255, 133, 146, 158)),
                                  contentPadding: EdgeInsets.only(bottom: -10),
                                ),
                                controller: _meetingDateEndInputController,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Thời gian kết thúc',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 139, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      'Đăng ký lịch tuần VTTP',
                      style: TextStyle(
                          fontSize: 17, color: Color.fromARGB(255, 0, 0, 128)),
                    )),
                    Checkbox(
                      value: _meetingPublicFlg,
                      activeColor: Color.fromARGB(255, 0, 108, 183),
                      onChanged: (bool newValue) {
                        setState(() {
                          _meetingPublicFlg = newValue;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        disabledElevation: 1,
                        disabledColor: Colors.black45,
                        onPressed: () {
                          _submitMeeting(actionFlg);
                        },
                        child: Text(
                          (actionFlg == constants.ACTION_CREATE)
                              ? 'Đăng ký'
                              : 'Cập nhật',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                        color: Color.fromARGB(255, 0, 108, 183),
                        minWidth: double.infinity,
                        height: 53,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
