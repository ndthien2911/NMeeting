import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:nmeeting/models/in-meeting/user-meeting.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/material.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:oktoast/oktoast.dart';
import 'package:nmeeting/configs/constants.dart' as constants;

class PageMeetingUser extends StatefulWidget {
  final MeetingBloc meetingBloc;
  final String listUserSelected;
  PageMeetingUser({Key key, @required this.meetingBloc, @required this.listUserSelected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageMeetingUserState();
}

class _PageMeetingUserState
    extends State<PageMeetingUser> {
  var userId;
  List<UserMeetingOutput> listUser;
  List<dynamic> stringList = new List<dynamic>();

  final _itemInputController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(widget.listUserSelected != "" && widget.listUserSelected != "[]" && widget.listUserSelected != null) {
      stringList = jsonDecode(widget.listUserSelected);
    } else {
      stringList = new List<dynamic>();
    }

    initValue();
  }

  initValue() async {
    widget.meetingBloc.getListUser('',stringList);
  }

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 0, 0, 128)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Danh sách tham gia',
          style: TextStyle(
            fontSize: 25,
            color: Color.fromARGB(255, 0, 0, 128)
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(236, 252, 252, 252),
        elevation: 0,
      ),
      body: Container(
        color: Color.fromRGBO(236, 252, 252, 252),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.topLeft,
        child: Column(
          children: <Widget>[
            _searchView(_mediaQuery),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                child: StreamBuilder<List<UserMeetingOutput>>(
                    stream: widget.meetingBloc.userListMeetingStream,
                    builder: (context, snapshot) {
                      if (snapshot.data == null || snapshot.data.length == 0) {
                        listUser = new List<UserMeetingOutput>();
                        return _nodata();
                      }
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          listUser = snapshot.data;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: listUser.length,
                            itemBuilder: (context, index) {
                              return CheckboxListTile(
                                  checkColor: Colors.white,
                                  activeColor: Color.fromARGB(255,0, 108, 183),
                                  title: Row(
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: !StringUtils.isNullOrEmpty(listUser[index].avatar)
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
                                                    listUser[index].avatar)
                                            : CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'lib/assets/images/no-avatar.png')),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Wrap(
                                                  children: <Widget>[
                                                    SizedBox(
                                                      width:  _mediaQuery.size.width * 0.6,
                                                      child: Text(
                                                        '${listUser[index].name}',
                                                        style: TextStyle(
                                                            color: Color.fromARGB(255, 0, 0, 128), 
                                                            fontWeight: FontWeight.w600
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text('${listUser[index].id}',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Color.fromARGB(255, 0, 0, 128),
                                                    )
                                                )
                                              ],
                                            ),
                                          ]),
                                    ],
                                  ),
                                  value: listUser[index].selected ? listUser[index].selected : false,
                                  onChanged: (bool value) {
                                    setState(() {
                                      listUser = handleSelected(value, index, listUser);
                                    });
                                  });
                            },
                          );
                        }
                      }
                      return Center(child: CircularProgressIndicator());
                    }),
              ),
            ),
            Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MaterialButton(
                      elevation: 0,
                      disabledElevation: 1,
                      disabledColor: Colors.black45,
                      onPressed: () {
                        widget.meetingBloc.onChangedMeetingMemberInput(stringList);
                        String memberNmList = widget.meetingBloc.getListNameUserSelected(stringList);
                        Navigator.pop(context, memberNmList);
                      },
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      color: Color.fromARGB(255,0, 108, 183),
                      minWidth: double.infinity,
                      height: 53,
                    )
                  ],
                ),
              )
          ]
        ),
      )
    );
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
            'Không tìm thấy dữ liệu',
            style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 184, 134, 11)),
          ),
        ],
      ),
    );
  }

  Widget _searchView(_mediaQuery) {
    double width = (1 - ((34+60)/_mediaQuery.size.width));
    //double width = (1 - ((40)/_mediaQuery.size.width));
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 34,
              width: _mediaQuery.size.width * width,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                color: Color.fromRGBO(236, 236, 236, 1),
                borderRadius: BorderRadius.all(Radius.circular(17)),
              ),
              child: TextField(
                textAlignVertical: TextAlignVertical.bottom,
                onChanged: (value) => {
                  _onSearchList(value)
                },
                onSubmitted: (value) => {},
                decoration: InputDecoration(
                    hintText: 'Tìm kiếm',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 10)),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color:
                        Color.fromARGB(255, 4, 108, 180),
                    borderRadius: BorderRadius.circular(25)),
              ),
              Icon(
                Icons.add,
                color: Colors.white,
              )
            ],
          ),
              onTap: () {
                _itemInputController.text = "";
                _showAddItemDialog();
              },
            )
          ],
        )
      ],
    );
  }

  _showAddItemDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetAnimationDuration:
              const Duration(milliseconds: 100),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Container(       // use container to change width and height
            height: 200,
            width: 500,
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Material(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                                'Người tham gia',
                                style: TextStyle(
                                    fontSize: 17, color: Color.fromARGB(255, 0, 0, 128)),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: TextField(
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 109, 108, 108)),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Tên',
                                  contentPadding: EdgeInsets.only(bottom: -20),
                                ),
                                onChanged: (value) => print("object"),
                                controller: _itemInputController,
                              ),
                              width: 460,
                            ),
                          ],
                        ),
                        Divider(
                          color: Color.fromARGB(255, 178, 178, 178),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        MaterialButton(
                          disabledElevation: 1,
                          disabledColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                              borderRadius:BorderRadius.circular(17)
                          ),
                          onPressed: () {
                            _createItem(_itemInputController.text);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Tạo mới", 
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          color: Color.fromARGB(255,0, 108, 183),
                        ),
                      ]
                    )
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  _createItem(String newID) {
    UserMeetingOutput userNew = new UserMeetingOutput();
    userNew.id = newID;
    userNew.name = newID;
    userNew.selected = true;
    userNew.type = constants.TYPE_OTHER;

    listUser.add(userNew);
    widget.meetingBloc.updateUserListMeetingOrigin(listUser);
    widget.meetingBloc.addNewUser(userNew);
    stringList.add(userNew.id);
  }

  _onSearchList(txtSearch) {
    widget.meetingBloc.searchUser(txtSearch, stringList);
  }

  handleSelected(value, index, list) {
    for (var i = 0; i < list.length; i++) {
      if (i == index) {
        list[i].selected = value;
        if(value == false) {
          for(var j = 0; j < stringList.length; j++) {
            if(stringList[j].toString() == list[i].id) {
              stringList.remove(stringList[j]);
              break;
            }
          }
        } else {
          for(var j = 0; j < stringList.length; j++) {
            if(stringList[j].toString() == list[i].id) {
              return list;
            }
          }
          stringList.add(list[i].id);
        }
        return list;
      }
    }
    return list;
  }
}
