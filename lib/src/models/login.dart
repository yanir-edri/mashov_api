import 'package:mashov_api/src/models/login_data.dart';
import 'package:mashov_api/src/models/student.dart';

class Login {
  Login({this.data, this.students});

  LoginData data;
  List<Student> students;

  factory Login.fromJson(Map<String, dynamic> src) {
    print("printing from login from json");
    for (MapEntry<String, dynamic> entry in src.entries) {
      print(
          "entry with key ${entry.key} is ${entry.value}, and ${entry.value.toString()}");
    }

    var credential = src["credential"];
    var token = src["accessToken"];
    if (token != null) {
      List<dynamic> children = token["children"];
      LoginData data = LoginData.fromJson(credential);
      List<Student> st = children.map((student) {
        return Student.fromJson(student as Map<String, dynamic>);
      }).toList();
      return Login(data: data, students: st);
    } else {
      throw Exception("token is null");
    }
  }

  static listToStringsList(List list) {
    List<String> strings = new List(list.length);
    for (int i = 0; i < list.length; i++) {
      strings[i] = list[i].toString();
    }
  }
}
