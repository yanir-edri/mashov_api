import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mashov_api/src/controller/cookie_manager.dart';
import 'package:mashov_api/src/controller/request_controller.dart';
import 'package:mashov_api/src/models.dart';
import 'package:mashov_api/src/utils.dart';

typedef Parser<E> = E Function(Map<String, dynamic> src);
typedef DataProcessor = void Function(dynamic data, Api api);
typedef RawDataProcessor = void Function(String json, Api api);

class ApiController {
  CookieManager _cookieManager;
  RequestController _requestController;
  DataProcessor _dataProcessor;
  RawDataProcessor _rawDataProcessor;

  detachDataProcessor() {
    _dataProcessor = null;
  }

  attachDataProcessor(DataProcessor processor) {
    if (processor != null) {
      _dataProcessor = processor;
    }
  }

  detachRawDataProcessor() {
    _rawDataProcessor = null;
  }

  attachRawDataProcessor(RawDataProcessor processor) {
    if (processor != null) {
      _rawDataProcessor = processor;
    }
  }

  ApiController(CookieManager manager, RequestController controller) {
    _setJsonHeader();
    _cookieManager = manager;
    _requestController = controller;
    _rawDataProcessor = null;
    _dataProcessor = null;
  }

  ///returns a list of schools.
  Future<Result<List<School>>> getSchools() =>
      _authList(_schoolsUrl, School.fromJson, Api.Schools);

  ///logs in to the Mashov API.
  Future<Result<Login>> login(School school, String id, String password,
      int year) async {
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
    headers.addAll(_loginHeader());
    try {
      return _requestController
          .post(_loginUrl, headers, json.encode(body))
          .then((response) {
        if (response.statusCode != 200) {
          return Result(
              exception: null, value: null, statusCode: response.statusCode);
        }
        processResponse(response);
        Login login =
        Login.fromJson(json.decode(utf8.decode(response.bodyBytes)));
        return Result(
            exception: null, value: login, statusCode: response.statusCode);
      }).catchError((e) => Result(exception: e, value: null, statusCode: -1));
    } catch (e) {
      return Result(exception: e, value: null, statusCode: -1);
    }
  }

  ///Returns a list of grades.
  Future<Result<List<Grade>>> getGrades(String userId) =>
      _process(
          _authList<Grade>(_gradesUrl(userId), Grade.fromJson, Api.Grades),
          Api.Grades);

  ///Returns a list of behave events.
  Future<Result<List<BehaveEvent>>> getBehaveEvents(String userId) =>
      _process(
          _authList<BehaveEvent>(
              _behaveUrl(userId), BehaveEvent.fromJson, Api.BehaveEvents),
          Api.BehaveEvents);

  ////Returns the messages count - all, inbox, new and unread.
  Future<Result<MessagesCount>> getMessagesCount() =>
      _process(
          _auth(_messagesCountUrl, MessagesCount.fromJson, Api.MessagesCount),
          Api.MessagesCount)
          .then((r) =>
          Result(
              exception: r.exception,
              statusCode: r.statusCode,
              value: r.value == null ? null : r.value as MessagesCount));

  ///Returns a list of conversations.
  Future<Result<List<Conversation>>> getMessages(int skip) =>
      _process(
          _authList(_messagesUrl(skip), Conversation.fromJson, Api.Messages),
          Api.Messages);

  ///Returns a specific message.
  Future<Result<Message>> getMessage(String messageId) =>
      _process(
          _auth(_messageUrl(messageId), Message.fromJson, Api.Message),
          Api.Message)
          .then((r) =>
          Result(
              exception: r.exception,
              statusCode: r.statusCode,
              value: r.value == null ? null : r.value as Message));

  ///Returns the user timetable.
  Future<Result<List<Lesson>>> getTimeTable(String userId) =>
      _process(
          _authList(_timetableUrl(userId), Lesson.fromJson, Api.Timetable),
          Api.Timetable);

