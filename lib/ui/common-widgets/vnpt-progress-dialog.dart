import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class VNPTProgressDialog {
  late ProgressDialog pr;
  VNPTProgressDialog(BuildContext _context) {
    pr = new ProgressDialog(_context, isDismissible: false);
    pr.style(
      message: 'Vui lòng đợi...',
    );
  }
  show() async {
    await pr.show();
  }

  hide() async {
    Future.delayed(Duration(milliseconds: 200)).then((value) {
      pr.hide();
    });
  }
}
