import 'dart:convert';

import 'package:intl/intl.dart';

class StringUtils {
  static RegExp _numeric = RegExp(r'^-?[0-9]+$');
  static RegExp _email = RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");
  static RegExp _alpha = RegExp(r'^[a-zA-Z]+/\s/$');
  static RegExp _alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
  // static RegExp _vietnamphone = RegExp(r'((09|03|07|08|05|9|3|7|8|5)+([0-9]{8})\b)');
  static RegExp _vietnamphone = RegExp(r'(^(?:[+0]8)?[0-9]{10}$)');
  static RegExp _surrogatePairsRegExp =
      RegExp(r'[\uD800-\uDBFF][\uDC00-\uDFFF]');

  /// check if the string is null
  static bool isNullOrEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  /// check if the string matches the comparison
  static bool equals(String str, comparison) {
    return str == comparison.toString();
  }

  /// check if the string contains the substring
  static bool contains(String str, substring) {
    return str.contains(substring);
  }

  /// check if the string contains only numbers
  static bool isNumeric(String str) {
    return _numeric.hasMatch(str);
  }

  /// check if the string contains only letters (a-zA-Z).
  static bool isAlpha(String str) {
    return _alpha.hasMatch(str);
  }

  /// check if the string contains only letters and numbers
  static bool isAlphanumeric(String str) {
    return _alphanumeric.hasMatch(str);
  }

  /// check if the string is an email
  static bool isEmail(String str) {
    return _email.hasMatch(str.toLowerCase());
  }

  /// check if the string's length falls in a range
  /// If no max is given then any length above min is ok.
  ///
  /// Note: this function takes into account surrogate pairs.
  static bool isLength(String str, int min, [int? max]) {
    List surrogatePairs = _surrogatePairsRegExp.allMatches(str).toList();
    int len = str.length - surrogatePairs.length;
    return len >= min && (max == null || len <= max);
  }

