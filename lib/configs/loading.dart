import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingConfig {
  static void init() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 3000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..maskType =   EasyLoadingMaskType.none
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.black
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.white
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = true;
  }
}