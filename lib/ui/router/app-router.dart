import 'package:flutter/material.dart';
import 'package:nmeeting/ui/home/page-home.dart';
import 'package:nmeeting/ui/login/page-login.dart';
import 'package:nmeeting/ui/router/custom-page-router.dart';

class AppRouter {
  static const PAGE_HOME = '/PageHome';
  static const PAGE_LOGIN_SELECTION = '/PageLoginSelection';
  static const PAGE_LOGIN = '/PageLogin';
  static const PAGE_WEBVIEW_DEFAULT = '/PageWebviewDefault';
  static const PAGE_WEBVIEW_IMAGE = '/PageWebviewImage';
  static const PAGE_SETTING = '/PageSetting';
  static const PAGE_DOCUMENT_VIEWER = '/PageDocumentViewer';
  static const PAGE_CHANGE_PASSWORD = '/PageChangePassword';
  static const PAGE_MAPS = '/PageMaps';
  static const PAGE_QRSCAN = '/PageQRScan';
  static const PAGE_REGISTER = '/PageRegister';
  static const PAGE_LOGIN_QR_SCAN = '/PageLoginQRScan';
  static const PAGE_FORGOT_PASSWORD = '/PageForgotPassword';
  static const PAGE_RESET_PASSWORD = '/PageResetPassword';
  static const PAGE_UPDATE_STATUS = '/PageUpdateStatus';
  static const PAGE_USER_INFO = '/PageUserInfo';
  static const PAGE_USER_INFO_UPDATE = '/PageUserInfoUpdate';
  static const PAGE_WAITING_APPROVE_REPORT_LIST =
      '/PageWaitingApproveReportList';
  static const PAGE_APPROVED_REPORT_LIST = '/PageApprovedReportList';
  static const PAGE_WAITING_REPORT_LIST = '/PageWaitingReportList';
  static const PAGE_REPORT_DETAIL = '/PageReportDetail';
  static const PAGE_EXCEL_TABLE = '/PageExcelTable';
  static const PAGE_NOTIFY_LIST = '/PageNotifyList';

  static final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PAGE_HOME:
        return CustomPageRouter(
          page: PageHome(),
        );
      case PAGE_LOGIN:
        return CustomPageRouter(
          page: PageLogin(),
        );

      default:
        return throw Exception('No router matching');
    }
  }

  static bool isCurrent(String routeName) {
    bool isCurrent = false;
    navigatorKey.currentState!.popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }
}
