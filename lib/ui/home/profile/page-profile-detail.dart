import 'package:cached_network_image/cached_network_image.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:nmeeting/bloc/profileBloc.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/common-widgets.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-progress-dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nmeeting/configs/constants.dart' as constants;
import 'package:nmeeting/configs/error-message.dart' as errorMessage;

class PageProfileDetail extends StatefulWidget {
  final ProfileBloc bloc;
  PageProfileDetail({Key key, @required this.bloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageProfileDetailState();
  }
}

class _PageProfileDetailState extends State<PageProfileDetail> {
  String _selectedUnitValues;
  int _selectedGenderValues;

  final _textNameFieldController = TextEditingController();
  final _textBirthdayFieldController = TextEditingController();
  final _textEmailFieldController = TextEditingController();
  final _textPhoneFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initValue();
  }

  initValue() async {
    final prefs = await SharedPreferences.getInstance();
    _textNameFieldController.text = prefs.getString('fullname');

    final _birthday = prefs.getString('user_birthday');
    if (!StringUtils.isNullOrEmpty(_birthday)) {
      _textBirthdayFieldController.text =
          DateFormat(constants.DATE_FORMAT_CLIENT)
              .format(DateTime.tryParse(_birthday));
    }

    // _selectedGenderValues = prefs.getInt('user_gender');
    _textEmailFieldController.text = prefs.getString('user_email');
    // _selectedUnitValues = prefs.getString('user_unitID');
    _textPhoneFieldController.text = '${prefs.getString('user_phone')}';

    // widget.bloc.getDetailInfoStream();
  }

