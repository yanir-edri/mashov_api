import 'package:mashov_api/src/utils.dart';

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
