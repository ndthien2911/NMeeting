class MeetingTodayOutput {
  final String? id;
  final String? name;
  final String? startAt;
  final String? endAt;
  final String? admin;
  final String? address;
  final bool? insertFlg;
  final bool? cancelApproved;
  final int? type;
  final int? groupID;

  MeetingTodayOutput({
    this.id,
    this.name,
    this.startAt,
    this.endAt,
    this.admin,
    this.address,
    this.insertFlg,
    this.cancelApproved,
    this.type,
    this.groupID,
  });

  factory MeetingTodayOutput.fromJson(Map<String, dynamic> json) {
    return MeetingTodayOutput(
      id: json['ID'] as String?,
      name: json['Name'] as String?,
      startAt: json['StartAt'] as String?,
      endAt: json['EndAt'] as String?,
      admin: json['Admin'] as String?,
      address: json['Address'] as String?,
      insertFlg: json['InsertFlg'] as bool?,
      cancelApproved: json['CancelApproved'] as bool?,
      type: json['Type'] as int?,
      groupID: json['GroupID'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startAt': startAt,
        'endAt': endAt,
        'admin': admin,
        'address': address,
        'insertFlg': insertFlg,
        'cancelApproved': cancelApproved,
        'type': type,
        'groupID': groupID,
      };
}

class MenuAppLayout {
  final String? id;
  final String? name;
  final String? url;
  final String? imgUrl;

  MenuAppLayout({
    this.id,
    this.name,
    this.url,
    this.imgUrl,
  });

  factory MenuAppLayout.fromJson(Map<String, dynamic> json) {
    return MenuAppLayout(
      id: json['ID'] as String?,
      name: json['Name'] as String?,
      url: json['Url'] as String?,
      imgUrl: json['ImgUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'imgUrl': imgUrl,
      };
}
