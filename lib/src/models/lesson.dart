///data class Lesson(
/// val groupId: Int, val day: Int, val hour: Int, val subject: String, val teacher: String)
import 'package:mashov_api/src/utils.dart';

/// val groupId: Int, val day: Int, val hour: Int, val subject: String, val teacher: String)


/// val groupId: Int, val day: Int, val hour: Int, val subject: String, val teacher: String)


/// val groupId: Int, val day: Int, val hour: Int, val subject: String, val teacher: String)


class Lesson {
  int groupId, day, hour;
  String subject, teacher, room;
  Lesson({this.groupId, this.day, this.hour, this.subject, this.teacher, this.room});

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
      room: Utils.string(tableDataNull ? null : tableData["roomNum"])

    );
  }

  @override
  String toString() => super.toString() + " => { $groupId, $day, $hour, $subject, $teacher, $room }";


}