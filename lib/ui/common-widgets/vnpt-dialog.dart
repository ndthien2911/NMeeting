import 'package:flutter/material.dart';

enum VNPTDialogType { question, success, warning, error, voting, normal }

class VNPTDialog extends StatelessWidget {
  final VNPTDialogType type;
  final String title;
  final String? description;
  final List<Widget>? actions;
  final Widget? descriptionWidget;
  final TextStyle? styleTitle;

  const VNPTDialog({
    key,
    required this.type,
    required this.title,
    this.description,
    this.actions,
    this.descriptionWidget,
    this.styleTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Material(
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          title,
                          style: styleTitle ??
                              const TextStyle(
                                fontSize: 25,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
                        if (description != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    description!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 52, 52, 52),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (descriptionWidget != null) descriptionWidget!,
                        const SizedBox(height: 15),
                        if (actions != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: actions!,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (type != VNPTDialogType.normal)
                Container(
                  alignment: Alignment.topCenter,
                  child: Image(
                    image: _buildIcon(),
                    width: 70,
                    height: 70,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  AssetImage _buildIcon() {
    switch (type) {
      case VNPTDialogType.question:
        return const AssetImage('lib/assets/icons/dialog-question.png');
      case VNPTDialogType.success:
        return const AssetImage('lib/assets/icons/dialog-success.png');
      case VNPTDialogType.warning:
        return const AssetImage('lib/assets/icons/dialog-warning.png');
      case VNPTDialogType.error:
        return const AssetImage('lib/assets/icons/dialog-error.png');
      case VNPTDialogType.voting:
        return const AssetImage('lib/assets/icons/dialog-voting.png');
      case VNPTDialogType.normal:
        throw Exception("VNPTDialogType.normal không có icon");
    }
  }
}
