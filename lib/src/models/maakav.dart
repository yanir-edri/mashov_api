import 'package:mashov_api/src/models/attachment.dart';
import 'package:mashov_api/src/utils.dart';

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
