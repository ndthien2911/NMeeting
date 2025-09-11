import 'package:flutter/material.dart';
import 'package:nmeeting/bloc/loginBloc.dart';
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/common-widgets.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-dialog.dart';

class PageForgotPassword extends StatefulWidget {
  final LoginBloc loginBloc;

  PageForgotPassword({Key? key, required this.loginBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageForgotPasswordState();
  }
}

class _PageForgotPasswordState extends State<PageForgotPassword> {
  final _emailInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
          padding: EdgeInsets.only(left: 20, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Quên mật khẩu',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Hãy nhập địa chỉ email của bạn. Bạn sẽ nhận được mật khẩu mới qua email',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 25, 30, 0),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(primaryColor: Color.fromARGB(255, 30, 37, 239)),
                  child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 30, 37, 239)),
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 30, 37, 239)),
                              borderRadius: BorderRadius.circular(25)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(),
                              borderRadius: BorderRadius.circular(25)),
                          hintText: 'Email',
                          hintStyle: TextStyle(fontSize: 16),
                          border: CommonWidgets.outlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          errorStyle: CommonWidgets.textErrorStyle()),
                      onChanged: (value) => null,
                      controller: _emailInputController),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(80, 40, 80, 0),
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 29, 40, 238),
                      Color.fromARGB(255, 16, 113, 230)
                    ],
                  ),
                ),
                child: MaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                  minWidth: double.infinity,
                  height: 50,
                  child: Text(
                    'Gửi',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _sendRefreshPassword(_emailInputController.text);
                  },
                ),
              )
            ],
          )),
    );
  }

  _sendRefreshPassword(String email) {
    Future<TResult> _resultFuture = widget.loginBloc.onRefreshPassword(email);
    _resultFuture.then((res) async {
      int type = res.status;
      String mes = res.msg;

      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return VNPTDialog(
            type: (type == 1) ? VNPTDialogType.success : VNPTDialogType.warning,
            title: (type == 1) ? "Success" : "Warning",
            description: mes,
            actions: <Widget>[
              SizedBox(
                width: 134,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 108, 183),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Color.fromARGB(255, 0, 108, 183)),
                    ),
                  ),
                  child: Text(
                    "Đồng ý",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (type == 1) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
