import 'package:mashov_api/src/utils.dart';

class Attachment {
  String id, name;
  Attachment({this.id, this.name});

  static Attachment fromJson(Map<String, dynamic> src) =>
      Attachment(
        id: Utils.string(src["fileId"]),
        name: Utils.string(src["fileName"])
      );

  @override
  String toString() => super.toString() + " => { $id, $name }";
}