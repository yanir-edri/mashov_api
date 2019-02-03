import 'dart:convert';

import 'package:mashov_api/src/utils.dart';

///A result wrapper
class Result<E> {
  dynamic exception;
  E value;

  Result({this.exception, this.value});

  //Returns true if value can be used, false otherwise.
  bool get isSuccess => exception == null && value != null;
}

//login

class School {
  int id;
  String name;
  List<int> years;

  String getYears() => Utils.listToString(years);

  School({this.id, this.name, this.years});

  static School fromJson(Map<String, dynamic> json) => School(
      id: json['semel'], name: json['name'], years: json['years'].cast<int>());

  static List<School> ListFromJson(String src) => (json.decode(src) as List)
      .map((school) => School.fromJson(school))
      .toList();

  Map<String, dynamic> toJson() => {'semel': id, 'name': name, 'years': years};
}

class Student {
  Student(
      {this.id,
      this.familyName,
      this.privateName,
      this.classCode,
      this.classNum});

  String id, familyName, privateName, classCode;
  int classNum;

  factory Student.fromJson(Map<String, dynamic> json) => Student(
      id: json['childGuid'],
      familyName: json['familyName'],
      privateName: json['privateName'],
      classCode: json['classCode'],
      classNum: json['classNum']);

  Map<String, dynamic> toJson() => {
        'childGuid': id,
        'familyName': familyName,
        'privateName': privateName,
        'classCode': classCode,
        'classNum': classNum
      };
}

class LoginData {
  LoginData(
      {this.sessionId,
      this.userId,
      this.id,
      this.userType,
      this.schoolUserType,
      this.schoolId,
      this.year,
      this.correlationId});

  String sessionId, userId, id, correlationId;
  int userType, schoolUserType, schoolId, year;

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
      sessionId: '',
      userId: json['userId'],
      id: "${json['idNumber']}",
      userType: json['userType'],
      schoolUserType: json['schoolUserType'],
      schoolId: json['semel'],
      year: json['year'],
      correlationId: json['correlationId']);

  Map<String, dynamic> toJson() => {
        'sessionId': '',
        'userId': userId,
        'id': id,
        'userType': userType,
        'schoolUserType': schoolUserType,
        'schoolId': schoolId,
        'year': year,
        'correlationId': correlationId
      };
}

class Login {
  Login({this.statusCode, this.data, this.students});

  int statusCode;
  LoginData data;
  List<Student> students;

  factory Login.fromJson(Map<String, dynamic> src) {
    var credential = src["credential"];
    var token = src["accessToken"];
    if (token != null) {
      List<dynamic> children = token["children"];
      LoginData data = LoginData.fromJson(credential);
      List<Student> st = children.map((student) {
        return Student.fromJson(student as Map<String, dynamic>);
      }).toList();
      return Login(data: data, students: st, statusCode: 200);
    } else {
      throw Exception("token is null");
    }
  }

  bool get isUnauthorized => statusCode == 401;

  bool get isInternalServerError => statusCode == 500;

  bool get isNeedToLogin => isUnauthorized || isInternalServerError;

  bool get isForbidden => statusCode == 403;


  static listToStringsList(List list) {
    List<String> strings = new List(list.length);
    for (int i = 0; i < list.length; i++) {
      strings[i] = list[i].toString();
    }
  }
}

//end login

//messages

class Attachment {
  String id, name;

  Attachment({this.id, this.name});

  static Attachment fromJson(Map<String, dynamic> src) => Attachment(
      id: Utils.string(src["fileId"]), name: Utils.string(src["fileName"]));

  @override
  String toString() => super.toString() + " => { $id, $name }";
}

class MessageTitle {
  String messageId, subject, senderName;
  DateTime sendDate;
  bool isNew, hasAttachment;

  MessageTitle(
      {this.messageId,
      this.subject,
      this.senderName,
      this.sendDate,
      this.isNew,
      this.hasAttachment});

  static MessageTitle fromJson(Map<String, dynamic> src) => MessageTitle(
      messageId: Utils.string(src["messageId"]),
      subject: Utils.string(src["subject"]),
      senderName: Utils.string(src["senderName"]),
      sendDate: Utils.date(src["sendTime"]),
      isNew: Utils.boolean(src["isNew"]),
      hasAttachment: Utils.boolean(src["hasAttachments"]));

  @override
  String toString() {
    return super.toString() +
        " => { $messageId, $subject, $senderName, ${sendDate.toIso8601String()}, $isNew, $hasAttachment";
  }
}

