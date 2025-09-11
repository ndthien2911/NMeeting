class ProgressInput {
  final String? meetingID;
  final String? personalID;

  ProgressInput({this.meetingID, this.personalID});

  Map<String, dynamic> toJson() =>
      {'MeetingID': meetingID, 'PersonalID': personalID};
}

class ProgressOutput {
  String? id;
  String? name;
  String? time;
  bool? activeFlg;
  bool? isActiveNewest;
  bool? isHasDocument;
  bool? isHasQuestion;
  String? problemNameNewest;
  CurrentQuestion? currentQuestion;
  ResultQuestion? resultQuestion;

  ProgressOutput({
    this.id,
    this.name,
    this.time,
    this.activeFlg,
    this.isActiveNewest,
    this.isHasDocument,
    this.isHasQuestion,
    this.problemNameNewest,
    this.currentQuestion,
    this.resultQuestion,
  });

  factory ProgressOutput.fromJson(Map<String, dynamic> json) {
    return ProgressOutput(
      id: json['ID'],
      name: json['Name'],
      time: json['Time'],
      activeFlg: json['ActiveFlg'],
      isActiveNewest: json['IsActiveNewest'],
      isHasDocument: json['IsHasDocument'],
      isHasQuestion: json['IsHasQuestion'],
      problemNameNewest: json['ProblemNameNewest'],
      currentQuestion: json['CurrentQuestion'] == null
          ? null
          : CurrentQuestion.fromJson(json['CurrentQuestion']),
      resultQuestion: json['ResultQuestion'] == null
          ? null
          : ResultQuestion.fromJson(json['ResultQuestion']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'time': time,
        'activeFlg': activeFlg,
        'isActiveNewest': isActiveNewest,
        'isHasDocument': isHasDocument,
        'isHasQuestion': isHasQuestion,
        'problemNameNewest': problemNameNewest,
      };
}

class CurrentQuestion {
  final String? questionID;
  final String? questionName;
  final List<Answers>? answers;
  final String? problemID;
  final bool? startFlg;
  final bool? endFlg;
  final bool? declareFlg;

  CurrentQuestion({
    this.questionID,
    this.questionName,
    this.answers,
    this.problemID,
    this.startFlg,
    this.endFlg,
    this.declareFlg,
  });

  factory CurrentQuestion.fromJson(Map<String, dynamic> json) {
    return CurrentQuestion(
      questionID: json['QuestionID'],
      questionName: json['QuestionName'],
      answers: (json['Answers'] as List<dynamic>?)
          ?.map((e) => Answers.fromJson(e))
          .toList(),
      problemID: json['ProblemID'],
      startFlg: json['StartFlg'],
      endFlg: json['EndFlg'],
      declareFlg: json['DeclareFlg'],
    );
  }
}

class ResultQuestion {
  final String? questionID;
  final String? questionName;
  final int? questionGroupID;
  final String? questionRefID;
  final List<AnswersResult>? answers;
  final String? hh;
  final String? mm;
  final int? total;
  final int? totalUserJoin;

  ResultQuestion({
    this.questionID,
    this.questionName,
    this.questionGroupID,
    this.questionRefID,
    this.answers,
    this.hh,
    this.mm,
    this.total,
    this.totalUserJoin,
  });

  factory ResultQuestion.fromJson(Map<String, dynamic> json) {
    return ResultQuestion(
      questionID: json['QuestionID'],
      questionName: json['QuestionName'],
      questionGroupID: json['QuestionGroupID'],
      questionRefID: json['QuestionRefID'],
      answers: (json['Answers'] as List<dynamic>?)
          ?.map((e) => AnswersResult.fromJson(e))
          .toList(),
      hh: json['HH'],
      mm: json['MM'],
      total: json['Total'],
      totalUserJoin: json['TotalUserJoin'],
    );
  }
}

class Answers {
  String? id;
  String? name;
  bool? isChosen;

  Answers({this.id, this.name, this.isChosen});

  factory Answers.fromJson(Map<String, dynamic> json) {
    return Answers(
      id: json['ID'],
      name: json['Name'],
      isChosen: json['IsChosen'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'isChosen': isChosen};
}

class AnswersResult {
  String? id;
  String? name;
  int? numberChosen;

  AnswersResult({this.id, this.name, this.numberChosen});

  factory AnswersResult.fromJson(Map<String, dynamic> json) {
    return AnswersResult(
      id: json['ID'],
      name: json['Name'],
      numberChosen: json['NumberChosen'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'numberChosen': numberChosen};
}

class Idea {
  final String? id;
  final bool? accountHasRegist;
  final bool? accountHasInviteByAdmin;
  final String? ideaDetailID;
  final bool? isUserEndIdea;
  final MemberInvited? memberInvited;
  final String? description;

  Idea({
    this.id,
    this.accountHasRegist,
    this.accountHasInviteByAdmin,
    this.ideaDetailID,
    this.isUserEndIdea,
    this.memberInvited,
    this.description,
  });

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['ID'],
      accountHasRegist: json['AccountHasRegist'],
      accountHasInviteByAdmin: json['AccountHasInviteByAdmin'],
      ideaDetailID: json['IdeaDetailID'],
      isUserEndIdea: json['IsUserEndIdea'],
      memberInvited: json['MemberInvited'] != null
          ? MemberInvited.fromJson(json['MemberInvited'])
          : null,
      description: json['Description'],
    );
  }
}

class MemberInvited {
  final String? memberInvitedID;
  final String? message;

  MemberInvited({this.memberInvitedID, this.message});

  factory MemberInvited.fromJson(Map<String, dynamic> json) {
    return MemberInvited(
      memberInvitedID: json['MemberInvitedID'],
      message: json['Message'],
    );
  }
}

class ProgressIdea {
  final List<ProgressOutput>? progressOutput;
  final Idea? idea;

  ProgressIdea({this.progressOutput, this.idea});
}

class DocumentInput {
  final String? progressID;
  final String? meetingID;
  final bool? isGetAll;

  DocumentInput({this.progressID, this.meetingID, this.isGetAll});

  Map<String, dynamic> toJson() =>
      {'progressID': progressID, 'meetingID': meetingID, 'isGetAll': isGetAll};
}

class DocumentOutput {
  String? id;
  String? name;
  String? link;
  String? createAt;
  bool? isAllowDownload;

  DocumentOutput(
      {this.id, this.name, this.link, this.createAt, this.isAllowDownload});

  factory DocumentOutput.fromJson(Map<String, dynamic> json) {
    return DocumentOutput(
      id: json['ID'],
      name: json['Name'],
      link: json['Link'],
      createAt: json['CreateAt'],
      isAllowDownload: json['IsAllowDownload'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'link': link,
        'createAt': createAt,
        'isAllowDownload': isAllowDownload,
      };
}

class UrlDocumentInput {
  final String? documentID;
  final String? personalID;
  final String? fullName;

  UrlDocumentInput({this.documentID, this.personalID, this.fullName});

  Map<String, dynamic> toJson() => {
        'documentID': documentID,
        'personalID': personalID,
        'fullName': fullName,
      };
}

class LibraryInput {
  final String? personalID;

  LibraryInput({this.personalID});

  Map<String, dynamic> toJson() => {'personalID': personalID};
}

class LibraryOutput {
  String? id;
  String? name;
  bool? isDateGroup;
  bool? isAllowDownload;
  String? inDateGroup;

  LibraryOutput(
      {this.id,
      this.name,
      this.isDateGroup,
      this.isAllowDownload,
      this.inDateGroup});

  factory LibraryOutput.fromJson(Map<String, dynamic> json) {
    return LibraryOutput(
      id: json['ID'],
      name: json['Name'],
      isDateGroup: json['IsDateGroup'],
      isAllowDownload: json['IsAllowDownload'],
      inDateGroup: json['InDateGroup'],
    );
  }

  LibraryOutput.clone(LibraryOutput source)
      : id = source.id,
        name = source.name,
        isDateGroup = source.isDateGroup,
        isAllowDownload = source.isAllowDownload,
        inDateGroup = source.inDateGroup;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isDateGroup': isDateGroup,
        'isAllowDownload': isAllowDownload,
        'inDateGroup': inDateGroup,
      };
}
