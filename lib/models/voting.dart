class ProblemInput {
  final String meetingID;
  final String personalID;

  ProblemInput({required this.meetingID, required this.personalID});

  Map toJson() => {'meetingID': meetingID, 'personalID': personalID};
}

class ProblemOutput {
  String id;
  String name;
  int groupID;
  String problemIndex;
  String refID;
  bool isComplete;
  bool endFlg;

  ProblemOutput(
      {required this.id,
      required this.name,
      required this.groupID,
      required this.problemIndex,
      required this.refID,
      required this.isComplete,
      required this.endFlg});

  factory ProblemOutput.fromJson(Map<String, dynamic> json) {
    return ProblemOutput(
        id: json['ID'],
        name: json['Name'],
        groupID: json['GroupID'],
        problemIndex: json['ProblemIndex'],
        refID: json['RefID'],
        isComplete: json['IsComplete'],
        endFlg: json['EndFlg']);
  }
  Map toJson() => {
        'id': id,
        'name': name,
        'groupID': groupID,
        'problemIndex': problemIndex,
        'isComplete': isComplete,
        'refID': refID,
        'endFlg': endFlg,
      };
}

class QuestionInput {
  final String problemID;
  final String personalID;

  QuestionInput({required this.problemID, required this.personalID});

  Map toJson() => {'problemID': problemID, 'personalID': personalID};
}

class QuestionOutput {
  String questionID;
  String questionName;
  List<Answer> answers;

  QuestionOutput(
      {required this.questionID,
      required this.questionName,
      required this.answers});

  factory QuestionOutput.fromJson(Map<String, dynamic> json) {
    return QuestionOutput(
        questionID: json['QuestionID'],
        questionName: json['QuestionName'],
        answers: json["Answers"].map<Answer>((event) {
          return Answer.fromJson(event);
        }).toList());
  }
}

class QuestionResultInput {
  final String meetingID;
  final int groupID;
  final String problemID;

  QuestionResultInput(
      {required this.meetingID,
      required this.problemID,
      required this.groupID});

  Map toJson() =>
      {'meetingID': meetingID, 'problemID': problemID, 'groupID': groupID};
}

class Answer {
  String id;
  String name;
  bool isChosen;

  Answer({required this.id, required this.name, required this.isChosen});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
        id: json['ID'], name: json['Name'], isChosen: json['IsChosen']);
  }
  Map toJson() => {'id': id, 'name': name, 'isChosen': isChosen};
}

class AnwserInput {
  final List<String> answerIDs;
  final String personalID;
  final String questionID;
  final String problemID;
  final bool isAnswerValid;

  AnwserInput(
      {required this.answerIDs,
      required this.personalID,
      required this.questionID,
      required this.problemID,
      required this.isAnswerValid});

  Map toJson() => {
        'answerIDs': answerIDs,
        'personalID': personalID,
        'questionID': questionID,
        'problemID': problemID,
        'isAnswerValid': isAnswerValid
      };
}

class CompleteProblemInput {
  final String personalID;
  final String problemID;

  CompleteProblemInput({required this.personalID, required this.problemID});

  Map toJson() => {'personalID': personalID, 'problemID': problemID};
}

class AllowInput {
  final String problemID;
  final String? personalID;

  AllowInput({required this.problemID, this.personalID});

  Map toJson() => {'problemID': problemID, 'personalID': personalID};
}

class DeclareInput {
  final String problemID;

  DeclareInput({required this.problemID});

  Map toJson() => {'problemID': problemID};
}

class CompleteOutput {
  bool isComplete;
  bool isEndFlg;

  CompleteOutput({required this.isComplete, required this.isEndFlg});

  factory CompleteOutput.fromJson(Map<String, dynamic> json) {
    return CompleteOutput(
        isComplete: json['IsComplete'], isEndFlg: json['IsEndFlg']);
  }
  Map toJson() => {
        'isComplete': isComplete,
        'isEndFlg': isEndFlg,
      };
}

class QuestionResultOutput {
  String questionID;
  String questionName;
  List<AnswerResult> answers;
  int total;

  QuestionResultOutput(
      {required this.questionID,
      required this.questionName,
      required this.answers,
      required this.total});

  factory QuestionResultOutput.fromJson(Map<String, dynamic> json) {
    return QuestionResultOutput(
        questionID: json['QuestionID'],
        questionName: json['QuestionName'],
        answers: json['Answers'].map<AnswerResult>((event) {
          return AnswerResult.fromJson(event);
        }).toList(),
        total: json['Total']);
  }
}

class AnswerResult {
  String id;
  String name;
  int numberChosen;

  AnswerResult(
      {required this.id, required this.name, required this.numberChosen});

  factory AnswerResult.fromJson(Map<String, dynamic> json) {
    return AnswerResult(
        id: json['ID'], name: json['Name'], numberChosen: json['NumberChosen']);
  }
  Map toJson() => {'id': id, 'name': name, 'numberChosen': numberChosen};
}

class QuestionFinalResultOutput {
  int totalUserJoin;
  List<QuestionResultOutput> questionResults;

  QuestionFinalResultOutput(
      {required this.totalUserJoin, required this.questionResults});
}

class BCResultOutput {
  String questionID;
  String questionName;
  List<AccountResult> accounts;

  BCResultOutput(
      {required this.questionID,
      required this.questionName,
      required this.accounts});

  factory BCResultOutput.fromJson(Map<String, dynamic> json) {
    return BCResultOutput(
        questionID: json['QuestionID'],
        questionName: json['QuestionName'],
        accounts: json['Accounts'].map<AccountResult>((event) {
          return AccountResult.fromJson(event);
        }).toList());
  }
}

class AccountResult {
  String avatarUrl;
  String name;
  String position;

  AccountResult(
      {required this.avatarUrl, required this.name, required this.position});

  factory AccountResult.fromJson(Map<String, dynamic> json) {
    return AccountResult(
        avatarUrl: json['AvatarUrl'],
        name: json['Name'],
        position: json['Position']);
  }
  Map toJson() => {'avatarUrl': avatarUrl, 'name': name, 'position': position};
}