class Message {
  ///data class Message(
  /// val messageId: String, val sendDate: Long, val subject: String,
  /// val body: String, val sender: String, val attachments: List<Attachment>)
  String messageId, subject, sender, body;
  DateTime sendDate;
  List<Attachment> attachments;

  Message(
      {this.messageId,
      this.sendDate,
      this.subject,
      this.body,
      this.sender,
      this.attachments});

  static Message fromJson(Map<String, dynamic> src) {
    print("attachments is of type ${src["files"].runtimeType}");
    return Message(
        messageId: Utils.string(src["messageId"]),
        sendDate: Utils.date(src["sendTime"]),
        subject: Utils.string(src["subject"]),
        body: Utils.string(src["body"]),
        sender: Utils.string(src["senderName"]),
        attachments: Utils.attachments(src["files"]));
  }

  @override
  String toString() {
    return super.toString() +
        " => { $messageId, $subject, $sender, ${sendDate.toIso8601String()}, ${attachments.length} attachments";
  }
}

///Basically the parent of a Message.
class Conversation {
  String conversationId, subject;
  DateTime sendTime;
  List<MessageTitle> messages;
  bool preventReply, isNew, hasAttachments;

  Conversation(
      {this.conversationId,
      this.subject,
      this.sendTime,
      this.messages,
      this.preventReply,
      this.isNew,
      this.hasAttachments});

  static Conversation fromJson(Map<String, dynamic> src) => Conversation(
      conversationId: Utils.string(src["conversationId"]),
      subject: Utils.string(src["subject"]),
      hasAttachments: Utils.boolean(src["hasAttachments"]),
      isNew: Utils.boolean(src["isNew"]),
      messages: src["messages"]
          .map<MessageTitle>((m) => MessageTitle.fromJson(m))
          .toList(),
      preventReply: Utils.boolean(src["preventReply"]));
}

class MessagesCount {
  int allMessages, inboxMessages, newMessages, unreadMessages;

  MessagesCount(
      {this.allMessages,
      this.inboxMessages,
      this.newMessages,
      this.unreadMessages});

  static MessagesCount fromJson(Map<String, dynamic> src) => MessagesCount(
      allMessages: Utils.Int(src["allMessages"]),
      inboxMessages: Utils.Int(src["inboxMessages"]),
      newMessages: Utils.Int(src["newMessages"]),
      unreadMessages: Utils.Int(src["unreadMessages"]));

  @override
  String toString() {
    return super.toString() +
        "{ $allMessages, $inboxMessages, $newMessages, $unreadMessages }";
  }
}

//end messages

//everything else

class BagrutGrade {
  String semel, name, date;
  int finalGrade, yearGrade, testGrade;

  BagrutGrade(
      {this.semel,
      this.name,
      this.date,
      this.finalGrade,
      this.yearGrade,
      this.testGrade});

  static BagrutGrade fromJson(Map<String, dynamic> src) => BagrutGrade(
      semel: Utils.Int(src["semel"]).toString(),
      name: Utils.string(src["name"]),
      date: Utils.string(src["moed"]),
      finalGrade: Utils.Int(src["final"]),
      yearGrade: Utils.Int(src["shnaty"]),
      testGrade: Utils.Int(src["test"]));
}

class BehaveEvent {
  int groupId, lesson, type, justificationId;
  String text, justification, reporter, subject;
  DateTime date;

  BehaveEvent(
      {this.groupId,
      this.lesson,
      this.date,
      this.type,
      this.text,
      this.justificationId,
      this.justification,
      this.reporter,
      this.subject});

  static BehaveEvent fromJson(Map<String, dynamic> src) => BehaveEvent(
      groupId: Utils.Int(src["groupId"]),
      lesson: Utils.Int(src["lesson"]),
      date: Utils.date(src["lessonDate"]),
      type: Utils.Int(src["lessonType"]),
      text: Utils.string(src["achvaName"]),
      justificationId: Utils.Int(src["justificationId"]),
      justification: Utils.string(src["justification"]),
      reporter: Utils.string(src["reporter"]),
      subject: Utils.string(src["subject"]));

  @override
  String toString() {
    return super.toString() +
        " => {$groupId, $lesson, ${date.toIso8601String()}, $type, $text, $justificationId, $justification, $reporter, $subject";
  }
}

class Lesson {
  int groupId, day, hour;
  String subject, teacher, room;

