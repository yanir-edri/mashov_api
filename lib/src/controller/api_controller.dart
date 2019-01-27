import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mashov_api/src/controller/cookie_manager.dart';
import 'package:mashov_api/src/controller/request_controller.dart';
import 'package:mashov_api/src/models/behave_event.dart';
import 'package:mashov_api/src/models/contact.dart';
import 'package:mashov_api/src/models/conversation.dart';
import 'package:mashov_api/src/models/grade.dart';
import 'package:mashov_api/src/models/group.dart';
import 'package:mashov_api/src/models/homework.dart';
import 'package:mashov_api/src/models/lesson.dart';
import 'package:mashov_api/src/models/login.dart';
import 'package:mashov_api/src/models/maakav.dart';
import 'package:mashov_api/src/models/message.dart';
import 'package:mashov_api/src/models/messages_count.dart';
import 'package:mashov_api/src/models/result.dart';
import 'package:mashov_api/src/models/school.dart';
import 'package:mashov_api/src/utils.dart';

typedef Parser<E> = E Function(Map<String, dynamic> src);

class ApiController {
  CookieManager _cookieManager;
  RequestController _requestController;

  ApiController(CookieManager manager, RequestController controller) {
    setJsonHeader();
    _cookieManager = manager;
    _requestController = controller;
  }

  ///returns a list of schools.
  Future<Result<List<School>>> getSchools() =>
      authList(_schoolsUrl, School.fromJson);

  ///logs in to the Mashov API.
  Future<Result<Login>> login(
      School school, String id, String password, int year) async {
    var body = {
      "school": {
        "semel": school.id,
        "name": school.name,
        "years": school.getYears(),
        "top": true
      },
      "username": id,
      "year": year,
      "password": password,
      "semel": school.id,
      "appName": "com.mashov.main",
      "appVersion": _ApiVersion
    };

    var headers = jsonHeader;
    headers.addAll(loginHeader());
    try {
      return _requestController
          .post(_loginUrl, headers, json.encode(body))
          .then((response) {
        processResponse(response);
        return Result(
            exception: null, value: Login.fromJson(json.decode(response.body)));
      }).catchError((e) => Result(exception: e, value: null));
    } catch (e) {
      return Result(exception: e, value: null);
    }
  }

  ///Returns a list of grades.
  Future<Result<List<Grade>>> getGrades(String userId) =>
      authList<Grade>(_gradesUrl(userId), Grade.fromJson);

  ///Returns a list of behave events.
  Future<Result<List<BehaveEvent>>> getBehaveEvents(String userId) =>
      authList<BehaveEvent>(_behaveUrl(userId), BehaveEvent.fromJson);

  ////Returns the messages count - all, inbox, new and unread.
  Future<Result<MessagesCount>> getMessagesCount() =>
      auth(_messagesCountUrl, MessagesCount.fromJson);

  ///Returns a list of conversations.
  Future<Result<List<Conversation>>> getMessages(int skip) =>
      authList(_messagesUrl(skip), Conversation.fromJson);

  ///Returns a specific message.
  Future<Result<Message>> getMessage(String messageId) =>
      auth(_messageUrl(messageId), Message.fromJson);

  ///Returns the user timetable.
  Future<Result<List<Lesson>>> getTimeTable(String userId) =>
      authList(_timetableUrl(userId), Lesson.fromJson);

  ///Returns a list of the Alfon Groups.
  ///The class group is a different address, so we use an id -1 to access it.
  Future<Result<List<Group>>> getGroups(String userId) =>
      authList(_groupsUrl(userId), Group.fromJson).then((groups) {
        groups.value.add(Group(id: -1, teacher: "", subject: "כיתה"));
        return groups;
      });

  ///returns an Alfon Group contacts.
  Future<Result<List<Contact>>> getContacts(String userId, String groupId) =>
      authList(_alfonUrl(userId, groupId), Contact.fromJson);

  ///Returns a list of Maakav reports.
  Future<Result<List<Maakav>>> getMaakav(String userId) =>
      authList(_maakavUrl(userId), Maakav.fromJson);

  ///Returns a list of homework.
  Future<Result<List<Homework>>> getHomework(String userId) =>
      authList(_homeworkUrl(userId), Homework.fromJson);

  ///Returns the user profile.
  Future<File> getPicture(String userId, File file) {
    Map<String, String> headers = jsonHeader;
    headers.addAll(authHeader());
    return _requestController
        .get(_pictureUrl(userId), headers)
        .then((response) {
      return response.bodyBytes;
    }).then((picture) {
      return file.writeAsBytes(picture);
    });
  }

  ///log out from the session. might want to reset the cookies, but anyway
  ///The application should make sure these are reset.
  void logout() => _requestController.get(_logoutUrl, Map());

