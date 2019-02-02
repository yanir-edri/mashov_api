import 'package:mashov_api/src/utils.dart';

class Hatama {
  int code;
  String name;

  Hatama({this.code, this.name});

  static Hatama fromJson(Map<String, dynamic> src) =>
      Hatama(code: Utils.Int(src["code"]), name: Utils.string(src["name"]));
}
