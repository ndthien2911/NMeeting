import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:nmeeting/bloc/in-meeting/in-meetingBloc.dart';
import 'package:nmeeting/models/in-meeting/user-meeting.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-progress-dialog.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:nmeeting/configs/api-endpoint.dart' as api;

class PageMeetingDetailAssignUser extends StatefulWidget {
  final InMeetingBloc inMeetingBloc;
  PageMeetingDetailAssignUser({Key? key, required this.inMeetingBloc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageMeetingDetailAssignUserState();
}

class _PageMeetingDetailAssignUserState
    extends State<PageMeetingDetailAssignUser> {
  var userId;
  List<UserMeetingOutput>? listUser;
  List<String> stringList = [];

  @override
  void initState() {
    super.initState();

    initValue();
  }

  initValue() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');

    Future<List<String>> _resultFuture =
        widget.inMeetingBloc.getListUserAssign('');
    _resultFuture.then((res) async {
      if (res != null) {
        setState(() {
          stringList = res;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    bool isChanged = true;
    //listUser != null ? widget.inMeetingBloc.isChanged(listUser) : false;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: const Text(
          'Danh sách thành viên',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(children: <Widget>[
        _searchView(),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(bottom: isChanged == true ? 80 : 0),
            child: StreamBuilder<List<UserMeetingOutput>>(
                stream: widget.inMeetingBloc.assignListMeetingStream,
                builder: (context, snapshot) {
                  if (snapshot.data == null || snapshot.data!.length == 0) {
                    listUser = [];
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data != null) {
                      listUser = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: listUser!.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                              checkColor: Colors.white,
                              activeColor: listUser![index].disable == false
                                  ? Color.fromRGBO(30, 37, 239, 1)
                                  : Color.fromRGBO(135, 138, 216, 1),
                              title: Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: !StringUtils.isNullOrEmpty(
                                            listUser![index].avatar)
                                        ? CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            width: 40,
                                            height: 40,
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                      Icons.error_outline,
                                                      size: 40,
                                                    ),
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            imageUrl: api.BASE_URL +
                                                listUser![index].avatar)
                                        : CircleAvatar(
                                            backgroundImage: AssetImage(
                                                'lib/assets/images/no-avatar.png')),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Wrap(
                                              children: <Widget>[
                                                SizedBox(
                                                  width:
                                                      _mediaQuery.size.width *
                                                          0.6,
                                                  child: Text(
                                                    '${listUser![index].name}',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (!StringUtils.isNullOrEmpty(
                                            listUser![index].phone))
                                          Row(
                                            children: <Widget>[
                                              Text('${listUser![index].phone}',
                                                  textAlign: TextAlign.left),
                                              if (listUser![index].id == userId)
                                                Image(
                                                  image: AssetImage(
                                                      'lib/assets/icons/icon-me.png'),
                                                  width: 40,
                                                  height: 40,
                                                ),
                                            ],
                                          ),
                                      ]),
                                ],
                              ),
                              value: listUser![index].selected
                                  ? listUser![index].selected
                                  : false,
                              onChanged: (bool? value) {
                                if (value != null &&
                                    listUser![index].disable == false) {
                                  setState(() {
                                    listUser =
                                        handleSelected(value, index, listUser);
                                  });
                                }
                              });
                        },
                      );
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                }),
          ),
        ),
      ]),
      floatingActionButton: Visibility(
        child: Container(
          width: _mediaQuery.size.width * 0.9,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 66, 133, 244),
                Color.fromARGB(255, 66, 133, 244)
              ],
            ),
          ),
          child: MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            disabledElevation: 1,
            disabledColor: Colors.black45,
            shape: const StadiumBorder(),
            child: Text(
              'Xác nhận',
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              _onAssignUser();
            },
          ),
        ),
        visible: isChanged,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _searchView() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 40,
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(
          color: Color.fromRGBO(235, 233, 233, 1),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.bottom,
          onChanged: (value) => {_onSearchAssign(value)},
          onSubmitted: (value) => {},
          decoration: InputDecoration(
              hintText: 'Tìm kiếm',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 10)),
        ),
      ),
    );
  }

  _onSearchAssign(txtSearch) {
    widget.inMeetingBloc.searchUser(txtSearch);
  }

  handleSelected(value, index, list) {
    for (var i = 0; i < list.length; i++) {
      if (i == index) {
        list[i].selected = value;
        if (value == false) {
          for (var j = 0; j < stringList.length; j++) {
            if (stringList[j] == list[i].id) {
              stringList.remove(stringList[j]);
            }
          }
        } else {
          stringList.add(list[i].id.toString());
        }
      }
    }

    return list;
  }

  _onAssignUser() {
    bool isChanged = widget.inMeetingBloc.isChanged(stringList);

    if (!isChanged) {
      showToast('Vui lòng thay đổi danh sách thành viên trước khi mời!');
      return;
    }

    String idsStr = jsonEncode(stringList).toString();

    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        final _vnptProgress = VNPTProgressDialog(context);
        _vnptProgress.show();
        Future<dynamic> _resultFuture =
            widget.inMeetingBloc.assignUsers(idsStr);
        _resultFuture.then((res) {
          _vnptProgress.hide();
          if (res.status == 1) {
            showToast(res.msg);
            Navigator.pop(context, res);
          } else {
            showToast(res.msg);
          }
        });
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }
}
