import 'dart:convert';

class CommonUtils {
  static bool checkRole(String btnName, String rolepage) {
   if(rolepage != null && rolepage != "") {
      List<dynamic> stringList = jsonDecode(rolepage);
      for(var i = 0; i < stringList.length; i++) {
        if(btnName == stringList[i].toString()) {
          return true;
        }
      }
    }

    return false;
  }
}
