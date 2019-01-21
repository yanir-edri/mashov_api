import 'package:mashov_api/src/models/attachment.dart';
import 'package:mashov_api/src/utils.dart';

class Message {
  ///data class Message(
  /// val messageId: String, val sendDate: Long, val subject: String,
  /// val body: String, val sender: String, val attachments: List<Attachment>)
  String messageId, subject, sender, body;
  DateTime sendDate;
  List<Attachment> attachments;

  Message(
      {this.messageId,
      this.sendDate,
      this.subject,
      this.body,
      this.sender,
      this.attachments});

  static Message fromJson(Map<String, dynamic> src) {
    print("attachments is of type ${src["files"].runtimeType}");
    return Message(
      messageId: Utils.string(src["messageId"]),
      sendDate: Utils.date(src["sendTime"]),
      subject: Utils.string(src["subject"]),
      body: Utils.string(src["body"]),
      sender: Utils.string(src["senderName"]),
      attachments:  Utils.attachments(src["files"]));
  }

  @override
  String toString() {
    return super.toString() +
        " => { $messageId, $subject, $sender, ${sendDate.toIso8601String()}, ${attachments.length} attachments";
  }
}