  /// check if the string is a date
  static bool isDate(String str) {
    try {
      DateTime.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// check if the string is a date that's after the specified date
  ///
  /// If `date` is not passed, it defaults to now.
  static bool isAfter(String str, [date]) {
    if (date == null) {
      date = DateTime.now();
    } else if (isDate(date)) {
      date = DateTime.parse(date);
    } else {
      return false;
    }

    DateTime strdate;
    try {
      strdate = DateTime.parse(str);
    } catch (e) {
      return false;
    }

    return strdate.isAfter(date);
  }

  /// check if the string is a date that's before the specified date
  ///
  /// If `date` is not passed, it defaults to now.
  static bool isBefore(String str, [date]) {
    if (date == null) {
      date = DateTime.now();
    } else if (isDate(date)) {
      date = DateTime.parse(date);
    } else {
      return false;
    }

    DateTime strdate;
    try {
      strdate = DateTime.parse(str);
    } catch (e) {
      return false;
    }

    return strdate.isBefore(date);
  }

  /// check if the string is in an array of allowed values
  static bool isIn(String str, values) {
    if (values == null || values.length == 0) {
      return false;
    }

    if (values is List) {
      values = values.map((e) => e.toString()).toList();
    }

    return values.indexOf(str) >= 0;
  }

  /// check if the string is phone number
  static bool isVietnamPhone(String str) {
    return _vietnamphone.hasMatch(str);
  }

  // parse time to date format

  // input "2020-05-04T00:00:00; format string
  // output by fotmat
  static String convertTimeFromString(time, formatType) {
    if (time == null || time == "") {
      return "";
    }
    // String formatType = 'hh:mm dd/MM/YYYY';
    var date = DateTime.parse(time);
    int numDate = date.day;
    String strDate =
        numDate < 10 ? "0" + numDate.toString() : numDate.toString();
    int numMonth = date.month;
    String strMonth =
        numMonth < 10 ? "0" + numMonth.toString() : numMonth.toString();
    String strYear = date.year.toString();
    int hours = date.hour;
    String strHours = hours > 9 ? hours.toString() : "0" + hours.toString();
    int minutes = date.minute;
    String strMinutes =
        minutes > 9 ? minutes.toString() : "0" + minutes.toString();
    if (formatType == "hh:mm dd/MM/YYYY")
      return (strHours +
          ':' +
          strMinutes +
          ' ' +
          strDate +
          '/' +
          strMonth +
          '/' +
          strYear);
    else if (formatType == "dd/MM/YYYY") {
      return (strDate + '/' + strMonth + '/' + strYear);
    } else if (formatType == "dd/MM") {
      return (strDate + '/' + strMonth);
    } else if (formatType == "YYYY-MM-dd") {
      return (strYear + '-' + strMonth + '-' + strDate);
    } else if (formatType == "dd/MM/YYYY hh:mm") {
      return (strDate +
          '/' +
          strMonth +
          '/' +
          strYear +
          ' ' +
          strHours +
          ':' +
          strMinutes);
    } else if (formatType == "dd/MM/YYYY - hh:mm") {
      return (strDate +
          '/' +
          strMonth +
          '/' +
          strYear +
          ' - ' +
          strHours +
          ':' +
          strMinutes);
    } else if (formatType == "hh:mm") {
      return (strHours + ':' + strMinutes);
    } else if (formatType == "YYYYMMDDHHMM") {
      return (strYear + strMonth + strDate + strHours + strMinutes);
    } else if (formatType == 'yyyy-MM-dd HH:mm:ss') {
      return (strYear +
          '-' +
          strMonth +
          '-' +
          strDate +
          ' ' +
          strHours +
          ':' +
          strMinutes +
          ':00');
    } else {
      return "";
    }
  }

  static String calculateTimeBefore(createAt) {
    DateTime createTime = DateTime.parse(createAt);
    Duration duration = DateTime.now().difference(createTime);
    const YEAR_MILISECOND = 365 * 24 * 60 * 60 * 1000;
    const MONTH_MILISECOND = 30 * 24 * 60 * 60 * 1000;
    const DAY_MILISECOND = 1 * 24 * 60 * 60 * 1000;
    const HOUR_MILISECOND = 1 * 60 * 60 * 1000;
    const MINUTE_MILISECOND = 1 * 60 * 1000;
    var timeString = "";

    if (duration.inMilliseconds > YEAR_MILISECOND) {
      timeString =
          (duration.inMilliseconds / YEAR_MILISECOND).round().toString() +
              ' ' +
              'năm';
    } else if (duration.inMilliseconds > MONTH_MILISECOND) {
      timeString =
          (duration.inMilliseconds / MONTH_MILISECOND).round().toString() +
              ' ' +
              'tháng';
    } else if (duration.inMilliseconds > DAY_MILISECOND) {
      timeString =
          (duration.inMilliseconds / DAY_MILISECOND).round().toString() +
              ' ' +
              'ngày';
    } else if (duration.inMilliseconds > HOUR_MILISECOND) {
      timeString =
          (duration.inMilliseconds / HOUR_MILISECOND).round().toString() +
              ' ' +
              'giờ';
    } else if (duration.inMilliseconds > MINUTE_MILISECOND) {
      timeString =
          (duration.inMilliseconds / MINUTE_MILISECOND).round().toString() +
              ' ' +
              'phút';
    } else {
      timeString = 'Vừa xong';
    }

    if (timeString != "" && timeString != 'Vừa xong') {
      timeString = timeString + ' trước';
    }

    return timeString;
  }

  static String convertListToString(List<Object> list) {
    return jsonEncode(list);
  }

  static List<Object> convertStringToList(String listStr) {
    return jsonDecode(listStr);
  }

  static List<String> convertStringToListWithCharacter(
      String listStr, String character) {
    List<String> list = [];

    if (listStr != null) {
      list = listStr.split(character);
    }

    return list;
  }

  static String convertListToStringWithCharacter(
      List<String> list, String character) {
    String listNm = "";

    for (var i = 0; i < list.length; i++) {
      if (listNm == "") {
        listNm = list[i];
      } else {
        listNm = listNm + character + " " + list[i];
      }
    }

    return listNm;
  }

  static String convertDayToString(String date, [isMMDD = false]) {
    DateTime createTime = DateTime.parse(date);

    String stringCurDt = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String stringCreDt = DateFormat("yyyy-MM-dd").format(createTime);
    if (stringCurDt == stringCreDt) {
      return "Hôm nay";
    }
    if (isMMDD == true) {
      return DateFormat.MMMMd("vi_VN").format(createTime);
    }
    return DateFormat.yMMMMd("vi_VN").format(createTime);
  }

  static String convertDateToShortString(DateTime createTime) {
    // DateTime createTime = DateTime.parse(date);
    var timeString = DateFormat.MMMMd().format(createTime);
    return timeString;
  }

  static String getDateTimeInNotify(String createAt) {
    DateTime createTime = DateTime.parse(createAt);

    String stringCurDt = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String stringCreDt = DateFormat("yyyy-MM-dd").format(createTime);
    if (stringCurDt == stringCreDt) {
      return StringUtils.calculateTimeBefore(createAt);
    }

    return DateFormat.jms().format(createTime);
  }

  static String convertFormatD2(int hour, int minute) {
    String time = "";
    if (hour < 10 && minute < 10) {
      time = '0$hour : 0$minute';
    } else if (hour < 10 && minute >= 10) {
      time = '0$hour : $minute';
    } else if (hour >= 10 && minute < 10) {
      time = '$hour : 0$minute';
    } else {
      time = '$hour : $minute';
    }

    return time;
  }

  static String getWeekday(datetime) {
    // String formatType = 'hh:mm dd/MM/YYYY';
    var date = DateTime.parse(datetime);
    dynamic dayData =
        '{ "1" : "T2", "2" : "T3", "3" : "T4", "4" : "T5", "5" : "T6", "6" : "T7", "7" : "CN"}';
    return json.decode(dayData)['${date.weekday}'];
  }
}
