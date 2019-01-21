import 'package:mashov_api/src/controller/cookie_manager.dart';

class CookieManagerImpl implements CookieManager {

  @override
  String _csrfToken = "";

  String get csrfToken => _csrfToken;

  set csrfToken(String csrfToken) {
    _csrfToken = csrfToken;
    trigger();
  }

  @override
  String _mashovSessionId = "";

  String get mashovSessionId => _mashovSessionId;

  set mashovSessionId(String mashovSessionId) {
    _mashovSessionId = mashovSessionId;
    trigger();
  }

  @override
  String _uniqueId = "";

  String get uniqueId => _uniqueId;

  set uniqueId(String uniqueId) {
    _uniqueId = uniqueId;
    trigger();
  }



  Map<int, Function> _listeners = Map();

  @override
  void attachListener(int id, Function listener) {
    _listeners[id] = listener;
  }

  @override
  void detachListener(int id) {
    _listeners.remove(id);
  }

  @override
  void processHeaders(Map<String, List<String>> headers) {
    if(csrfToken.isNotEmpty && mashovSessionId.isNotEmpty && uniqueId.isNotEmpty) {
      return;
    }
    var cToken = headers["x-csrf-token"];
    if(cToken != null) {
      csrfToken = cToken[0];
    }
    if(headers.containsKey("set-cookie")) {
      var cookie = headers["set-cookie"];

      ///uniquId is NOT a typo!
      ///I...I really don't know why they named it that way.
      ///just... go on
      uniqueId = cookie
          .firstWhere((header) => header.contains("uniquId"))
          .split("=")
          .last;
      mashovSessionId = cookie
          .firstWhere((header) => header.contains("MashovSessionID"))
          .split("=")
          .last;
    }
  }

  void trigger() => _listeners.values.forEach((f) => f());

}