class EventByMonthInput {
  final String? personalID;
  final String? eventFromDate;
  final String? eventToDate;
  // final int? filterValue;
  // final String? unitID;
  final String? searchValue;

  EventByMonthInput({
    this.personalID,
    this.eventFromDate,
    this.eventToDate,
    // this.filterValue,
    // this.unitID,
    this.searchValue,
  });

  Map<String, dynamic> toJson() => {
        'personalID': personalID,
        'eventFromDate': eventFromDate,
        'eventToDate': eventToDate,
        // 'filterValue': filterValue,
        // 'unitID': unitID,
        'searchValue': searchValue,
      };
}

class EventByMonthOutput {
  final String? eventName;
  final String? from;
  final String? to;
  final int? type;
  final int? groupID;

  EventByMonthOutput({
    this.eventName,
    this.from,
    this.to,
    this.type,
    this.groupID,
  });

  factory EventByMonthOutput.fromJson(Map<String, dynamic> json) {
    return EventByMonthOutput(
      eventName: json['EventName'] as String?,
      from: json['From'] as String?,
      to: json['To'] as String?,
      type: json['Type'] as int?,
      groupID: json['GroupID'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'eventName': eventName,
        'from': from,
        'to': to,
        'type': type,
        'groupID': groupID,
      };
}

class EventByDayInput {
  final String? personalID;
  final String? eventDate;
  final String? searchValue;

  EventByDayInput({
    this.personalID,
    this.eventDate,
    this.searchValue,
  });

  Map<String, dynamic> toJson() => {
        'personalID': personalID,
        'eventDate': eventDate,
        'searchValue': searchValue,
      };
}

class EventByDayOutput {
  String? id;
  String? eventName;
  String? from;
  String? to;
  int? type;
  bool? cancelApproved;
  bool? insertFlg;
  int? groupID;

  EventByDayOutput({
    this.id,
    this.eventName,
    this.from,
    this.to,
    this.type,
    this.cancelApproved,
    this.insertFlg,
    this.groupID,
  });

  factory EventByDayOutput.fromJson(Map<String, dynamic> json) {
    return EventByDayOutput(
      id: json['ID'] as String?,
      eventName: json['EventName'] as String?,
      from: json['From'] as String?,
      to: json['To'] as String?,
      type: json['Type'] as int?,
      cancelApproved: json['CancelApproved'] as bool? ?? false,
      insertFlg: json['InsertFlg'] as bool? ?? false,
      groupID: json['GroupID'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventName': eventName,
        'from': from,
        'to': to,
        'type': type,
        'cancelApproved': cancelApproved,
        'insertFlg': insertFlg,
        'groupID': groupID,
      };
}

class UnitList {
  String? id;
  String? name;
  bool? selected;

  UnitList({
    this.id,
    this.name,
    this.selected,
  });

  factory UnitList.fromJson(Map<String, dynamic> json) {
    return UnitList(
      id: json['ID'] as String?,
      name: json['Name'] as String?,
      selected: false,
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'selected': selected};
}
