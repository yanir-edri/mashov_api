import 'package:mashov_api/src/utils.dart';
class Grade {
  String teacher, subject, event;
  DateTime eventDate;
  int groupId, type, grade;
  Grade({this.teacher, this.groupId, this.subject, this.eventDate, this.event, this.type, this.grade});

  static Grade fromJson(Map<String,dynamic> src) {
    return Grade(
      teacher: Utils.string(src["teacherName"]),
      groupId: Utils.Int(src["groupId"]),
      subject: Utils.string(src["subjectName"]),
      eventDate: Utils.date(src["eventDate"]),
      event: Utils.string(src["gradingEvent"]),
      type: Utils.Int(src["gradeTypeId"]),
      grade: Utils.Int(src["grade"])
    );
  }

  static List<Grade> fromJsonArray(List<dynamic> src) => src.map((g) => fromJson(g)).toList();
  @override
  String toString() {
    return super.toString() + "-> { teacher: $teacher, groupId: $groupId, subject: $subject, eventDate: ${eventDate.toIso8601String()}(${eventDate.millisecondsSinceEpoch}), event: $event, type: $type, grade: $grade }";
  }

}

///Grade(src["teacherName"].nullString ?: "",
/// src["groupId"].nullInt ?: 0,
/// src["subjectName"].nullString ?: "",
/// src["eventDate"].string.date(),
/// src["gradingEvent"].nullString ?: "",
/// src["gradeTypeId"].nullInt ?: 0,
/// src["grade"].nullInt ?: 0)

///
///data class Grade(
/// val teacher: String,
/// val groupId: Int,
/// val subject: String,
/// val eventDate: Long,
/// val event: String,
/// val type: Int,
/// val grade: Int)