  ///Returns a list of the Alfon Groups.
  ///The class group is a different address, so we use an id -1 to access it.
  Future<Result<List<Group>>> getGroups(String userId) =>
      _process(
          _authList(_groupsUrl(userId), Group.fromJson, Api.Groups).then((
              groups) {
            groups.value.add(Group(id: -1, teacher: "", subject: "כיתה"));
            return groups;
          }),
          Api.Groups);

  ///returns an Alfon Group contacts.
  Future<Result<List<Contact>>> getContacts(String userId, String groupId) =>
      _process(
          _authList(_alfonUrl(userId, groupId), Contact.fromJson, Api.Alfon),
          Api.Alfon);

  ///Returns a list of Maakav reports.
  Future<Result<List<Maakav>>> getMaakav(String userId) =>
      _process(
          _authList(_maakavUrl(userId), Maakav.fromJson, Api.Maakav),
          Api.Maakav);

  ///Returns a list of homework.
  Future<Result<List<Homework>>> getHomework(String userId) =>
      _process(
          _authList(_homeworkUrl(userId), Homework.fromJson, Api.Homework),
          Api.Homework);

  ///Returns a list of bagrut exams, combining both dates, times, room and grades.
  ///This will NOT go through raw data processor as it takes the data
  ///from two sources.
  Future<Result<List<Bagrut>>> getBagrut(String userId) async {
    try {
      Map<String, String> headers = jsonHeader;
      List gradesMaps = await _requestController
          .get(_bagrutGradesUrl(userId), headers)
          .then((response) => json.decode(response.body));
      List timesMaps = await _requestController
          .get(_bagrutTimeUrl(userId), headers)
          .then((response) => json.decode(response.body));
      List<Map> maps = [];
      gradesMaps.forEach((g) {
        int semel = Utils.integer(g["semel"]);
        Map matchingTime = timesMaps.firstWhere((m) =>
        Utils.integer(m["semel"]) == semel, orElse: () => null);
        maps.add(matchingTime == null ? g : Utils.mergeMaps(g, matchingTime));
      });
      List<Bagrut> bagrut = maps.map((m) => Bagrut.fromJson(m)).toList();
      if (_dataProcessor != null) _dataProcessor(bagrut, Api.Bagrut);
      return Result<List<Bagrut>>(
          exception: null, value: bagrut, statusCode: 200);
    } catch (e) {
      return Result(exception: e, value: null, statusCode: 200);
    }
  }

  //Returns the user's hatamot.
  Future<Result<List<Hatama>>> getHatamot(String userId) =>
      _process(
          _authList(_hatamotUrl(userId), Hatama.fromJson, Api.Hatamot),
          Api.Hatamot);

  ///Returns the user profile.
  Future<File> getPicture(String userId, File file) {
    Map<String, String> headers = jsonHeader;
    headers.addAll(_authHeader());
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
    headers.addAll(_authHeader());
    return _requestController
        .get(_attachmentUrl(messageId, fileId, name), headers)
        .then((response) => response.bodyBytes)
        .then((attachment) => file.writeAsBytes(attachment));
  }

  Future<File> getMaakavAttachment(String maakavId, String userId,
      String fileId, String name, File file) {
    Map<String, String> headers = jsonHeader;
    headers.addAll(_authHeader());
    return _requestController
        .get(_maakavAttachmentUrl(maakavId, userId, fileId, name), headers)
        .then((response) => response.bodyBytes)
        .then((attachment) => file.writeAsBytes(attachment));
  }

  ///Returns a list of E, using an authenticated request.
  Future<Result<List<E>>> _authList<E>(String url, Parser<E> parser,
      Api api) async {
    Map<String, String> headers = jsonHeader;
    if (url != _schoolsUrl) {
      /// we don't need authentication when getting schools.
      headers.addAll(_authHeader());
    }
    return _requestController
        .get(url, headers)
        .then((response) => _parseListResponse(response, parser, api));
    //.then((body) => body.map<E>((e) => parser(e)).toList());
  }

