import 'package:mashov_api/src/utils.dart';

class Homework {
  String message, subject;
  DateTime date;

  Homework({this.message, this.subject, this.date});

  static Homework fromJson(Map<String, dynamic> src) => Homework(
      message: Utils.string(src["homework"]),
      date: Utils.date(src["lessonDate"]),
      subject: Utils.string(src["subjectName"]));
}
