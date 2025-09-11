import 'dart:ui';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/ui/home/meeting/page-approved.dart';
import 'package:nmeeting/ui/home/meeting/page-watting-approve.dart';
import 'package:flutter/material.dart';
import 'package:nmeeting/configs/constants.dart' as constants;

class PageMeeting extends StatefulWidget {
  final MeetingBloc meetingBloc;
  final int pageIndex;

  PageMeeting({Key key, @required this.meetingBloc, @required this.pageIndex})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageMeetingState();
}

class _PageMeetingState extends State<PageMeeting>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool isChangedTabByTabOnProgress = false;
  bool selectAllFlg = true;
  bool showBtn = false;

  @override
  void initState() {
    if (widget.pageIndex != constants.PAGE_METTING) {
      return;
    }
    super.initState();
    // this._checkRolePage();
    // this._getRolePage();
    // widget.meetingBloc.tabCurrentNameStream.listen((onData) {
    //   setState(() {
    //     selectAllFlg = true;
    //   });
    // });

    // widget.meetingBloc.meetingCountStream.listen((onData) {
    //   if (onData != null && onData > 0) {
    //     setState(() {
    //       showBtn = true;
    //     });
    //   } else {
    //     setState(() {
    //       showBtn = false;
    //     });
    //   }
    //   setState(() {
    //     selectAllFlg = true;
    //   });
    // });
    // widget.meetingBloc.onSetTabCurrentName(constants.TAB_WAITING);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // if view document by progress
  void onTabProgress() {
    isChangedTabByTabOnProgress = true;
    _tabController.index = 1;
    isChangedTabByTabOnProgress = false;
  }

  // _checkRolePage() {
  //   NetworkCheck _networkCheck = NetworkCheck();
  //   _networkCheck.check().then((isConnected) async {
  //     if (isConnected) {
  //       widget.meetingBloc.checkRolePage(
  //         constants.PAGE_ID_FOR_APP,
  //         constants.PAGE_NM_FOR_APP,
  //         constants.BTN_ALL_TO_SAVE_CONTROL
  //       );
  //     }
  //   });
  // }

  // _getRolePage() {
  //   NetworkCheck _networkCheck = NetworkCheck();
  //   _networkCheck.check().then((isConnected) async {
  //     if (isConnected) {
  //       final prefs = await SharedPreferences.getInstance();
  //       widget.meetingBloc.getRolePage(prefs.getString('roleid'), constants.PAGE_ID_FOR_APP);
  //     }
  //   });
  // }

  _setTabCurrent(index) {
    String tabNm = constants.TAB_WAITING;
    if (index == 1) {
      tabNm = constants.TAB_APPROVED;
    }
    widget.meetingBloc.onSetTabCurrentName(tabNm);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pageIndex != constants.PAGE_METTING) {
      return Container();
    }
    final TargetPlatform platform = Theme.of(context).platform;
    _tabController =
        _tabController ?? new TabController(length: 2, vsync: this);
    return Container(
      color: Colors.redAccent,
      child: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(36),
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Expanded(child: Container()),
                    Material(
                      color: Colors.white,
                      elevation: 0,
                      shadowColor: Color(0x802196F3),
                      child: TabBar(
                        controller: _tabController,
                        labelPadding: EdgeInsets.only(bottom: 10),
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            width: 5,
                            color: Color.fromARGB(255, 0, 108, 183),
                          ),
                          insets: EdgeInsets.symmetric(horizontal: 15),
                        ),
                        unselectedLabelColor: Color.fromARGB(255, 0, 0, 128),
                        labelColor: Color.fromARGB(255, 0, 0, 128),
                        tabs: [
                          Text(
                            'Đăng ký',
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            'Đã duyệt',
                            style: TextStyle(fontSize: 17),
                          )
                        ],
                        onTap: (_index) {
                          widget.meetingBloc
                              .onSetKeepAliveForAdminWebViewTabController(true);
                          print('Tab Changes to index $_index');
                          this._setTabCurrent(_index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                PageWaittingApprove(
                    onTabProgress: onTabProgress,
                    meetingBloc: widget.meetingBloc),
                PageApproved(
                    platform: platform, meetingBloc: widget.meetingBloc)
              ],
              controller: _tabController,
            ),
          ),
        ),
      ),
    );
  }
}
