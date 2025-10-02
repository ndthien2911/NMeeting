import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nmeeting/base/platform-info.dart';
import 'package:nmeeting/bloc/loginBloc.dart';
import 'package:nmeeting/bloc/configBloc.dart';
import 'package:nmeeting/configs/api-endpoint.dart' as api;
import 'package:nmeeting/configs/error-message.dart' as errorMessage;
import 'package:nmeeting/models/t-result.dart';
import 'package:nmeeting/ui/common-widgets/common-widgets.dart';
import 'package:nmeeting/ui/common-widgets/vnpt-progress-dialog.dart';
import 'package:nmeeting/ui/home/page-home.dart';
import 'package:nmeeting/ui/router/app-router.dart';
import 'package:nmeeting/utilities/network-check.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

var countUrlLogoutLoad = 1;
var urlLoginPre = api.URL_WEB_CLIENT + '/login?';

class PageLogin extends StatefulWidget {
  const PageLogin({Key? key}) : super(key: key);

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final LoginBloc _loginBloc = LoginBloc();
  final ConfigBloc _configBloc = ConfigBloc();
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  late SharedPreferences prefs;

  bool isLoginMail = false;
  bool isLoggedIn = false;

  late final WebViewController _webController;

  @override
  void initState() {
    super.initState();
    String imeicode = PlatformInfo.getDeviceId();
    _loginBloc.onSetIMEICode(imeicode);
    _clearPrefs();
    getToken();
    _configBloc.getUnitUsed();
  }

  getToken() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.instance.getToken().then((value) async {
      print('firebaseMessaging.getToken: ' + value!);
      _loginBloc.onSetTokenDevice(value);
    });
  }

  _clearPrefs() async {
    prefs = await SharedPreferences.getInstance();
    String calendarFilter =
        prefs.getString('calendarSelectedFilterValue') ?? '';
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
    await prefs.clear();
    prefs.setString('calendarSelectedFilterValue', calendarFilter);
  }

  @override
  void dispose() {
    _nodeText1.dispose();
    _nodeText2.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
          toolbarButtons: [
            (node) => GestureDetector(
                  onTap: () => node.unfocus(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.close),
                  ),
                )
          ],
        ),
        KeyboardActionsItem(
          focusNode: _nodeText2,
          onTapAction: _login,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    final TargetPlatform platform = Theme.of(context).platform;

    double logoSize = 180;
    if (_mediaQuery.size.width >= 600 && _mediaQuery.size.width < 800)
      logoSize = 220;
    if (_mediaQuery.size.width >= 800) logoSize = 250;

    // Nếu login mail hoặc đã login => mở WebView
    if (isLoginMail || isLoggedIn) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
          appBar: AppBar(leading: const BackButton(color: Colors.black)),
          body: KeyboardActions(
            config: _buildConfig(context),
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onNavigationRequest: (request) {
                      if (request.url.startsWith(urlLoginPre)) {
                        _loginEmail(request.url);
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    },
                    onPageFinished: (url) {
                      if (url.startsWith('https://id.vnpt.com.vn/cas/logout')) {
                        if (countUrlLogoutLoad == 2 ||
                            platform == TargetPlatform.iOS) {
                          prefs.setBool('isLoggedIn', false);
                          setState(() {
                            isLoginMail = false;
                            isLoggedIn = false;
                          });
                          countUrlLogoutLoad = 1;
                        } else {
                          countUrlLogoutLoad++;
                        }
                      }
                    },
                  ),
                )
                ..loadRequest(Uri.parse(
                    isLoginMail ? api.URL_LOGIN_BY_MAIL : api.URL_LOGOUT)),
            ),
          ),
        ),
      );
    }

    // Màn hình login thường
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: KeyboardActions(
        config: _buildConfig(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'lib/assets/images/login-logo.png',
                width: logoSize + 70,
                height: logoSize,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 20),
              Text(
                'N-Meeting',
                style: TextStyle(
                  fontSize: _mediaQuery.size.width < 400 ? 25 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Đăng nhập tài khoản của bạn',
                style: TextStyle(
                  fontSize: _mediaQuery.size.width < 400 ? 17 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(35, 20, 35, 0),
                child: StreamBuilder<String>(
                  stream: _loginBloc.usernameStream,
                  builder: (context, snapshot) {
                    return TextField(
                      keyboardType: TextInputType.text,
                      enableSuggestions: false,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 30, 37, 239)),
                      focusNode: _nodeText1,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: 'Tên đăng nhập',
                        hintStyle: const TextStyle(fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        errorText:
                            snapshot.hasError ? '${snapshot.error}' : null,
                        errorStyle: CommonWidgets.textErrorStyle(),
                      ),
                      onChanged: _loginBloc.onUsernameChanged,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(35, 15, 35, 0),
                child: StreamBuilder<String>(
                  stream: _loginBloc.passwordStream,
                  builder: (context, snapshot) {
                    return TextField(
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 30, 37, 239)),
                      focusNode: _nodeText2,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 30, 37, 239)),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        hintText: 'Mật khẩu',
                        hintStyle: const TextStyle(fontSize: 16),
                        border: CommonWidgets.outlineInputBorder(),
                        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        errorText: snapshot.hasError
                            ? snapshot.error as String?
                            : null,
                        errorStyle: CommonWidgets.textErrorStyle(),
                      ),
                      onChanged: _loginBloc.onPasswordChanged,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: const StadiumBorder(),
                    backgroundColor: const Color.fromARGB(255, 0, 167, 0),
                  ),
                  onPressed: _login,
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              StreamBuilder<String>(
                stream: _configBloc.unitUsedStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == 'VTTP') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: const StadiumBorder(),
                          backgroundColor:
                              const Color.fromARGB(255, 66, 133, 244),
                        ),
                        icon: const Icon(Icons.mail, size: 20),
                        label: const Text(
                          'Đăng nhập bằng Mail VNPT',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _onPressLoginEmail,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (isLoginMail) {
      setState(() => isLoginMail = false);
      return false;
    }
    return true;
  }

  void _loginEmail(String url) {
    NetworkCheck().check().then((isConnected) {
      if (isConnected) {
        url = url.replaceAll(urlLoginPre, '');
        url = url.replaceAll('userName=', '');
        url = url.replaceAll('password=', '');
        var parts = url.split('&');
        if (parts.length == 2) {
          _loginBloc.onUsernameChanged(parts[0]);
          _loginBloc.onPasswordChanged(parts[1]);
          _login();
        }
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  void _onPressLoginEmail() {
    NetworkCheck().check().then((isConnected) {
      if (isConnected) {
        setState(() => isLoginMail = true);
      } else {
        showToast(errorMessage.networkError);
      }
    });
  }

  void _login() {
    if (_loginBloc.isValidInput()) {
      NetworkCheck().check().then((isConnected) {
        if (isConnected) {
          final progress = VNPTProgressDialog(context);
          progress.show();
          _loginBloc.onLogin().then((res) async {
            progress.hide();
            if (res.status == 1) {
              prefs.setBool('isLoggedIn', true);
              Future.delayed(const Duration(milliseconds: 300)).then((_) {
                AppRouter.navigatorKey.currentState!
                    .pushNamed(AppRouter.PAGE_HOME);
              });
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
}
