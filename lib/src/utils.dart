import 'package:mashov_api/src/models.dart';


///Some nice utility functions
class Utils {

  ///Returns an empty string if value is null, the value itself otherwise.
  static String string(String value) => value ?? "";

  ///Returns 0 if value is null, the value itself otherwise.
  static int Int(int value) => value ?? 0;

  ///Returns false if value is null, the value itself otherwise.
  static bool boolean(bool value) => value ?? false;

  ///Parses a list of attachments.
  static List<Attachment> attachments(List src) =>
      src == null
          ? List()
          : src.map<Attachment>((s) => Attachment.fromJson(s)).toList();

  ///Takes a list and turns it into the format:
  ///"[ a1, a2, a3, a4, ... ]"
  ///Used to convert a list to a nicely formatted json.
  static String listToString(List<dynamic> strings) {
    if (strings.isEmpty) return "[ ]";
    String string = '[${strings[0]}';
    if (strings.length == 1) {
      string += ']';
    } else {
      for (int i = 1; i < strings.length; i++) {
        string += '], ${strings[1]}';
      }
      string += ']';
    }
    return string;
  }

  ///Turns headers into something a bit more readable.
  static Map<String, List<String>> decodeHeaders(Map<String, String> headers) =>
      headers.map((key, value) => MapEntry(key, value.split(';')));
}