  ///Returns E, using an authenticated request.
  Future<Result<E>> _auth<E>(String url, Parser parser, Api api) async {
    Map<String, String> headers = jsonHeader;
    headers.addAll(_authHeader());
    return _requestController
        .get(url, headers)
        .then((response) => _parseResponse(response, parser, api));
  }

  Result<E> _parseResponse<E>(http.Response response, Parser parser, Api api) {
    try {
      Map<String, dynamic> src = json.decode(response.body);
      Result<E> result = Result(
          exception: null, value: parser(src), statusCode: response.statusCode);
      //if it had not crashed, we know the data is good.
      if (_rawDataProcessor != null) {
        _rawDataProcessor(response.body, api);
      }
      return result;
    } catch (e) {
      return Result(exception: e, value: null, statusCode: response.statusCode);
    }
  }

  Result<List<E>> _parseListResponse<E>(http.Response response, Parser parser,
      Api api) {
    try {
      List src = json.decode(response.body);
      Result<List<E>> result = Result(
          exception: null,
          value: src.map<E>((e) => parser(e)).toList(),
          statusCode: response.statusCode);
      //if it had not crashed, we know the data is good.
      if (_rawDataProcessor != null) {
        _rawDataProcessor(response.body, api);
      }
      return result;
    } catch (e) {
      return Result(exception: e, value: null, statusCode: response.statusCode);
    }
  }

  void processResponse(http.Response response) {
    _cookieManager.processHeaders(Utils.decodeHeaders(response.headers));
  }

  ///The authentication header.
  Map<String, String> _authHeader() {
    Map<String, String> headers = Map();

    ///uniquId is NOT a typo!
    ///I...I really don't know why they named it that way.
    ///just... go on
    headers["cookie"] =
    "uniquId=${_cookieManager.uniqueId}; MashovSessionID=${_cookieManager
        .mashovSessionId}; Csrf-Token=${_cookieManager.csrfToken}";
    headers["x-csrf-token"] = _cookieManager.csrfToken;
    return headers;
  }

  Map<String, String> _loginHeader() {
    Map<String, String> headers = new Map();
    headers["x-csrf-token"] = _cookieManager.csrfToken;
    headers["accept-encoding"] = "gzip";
    return headers;
  }

  Map<String, String> jsonHeader;
  static const String _baseUrl = "https://web.mashov.info/api/";
  static const String _schoolsUrl = _baseUrl + "schools";
  static const String _loginUrl = _baseUrl + "login";
  static const String _messagesCountUrl = _baseUrl + "mail/counts";

  static String _gradesUrl(String userId) =>
      _baseUrl + "students/$userId/grades";

  static String _bagrutGradesUrl(String userId) =>
      _baseUrl + "students/$userId/bagrut/grades";

  static String _bagrutTimeUrl(String userId) =>
      _baseUrl + "students/$userId/bagrut/sheelonim";

  static String _hatamotUrl(String userId) =>
      _baseUrl + "students/$userId/hatamot";

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

  static const String _ApiVersion = "3.20190514";

  _setJsonHeader() {
    jsonHeader = new Map<String, String>();
    jsonHeader["content-type"] = "application/json;charset=UTF-8";
    jsonHeader["accept"] = "application/json, text/plain, */*";
    jsonHeader["accept-language"] = "en-US,en;q=0.9;he;q=0.8";
  }

  Future<Result> _process(Future<Result> data, Api api) {
    if (_dataProcessor != null) {
      if (data is Future<Result>) {
        data.then((result) {
          if (result.isSuccess) {
//            print(
//                "result was successful in process: ${result.value.toString()}");
            _dataProcessor(result.value, api);
          }
        });
      } else {
        print(
            "Api controller data proccessor recieved data which is not of type Future<Result>");
        _dataProcessor(data, api);
      }
    }
    return data;
  }
}

enum Api {
  Schools,
  Login,
  Grades,
  Bagrut,
  BehaveEvents,
  Groups,
  Timetable,
  Alfon,
  Messages,
  Message,
  Details,
  MessagesCount,
  Maakav,
  Homework,
  Hatamot
}