  _uploadAvatar(VNPTProgressDialog _vnptProgress) async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile == null) {
      return;
    }

    NetworkCheck _networkCheck = NetworkCheck();
    _networkCheck.check().then((isConnected) {
      if (isConnected) {
        _vnptProgress.show();

        final res = widget.bloc.uploadAvatar(imageFile);
        res.then((res) async {
          print(res);
          if (res.status == 1) {
            widget.bloc.onChangedAvatarInput(res.data);
          }
          _vnptProgress.hide();
          showToast(res.msg);
        });
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _vnptProgress = VNPTProgressDialog(context);
    final _mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        // leading: BackButton(color: Colors.red),
        leading: GestureDetector(
          onTap: () {Navigator.of(context).pop();},
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Text('Huỷ', style: TextStyle(color: Colors.black, fontSize: 15)),
        ])
        ),
        title: Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
          onTap: () {
            if (widget.bloc.canSubmitCheck() == true) {
              NetworkCheck _networkCheck = NetworkCheck();
              _networkCheck.check().then((isConnected) {
                if (isConnected) {
                  _vnptProgress.show();
                  Future<TResult> _resultFuture = widget.bloc
                      .updateUserProfile();
                  _resultFuture.then((res) async {
                    await _vnptProgress.hide();
                    showToast(res.msg);
                    Future.delayed(Duration(milliseconds: 200)).then((onvalue) {
                      Navigator.of(context).pop();
                    });
                    
                  });
                } else {
                  showToast(errorMessage.networkError);
                }
              });
            } else {
              showToast('Vui lòng nhập đầy đủ thông tin');
            }
            
          },
          child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Text('Lưu', style: TextStyle(color: Color.fromARGB(255, 30, 37, 239), fontSize: 15)),
        ])
        ))
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: 
                Column(children: <Widget>[
                Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      StreamBuilder<String>(
                          stream: widget.bloc.avatarStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: !StringUtils.isNullOrEmpty(snapshot.data)
                                    ? CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                              Icons.error_outline,
                                              size: 80,
                                            ),
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        imageUrl: snapshot.data)
                                    : 
                                    Container(
                                    decoration: new BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [new BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 20.0
                                  )]
                                    ),
                                    child:
                                     CircleAvatar(
                                      radius: 43,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Color.fromARGB(255, 28, 126, 191),
                                      child: StreamBuilder<String>(
                                      stream: widget.bloc.nameStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData && snapshot.data != null && snapshot.data != '') {
                                          return Text((snapshot.data.toString()).substring(0, 1), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40));
                                        }
                                          return CircleAvatar(
                                          radius: 40,
                                          backgroundImage: AssetImage(
                                            'lib/assets/images/no-avatar.png'));
                                      }))
                                    ))
                              );
                            }
                            return CircularProgressIndicator();
                          }),
                      // Icon(
                      //   Icons.linked_camera,
                      //   color: Colors.green,
                      // ),
                    ],
                  ),

                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    _uploadAvatar(_vnptProgress);
                  },
                  child: Text('Đổi hình đại diện',
                  style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 30, 37, 239)),))
                ],)
                
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: _mediaQuery.size.width,
                height: 1,
                color: Colors.grey,
                margin:EdgeInsets.fromLTRB(0, 10, 0, 0)
              ),
              // Padding(child: Column(children: <Widget>[

              Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(children: <Widget>[

              // Name
              Row(children: <Widget>[
                new Expanded ( 
                  flex:1,
                  child : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[new Text("Tên", 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))],
                ),),
                new Expanded ( 
                  flex:2,
                  child : Column(
                  children: <Widget>[
                    StreamBuilder<String>(
                  stream: widget.bloc.nameInputStream,
                  builder: (context, snapshot) {
                    return TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 52, 52, 52),
                          fontWeight: FontWeight.normal),
                      decoration: InputDecoration(
                        errorText: snapshot.error,
                        errorStyle: CommonWidgets.textErrorStyle(),
                        contentPadding: EdgeInsets.only(bottom: -5),
                      ),
                      onChanged: (value) =>
                          widget.bloc.onChangedNameInput(value),
                      controller: _textNameFieldController,
                    );
                  })
                  ],
                ),)
              ],),

              // Phone number
              Row(children: <Widget>[
                new Expanded ( 
                  flex:1,
                  child : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[new Text("Số điện thoại", 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))],
                ),),
                new Expanded ( 
                  flex:2,
                  child : Column(
                  children: <Widget>[
                    StreamBuilder<String>(
                  stream: widget.bloc.phoneInputStream,
                  builder: (context, snapshot) {
                    return TextField(
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 52, 52, 52),
                          fontWeight: FontWeight.normal),
                      decoration: InputDecoration(
                        errorText: snapshot.error,
                        errorStyle: CommonWidgets.textErrorStyle(),
                        contentPadding: EdgeInsets.only(bottom: -5),
                      ),
                      onChanged: (value) =>
                          widget.bloc.onChangedPhoneInput(value),
                      controller: _textPhoneFieldController,
                    );
                  })
                  ],
                ),)
              ],),

              // email
              Row(children: <Widget>[
                new Expanded ( 
                  flex:1,
                  child : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[new Text("Email", 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))],
                ),),
                new Expanded ( 
                  flex:2,
                  child : Column(
                  children: <Widget>[

                  StreamBuilder<String>(
                  stream: widget.bloc.emailInputStream,
                  builder: (context, snapshot) {
                    return TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 52, 52, 52),
                          fontWeight: FontWeight.normal),
                      decoration: InputDecoration(
                        errorText: snapshot.error,
                        errorStyle: CommonWidgets.textErrorStyle(),
                        contentPadding: EdgeInsets.only(bottom: -5),
                      ),
                      onChanged: (value) =>
                          widget.bloc.onChangedEmailInput(value),
                      controller: _textEmailFieldController,
                    );
                  })
                  ],
                ),)
              ],),

              // Date of birth
              Row(children: <Widget>[
                new Expanded ( 
                  flex:1,
                  child : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[new Text("Ngày sinh", 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))],
                ),),
                new Expanded ( 
                  flex:2,
                  child : Column(
                  children: <Widget>[

                    GestureDetector(
                onTap: () {
                  var res = showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
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
                        _textBirthdayFieldController.text =
                            DateFormat(constants.DATE_FORMAT_CLIENT)
                                .format(onValue);
                      });
                      widget.bloc.onChangedBirthdayInput(onValue.toString());
                    }
                  });
                },
                child: AbsorbPointer(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 52, 52, 52),
                        fontWeight: FontWeight.normal),
                    controller: _textBirthdayFieldController,
                  ),
                ),
              ),
                  ],
                ),)
              ],),

              // StreamBuilder<List<DropdownMenuItem<int>>>(
              //     stream: widget.bloc.genderListStream,
              //     builder: (context, snapshot) {
              //       return DropdownButton<int>(
              //         isExpanded: true,
              //         underline: Container(
              //           height: 1,
              //           color: Colors.grey,
              //         ),
              //         items: snapshot.hasData ? snapshot.data : [],
              //         value: _selectedGenderValues,
              //         onChanged: (int value) {
              //           setState(() => _selectedGenderValues = value);
              //           print(_selectedGenderValues);
              //         },
              //         hint: Text('Chọn giới tính',
              //             style: TextStyle(
              //                 fontSize: 22,
              //                 color: Colors.black54,
              //                 fontWeight: FontWeight.bold)),
              //       );
              //     }),
              // Text(
              //   'Giới tính',
              //   style: TextStyle(fontSize: 16),
              // ),
              ],),)
              // Container(
              //   padding: EdgeInsets.only(top: 10, bottom: 10),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: <Widget>[
              //       StreamBuilder<bool>(
              //           stream: widget.bloc.submitCheck,
              //           builder: (context, snapshot) {
              //             return MaterialButton(
              //               disabledElevation: 1,
              //               disabledColor: Colors.black45,
              //               onPressed: () {
              //                 if (snapshot.data == null) {
              //                   return;
              //                 }

              //                 NetworkCheck _networkCheck = NetworkCheck();
              //                 _networkCheck.check().then((isConnected) {
              //                   if (isConnected) {
              //                     _vnptProgress.show();
              //                     Future<TResult> _resultFuture = widget.bloc
              //                         .updateUserProfile(_selectedGenderValues,
              //                             _selectedUnitValues);
              //                     _resultFuture.then((res) async {
              //                       _vnptProgress.hide();
              //                       showToast(res.msg);
              //                     });
              //                   } else {
              //                     showToast(errorMessage.networkError);
              //                   }
              //                 });
              //               },
              //               child: Text(
              //                 'CẬP NHẬT',
              //                 style: TextStyle(
              //                     color: Colors.white,
              //                     fontSize: 20,
              //                     fontWeight: FontWeight.bold),
              //               ),
              //               color: Colors.red,
              //               minWidth: double.infinity,
              //               height: 50,
              //             );
              //           }),
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