  ///Returns the message's attachment.
  ///The file passed is the file the attachment is going to be written to.
  ///You will usually want to put it in the downloads folder,
  ///and called as the actual attachment name.
  Future<File> getAttachment(String messageId, String fileId, String name,
      File file) {
    Map<String, String> headers = jsonHeader;
    headers.addAll(authHeader());
    return _requestController
        .get(_attachmentUrl(messageId, fileId, name), headers)
        .then((response) => response.bodyBytes)
        .then((attachment) => file.writeAsBytes(attachment));
  }

  Future<File> getMaakavAttachment(String maakavId, String userId,
      String fileId, String name, File file) {
    Map<String, String> headers = jsonHeader;
    headers.addAll(authHeader());
    return _requestController
        .get(_maakavAttachmentUrl(maakavId, userId, fileId, name), headers)
        .then((response) => response.bodyBytes)
        .then((attachment) => file.writeAsBytes(attachment));
  }

  ///Returns a list of E, using an authenticated request.
  Future<Result<List<E>>> authList<E>(String url, Parser<E> parser) async {
    Map<String, String> headers = jsonHeader;
    if (url != _schoolsUrl) {
      /// we don't need authentication when getting schools.
      headers.addAll(authHeader());
    }
    return _requestController
        .get(url, headers)
        .then((response) => parseListResponse(response, parser));
    //.then((body) => body.map<E>((e) => parser(e)).toList());
  }

  ///Returns E, using an authenticated request.
  Future<Result<E>> auth<E>(String url, Parser parser) async {
    Map<String, String> headers = jsonHeader;
    headers.addAll(authHeader());
    return _requestController
        .get(url, headers)
        .then((response) => parseResponse(response, parser));
  }

  Result<E> parseResponse<E>(http.Response response, Parser parser) {
    try {
      Map<String, dynamic> src = json.decode(response.body);
      Result<E> result = Result(exception: null, value: parser(src));
      return result;
    } catch (e) {
      return Result(exception: e, value: null);
    }
  }

  Result<List<E>> parseListResponse<E>(http.Response response, Parser parser) {
    try {
      List src = json.decode(response.body);
      Result<List<E>> result =
      Result(exception: null, value: src.map<E>((e) => parser(e)).toList());
      return result;
    } catch (e) {
      return Result(exception: e, value: null);
    }
  }

  void processResponse(http.Response response) {
    _cookieManager.processHeaders(Utils.decodeHeaders(response.headers));
  }

  ///The authentication header.
  Map<String, String> authHeader() {
    Map<String, String> headers = Map();

    ///uniquId is NOT a typo!
    ///I...I really don't know why they named it that way.
    ///just... go on
    headers["cookie"] =
        "uniquId=${_cookieManager.uniqueId}; MashovSessionID=${_cookieManager.mashovSessionId}; Csrf-Token=${_cookieManager.csrfToken}";
    headers["x-csrf-token"] = _cookieManager.csrfToken;
    return headers;
  }

  Map<String, String> loginHeader() {
    Map<String, String> headers = new Map();
    headers["x-csrf-token"] = _cookieManager.csrfToken;
    return headers;
  }

  Map<String, String> jsonHeader;
  static const String _baseUrl = "https://svc.mashov.info/api/";
  static const String _schoolsUrl = _baseUrl + "schools";
  static const String _loginUrl = _baseUrl + "login";
  static const String _messagesCountUrl = _baseUrl + "mail/counts";

  static String _gradesUrl(String userId) =>
      _baseUrl + "students/$userId/grades";

  static String _behaveUrl(String userId) =>
      _baseUrl + "students/$userId/behave";

  static String _messagesUrl(int skip) =>
      _baseUrl + "mail/inbox/conversations?skip=$skip";

  static String _messageUrl(String messageId) =>
      _baseUrl + "mail/messages/$messageId";

  static String _timetableUrl(String userId) =>
      _baseUrl + "students/$userId/timetable";

  static String _groupsUrl(String userId) =>
      _baseUrl + "students/$userId/groups";

  static String _maakavUrl(String userId) =>
      _baseUrl + "students/$userId/maakav";

  static String _homeworkUrl(String userId) =>
      _baseUrl + "students/$userId/homework";

  static String _pictureUrl(String userId) => _baseUrl + "user/$userId/picture";

  static String _attachmentUrl(String messageId, String fileId, String name) =>
      _baseUrl + "mail/messages/$messageId/files/$fileId/download/$name";

  static String _maakavAttachmentUrl(String maakavId, String userId,
      String fileId, String name) =>
      _baseUrl + "students/$userId/maakav/$maakavId/files/$fileId/$name";

  static String _alfonUrl(String userId, String groupId) =>
      _baseUrl +
          (groupId == "-1"
              ? "students/$userId/alfon"
              : "groups/$groupId/alfon");

  static const String _logoutUrl = _baseUrl + "logout";

  static const String _ApiVersion = "3.20181205";

  void setJsonHeader() {
    jsonHeader = new Map<String, String>();
    jsonHeader["Content-Type"] = "application/json;charset=UTF-8";
  }
}
