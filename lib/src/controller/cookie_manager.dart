abstract class CookieManager {

  ///Saves the csrf-token, session id and uniqueId.
  void processHeaders(Map<String, List<String>> headers);

  String csrfToken, mashovSessionId,uniqueId;

  ///Attach a listener to cookie manager - whenever one of the variables is updated, these listeners are triggered
  void attachListener(int id, Function listener);

  ///Detach a listener from the cookie manager.
  void detachListener(int id);
}
