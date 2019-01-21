import 'package:mashov_api/src/utils.dart';

class MessagesCount {
  int allMessages, inboxMessages, newMessages, unreadMessages;

  MessagesCount(
      {this.allMessages,
      this.inboxMessages,
      this.newMessages,
      this.unreadMessages});

  static MessagesCount fromJson(Map<String, dynamic> src) => MessagesCount(
      allMessages: Utils.Int(src["allMessages"]),
      inboxMessages: Utils.Int(src["inboxMessages"]),
      newMessages: Utils.Int(src["newMessages"]),
      unreadMessages: Utils.Int(src["unreadMessages"]));

  @override
  String toString() {
    return super.toString() +
        "{ $allMessages, $inboxMessages, $newMessages, $unreadMessages }";
  }
}