  Lesson(
      {this.groupId,
      this.day,
      this.hour,
      this.subject,
      this.teacher,
      this.room});

  static Lesson fromJson(Map<String, dynamic> src) {
    var tableData = src["timeTable"];
    var details = src["groupDetails"];
    bool tableDataNull = tableData == null;
    bool detailsNull = details == null;
    return Lesson(
        groupId: Utils.Int(tableDataNull ? null : tableData["groupId"]),
        day: Utils.Int(tableDataNull ? null : tableData["day"]),
        hour: Utils.Int(tableDataNull ? null : tableData["lesson"]),
        subject: Utils.string(detailsNull ? null : details["subjectName"]),
        teacher: Utils.string(detailsNull ? null : details["teacherName"]),
        room: Utils.string(tableDataNull ? null : tableData["roomNum"]));
  }

  @override
  String toString() =>
      super.toString() +
      " => { $groupId, $day, $hour, $subject, $teacher, $room }";
}

class Grade {
  String teacher, subject, event;
  DateTime eventDate;
  int groupId, type, grade;

  Grade(
      {this.teacher,
      this.groupId,
      this.subject,
      this.eventDate,
      this.event,
      this.type,
      this.grade});

  static Grade fromJson(Map<String, dynamic> src) {
    return Grade(
        teacher: Utils.string(src["teacherName"]),
        groupId: Utils.Int(src["groupId"]),
        subject: Utils.string(src["subjectName"]),
        eventDate: Utils.date(src["eventDate"]),
        event: Utils.string(src["gradingEvent"]),
        type: Utils.Int(src["gradeTypeId"]),
        grade: Utils.Int(src["grade"]));
  }

  static List<Grade> fromJsonArray(List<dynamic> src) =>
      src.map((g) => fromJson(g)).toList();

  @override
  String toString() {
    return super.toString() +
        "-> { teacher: $teacher, groupId: $groupId, subject: $subject, eventDate: ${eventDate.toIso8601String()}(${eventDate.millisecondsSinceEpoch}), event: $event, type: $type, grade: $grade }";
  }
}

class Group {
  int id;
  String subject, teacher;

  Group({this.id, this.subject, this.teacher});

  static Group fromJson(Map<String, dynamic> src) => Group(
      id: Utils.Int(src["groupId"]),
      subject: Utils.string(src["fullSubjectName"]),
      teacher: Utils.string(src["teacherName"]));

  @override
  String toString() =>
      super.toString() +
      " => { id: $id, $subject" +
      (teacher.isNotEmpty ? " - $teacher " : "") +
      " }";

  String format() => "$subject" + (teacher.isNotEmpty ? " - $teacher " : "");
}

class Contact {
  String name, parentClass, address, phone;

  Contact({this.name, this.parentClass, this.address, this.phone});

  static Contact fromJson(Map<String, dynamic> src) {
    var city = Utils.string(src["city"]);
    var street = Utils.string(src["address"]);
    return Contact(
        name: Utils.string(src["privateName"]) +
            " " +
            Utils.string(src["familyName"]),
        phone: Utils.string(src["cellphone"]),
        parentClass: Utils.string(src["classCode"]) +
            Utils.Int(src["classNum"]).toString(),
        address: street +
            (city.isEmpty ? "" : (street.isEmpty ? city : ", " + city)));
  }

  @override
  String toString() =>
      super.toString() + " => { $name, $parentClass, $address, $phone }";
}

class Hatama {
  int code;
  String name;

  Hatama({this.code, this.name});

  static Hatama fromJson(Map<String, dynamic> src) =>
      Hatama(code: Utils.Int(src["code"]), name: Utils.string(src["name"]));
}

class Homework {
  String message, subject;
  DateTime date;

  Homework({this.message, this.subject, this.date});

  static Homework fromJson(Map<String, dynamic> src) => Homework(
      message: Utils.string(src["homework"]),
      date: Utils.date(src["lessonDate"]),
      subject: Utils.string(src["subjectName"]));
}

class Maakav {
  DateTime date;
  String message, reporter, id;
  List<Attachment> attachments;

  Maakav({this.id, this.date, this.message, this.reporter, this.attachments});

  static Maakav fromJson(Map<String, dynamic> src) => Maakav(
      id: Utils.Int(src["maakavId"]).toString(),
      date: Utils.date(src["maakavDate"]),
      message: Utils.string(src["message"]),
      reporter: Utils.string(src["reporterName"]),
      attachments: Utils.attachments(src["filesMetadata"]));
}
