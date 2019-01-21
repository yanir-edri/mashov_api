import 'package:mashov_api/src/controller/request_controller.dart';
import 'package:http/http.dart' as http;


class RequestControllerImpl implements RequestController {
  RequestControllerImpl();

  @override
  Future<http.Response> get(String url, Map<String, String> headers) async =>
      http.get(url, headers: headers);

  @override
  Future<http.Response> post(String url, Map<String, String> headers,
      String body) => http.post(url, headers: headers, body: body);
}
