import 'package:mashov_api/src/utils.dart';

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
