import 'package:flutter/material.dart';
import 'package:flutter_polygon/flutter_polygon.dart';

import 'package:nmeeting/bloc/in-meeting/in-meetingBloc.dart';
import 'package:nmeeting/bloc/meetingBloc.dart';
import 'package:nmeeting/bloc/notifyBloc.dart';
import 'package:nmeeting/models/notify.dart';
import 'package:nmeeting/ui/home/library/page-library-process-webview.dart';
import 'package:nmeeting/ui/home/meeting/page-meeting-detail.dart';
import 'package:nmeeting/ui/home/meeting/page-meeting-webview.dart';
import 'package:nmeeting/ui/home/page-webview-default.dart';
import 'package:nmeeting/ui/home/webview/page-news-webview.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:nmeeting/configs/constants.dart' as constants;

class PageNotification extends StatefulWidget {
  final NotifyBloc notifyBloc;

  const PageNotification({Key? key, required this.notifyBloc})
      : super(key: key);

  @override
  State<PageNotification> createState() => _PageNotificationState();
}

class _PageNotificationState extends State<PageNotification> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {});
    widget.notifyBloc.onGetNotifyList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _notifys(),
      backgroundColor: Colors.white,
    );
  }

  Widget _notifys() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: Color.fromARGB(255, 236, 237, 249)),
        ),
      ),
      child: StreamBuilder<List<NotifyObj>>(
        stream: widget.notifyBloc.notifyListStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final items = snapshot.data!;
            if (items.isEmpty) {
              return _nodata();
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  margin: item.titleDtFlg == true
                      ? const EdgeInsets.only(top: 10)
                      : EdgeInsets.zero,
                  color: Colors.white,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (item.titleDtFlg == true) return;
                      _openTargetPage(
                        item.meetingID,
                        item.webviewObj,
                        item.type,
                        item.action,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (item.titleDtFlg == true)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.topCenter,
                                child: Text(
                                  StringUtils.convertDayToString(item.createAt),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            if (item.titleDtFlg != true) ...[
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 10, 0),
                                alignment: Alignment.topCenter,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 10,
                                    width: 10,
                                    color: item.seenFlg != true
                                        ? const Color.fromARGB(255, 255, 0, 0)
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 10, 0),
                                alignment: Alignment.topCenter,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: ShapeDecoration(
                                        color: item.groupID == 1
                                            ? const Color.fromARGB(
                                                255, 251, 188, 5)
                                            : item.groupID == 2
                                                ? const Color.fromARGB(
                                                    255, 66, 133, 244)
                                                : item.groupID == 3
                                                    ? const Color.fromARGB(
                                                        255, 52, 168, 83)
                                                    : item.groupID == 4
                                                        ? const Color.fromARGB(
                                                            255, 8, 231, 194)
                                                        : const Color.fromARGB(
                                                            255, 234, 67, 53),
                                        shape: PolygonBorder(
                                          sides: 6,
                                          rotate:
                                              60, // giữ nguyên rotation như trước
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item.tagID ?? '',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.only(
                                        right: 10,
                                        bottom: 10,
                                      ),
                                      padding: const EdgeInsets.only(top: 10),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        item.description,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: item.seenFlg != true
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      StringUtils.getDateTimeInNotify(
                                          item.createAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            Color.fromARGB(255, 143, 143, 143),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (item.titleDtFlg != true &&
                            index + 1 < items.length &&
                            items[index + 1].titleDtFlg != true)
                          const Divider(
                            height: 1,
                            color: Color.fromARGB(255, 241, 243, 244),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _nodata() {
    return Container(
      alignment: Alignment.topCenter,
      child: const Column(
        children: <Widget>[
          SizedBox(height: 50),
          Image(
            image: AssetImage('lib/assets/images/no-data.png'),
            height: 68,
          ),
          SizedBox(height: 10),
          Text(
            'Không có thông báo nào',
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 123, 123, 123),
            ),
          ),
        ],
      ),
    );
  }

  void _openTargetPage(
    String meetingID,
    WebviewObj? webviewObj,
    int type,
    int action,
  ) {
    if (webviewObj != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PageWebviewDefault(url: webviewObj.url, title: webviewObj.title),
        ),
      );
    } else {
      if (type == 0) {
        if (action == constants.NOTIFY_APPROVE_MEETING ||
            action == constants.NOTIFY_REVERT_APPROVE_MEETING ||
            action == constants.NOTIFY_REJECT_MEETING ||
            action == constants.NOTIFY_MODIFY_APPROVE_MEETING ||
            action == constants.NOTIFY_REMINDER_MEETING) {
          final inMeetingBloc = InMeetingBloc();
          final meetingBloc = MeetingBloc();
          meetingBloc.onSetMeetingId(meetingID);
          inMeetingBloc.onSetMeetingId(meetingID);

          final TargetPlatform platform = Theme.of(context).platform;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageMeetingDetail(
                inmeetingBloc: inMeetingBloc,
                meetingBloc: meetingBloc,
                platform: platform,
              ),
            ),
          );
        }
      }
    }
  }
}
