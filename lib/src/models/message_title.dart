import 'package:mashov_api/src/utils.dart';

class MessageTitle {
  String messageId, subject, senderName;
  DateTime sendDate;
  bool isNew, hasAttachment;

  MessageTitle(
      {this.messageId,
      this.subject,
      this.senderName,
      this.sendDate,
      this.isNew,
      this.hasAttachment});

  static MessageTitle fromJson(Map<String, dynamic> src) => MessageTitle(
      messageId: Utils.string(src["messageId"]),
      subject: Utils.string(src["subject"]),
      senderName: Utils.string(src["senderName"]),
      sendDate: Utils.date(src["sendTime"]),
      isNew: Utils.boolean(src["isNew"]),
      hasAttachment: Utils.boolean(src["hasAttachments"]));

  @override
  String toString() {
    return super.toString() + " => { $messageId, $subject, $senderName, ${sendDate.toIso8601String()}, $isNew, $hasAttachment";
  }


}
