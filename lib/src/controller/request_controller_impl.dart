import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:mashov_api/src/controller/request_controller.dart';

class RequestControllerImpl implements RequestController {
  RequestControllerImpl();

  http.Client _client = http.Client();

  @override
  Future<http.Response> get(String url, Map<String, String> headers) async {
    return _client.get(url, headers: headers);
  }

  @override
  Future<http.Response> post(String url, Map<String, String> headers,
      String body) async {
    return _client.post(url, headers: headers, body: body);
  }
}
