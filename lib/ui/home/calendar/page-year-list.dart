import 'package:flutter/material.dart';

class PageYearList extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const PageYearList(
      {Key? key,
      required this.selectedDate,
      required this.firstDate,
      required this.lastDate})
      : super(key: key);

  @override
  _PageYearList createState() => _PageYearList();
}

class _PageYearList extends State<PageYearList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          for (var i = widget.firstDate.year; i <= widget.lastDate.year; i++)
            GestureDetector(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: i == widget.selectedDate.year
                    ? Text(
                        i.toString(),
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      )
                    : Text(
                        i.toString(),
                        style: TextStyle(fontSize: 22),
                      ),
              ),
              onTap: () {
                Navigator.pop(context, i);
              },
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
