class EventObj {
  String id;
  String name;
  String admin;
  String eventDate;
  String startAt;
  String endAt;
  int? reminderID;
  int? reminderVal;
  String? tagID;
  String? tagNm;
  int type;

  EventObj(
      {required this.id,
      required this.name,
      required this.admin,
      required this.eventDate,
      required this.startAt,
      required this.endAt,
      this.reminderID,
      this.reminderVal,
      this.tagID,
      this.tagNm,
      required this.type});

  factory EventObj.fromJson(Map<String, dynamic> json) {
    return EventObj(
      id: json['ID'],
      name: json['Name'],
      admin: json['Admin'],
      eventDate: json['EventDate'],
      startAt: json['StartAt'],
      endAt: json['EndAt'],
      reminderID: json['ReminderID'],
      reminderVal: json['ReminderVal'],
      tagID: json['TagID'],
      tagNm: json['TagNm'],
      type: json['Type'],
    );
  }
  Map toJson() => {
        'ID': id,
        'Name': name,
        'Admin': admin,
        'EventDate': eventDate,
        'StartAt': startAt,
        'EndAt': endAt,
        'ReminderID': reminderID,
        'ReminderVal': reminderVal,
        'TagID': tagID,
        'TagNm': tagNm,
        'Type': type,
      };
}

class EventTag {
  String id;
  String name;
  bool selected;

  EventTag({required this.id, required this.name, required this.selected});

  factory EventTag.fromJson(Map<String, dynamic> json) {
    return EventTag(
        id: json['ID'], name: json['Name'], selected: json['Selected']);
  }
  Map toJson() => {'ID': id, 'Name': name, 'Selected': selected};
}

class EventReminder {
  int id;
  int value;
  bool selected;

  EventReminder(
      {required this.id, required this.value, required this.selected});

  factory EventReminder.fromJson(Map<String, dynamic> json) {
    return EventReminder(
        id: json['ID'], value: json['Value'], selected: json['Selected']);
  }
  Map toJson() => {'ID': id, 'Value': value, 'Selected': selected};
}

class EventReq {
  String eventID;
  String personalID;

  EventReq({required this.eventID, required this.personalID});

  factory EventReq.fromJson(Map<String, dynamic> json) {
    return EventReq(eventID: json['EventID'], personalID: json['PersonalID']);
  }
  Map toJson() => {'EventID': eventID, 'PersonalID': personalID};
}

class DeleteInput {
  final String idList;

  DeleteInput({required this.idList});

  Map toJson() => {'IDList': idList};
}
