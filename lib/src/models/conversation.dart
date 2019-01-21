import 'package:mashov_api/src/models/message_title.dart';
import 'package:mashov_api/src/utils.dart';

///Basically the parent of a Message.
class Conversation {
  String conversationId, subject;
  DateTime sendTime;
  List<MessageTitle> messages;
  bool preventReply, isNew, hasAttachments;

  Conversation(
      {this.conversationId,
      this.subject,
      this.sendTime,
      this.messages,
      this.preventReply,
      this.isNew,
      this.hasAttachments});

  static Conversation fromJson(Map<String, dynamic> src) => Conversation(
      conversationId: Utils.string(src["conversationId"]),
      subject: Utils.string(src["subject"]),
      hasAttachments: Utils.boolean(src["hasAttachments"]),
      isNew: Utils.boolean(src["isNew"]),
      messages: src["messages"]
          .map<MessageTitle>((m) => MessageTitle.fromJson(m))
          .toList(),
      preventReply: Utils.boolean(src["preventReply"]));
}
