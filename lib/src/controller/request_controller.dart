import 'dart:async';

import 'package:http/http.dart';

///I actually did think this class was gonna be more useful than that.
///But uhm, maybe it will have some meaning in the future??
///Who knows. I'm keeping it.
abstract class RequestController {
  ///sends a get request.
  Future<Response> get(String url, Map<String, String> headers);

  ///sends a post request.
  Future<Response> post(String url, Map<String, String> headers, String body);
}
