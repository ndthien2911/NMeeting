class NotifyInput {
  final String personalID;
  final String? username;

  NotifyInput({required this.personalID, this.username});

  Map toJson() => {'PersonalID': personalID, 'UserName': username};
}

class NotifyObj {
  final String id;
  final String meetingID;
  final String officeID;
  final String newsID;
  final String description;
  final bool seenFlg;
  final int type;
  final int action;
  final String tagID;
  final String createAt;
  final bool titleDtFlg;
  final WebviewObj? webviewObj;
  final int groupID;

  NotifyObj(
      {required this.id,
      required this.meetingID,
      required this.officeID,
      required this.newsID,
      required this.description,
      required this.seenFlg,
      required this.type,
      required this.action,
      required this.tagID,
      required this.createAt,
      required this.titleDtFlg,
      this.webviewObj,
      required this.groupID});

  factory NotifyObj.fromJson(Map<String, dynamic> json) {
    return NotifyObj(
        id: json['ID'],
        meetingID: json['MeetingID'],
        officeID: json['OfficeID'],
        newsID: json['NewsID'],
        description: json['Description'],
        seenFlg: json['SeenFlg'],
        type: json['Type'],
        action: json['Action'],
        tagID: json['TagID'],
        createAt: json['CreateAt'],
        titleDtFlg: json['TitleDtFlg'],
        webviewObj: json['WebviewObj'] != null
            ? new WebviewObj(
                title: json['WebviewObj']['Title'],
                url: json['WebviewObj']['Url'])
            : null,
        groupID: json['GroupID']);
  }

  Map toJson() => {
        'ID': id,
        'Description': description,
        'SeenFlg': seenFlg,
        'Type': type,
        'Action': action,
        'TagID': tagID,
        'CreateAt': createAt,
        'TitleDtFlg': titleDtFlg,
        'WebviewObj': webviewObj,
        'GroupID': groupID
      };
}

class WebviewObj {
  String title;
  String url;

  WebviewObj({required this.title, required this.url});

  factory WebviewObj.fromJson(Map<String, dynamic> json) {
    return WebviewObj(title: json['Title'], url: json['Url']);
  }

  Map toJson() => {'Title': title, 'Url': url};
}

class NotifyDay {
  final String createAt;
  final List<NotifyObj> notifyListDay;

  NotifyDay({required this.createAt, required this.notifyListDay});

  factory NotifyDay.fromJson(Map<String, dynamic> json) {
    return NotifyDay(
        createAt: json['CreateAt'],
        notifyListDay: json['NotifyListDay'].map<NotifyObj>((event) {
          return NotifyObj.fromJson(event);
        }).toList());
  }

  Map toJson() => {'CreateAt': createAt, 'NotifyListDay': notifyListDay};
}

class NotifyResGroup {
  final int notifyCnt;
  final List<NotifyDay> notifyList;

  NotifyResGroup({required this.notifyCnt, required this.notifyList});

  factory NotifyResGroup.fromJson(Map<String, dynamic> json) {
    return NotifyResGroup(
        notifyCnt: json['NotifyCnt'],
        notifyList: json['Notify'].map<NotifyDay>((event) {
          return NotifyDay.fromJson(event);
        }).toList());
  }

  Map toJson() => {'notifyCnt': notifyCnt, 'notifyList': notifyList};
}

class NotifyRes {
  final int notifyCnt;
  final List<NotifyObj> notifyList;

  NotifyRes({required this.notifyCnt, required this.notifyList});

  factory NotifyRes.fromJson(Map<String, dynamic> json) {
    return NotifyRes(
        notifyCnt: json['NotifyCnt'],
        notifyList: json['Notify'].map<NotifyObj>((event) {
          return NotifyObj.fromJson(event);
        }).toList());
  }

  Map toJson() => {'notifyCnt': notifyCnt, 'notifyList': notifyList};
}

class NotifyByMeetingIdsInput {
  final String meetingIDs;

  NotifyByMeetingIdsInput({required this.meetingIDs});

  Map toJson() => {'meetingIDs': meetingIDs};
}
