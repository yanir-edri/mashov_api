import 'package:mashov_api/src/utils.dart';

class Group {
  int id;
  String subject, teacher;
  Group({this.id, this.subject, this.teacher});

  static Group fromJson(Map<String, dynamic> src) => Group(
      id: Utils.Int(src["groupId"]),
      subject: Utils.string(src["fullSubjectName"]),
      teacher: Utils.string(src["teacherName"])
    );

  @override
  String toString() => super.toString() + " => { id: $id, $subject" + (teacher.isNotEmpty? " - $teacher " : "") + " }";

  String format() => "$subject" + (teacher.isNotEmpty? " - $teacher " : "");


}