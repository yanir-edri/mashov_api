library mashov_api;

import 'package:mashov_api/src/controller/api_controller.dart';
import 'package:mashov_api/src/controller/cookie_manager_impl.dart';
import 'package:mashov_api/src/controller/request_controller_impl.dart';

export 'src/controller/api_controller.dart';
export 'src/controller/cookie_manager.dart';
export 'src/controller/cookie_manager_impl.dart';
export 'src/controller/request_controller.dart';
export 'src/controller/request_controller_impl.dart';
export 'src/models/attachment.dart';
export 'src/models/behave_event.dart';
export 'src/models/contact.dart';
export 'src/models/conversation.dart';
export 'src/models/grade.dart';
export 'src/models/group.dart';
export 'src/models/homework.dart';
export 'src/models/lesson.dart';
export 'src/models/login.dart';
export 'src/models/login_data.dart';
export 'src/models/maakav.dart';
export 'src/models/message.dart';
export 'src/models/message_title.dart';
export 'src/models/messages_count.dart';
export 'src/models/result.dart';
export 'src/models/school.dart';
export 'src/models/student.dart';

class MashovApi {
  static ApiController _controller;

  static ApiController getController() {
    if (_controller == null) {
      _controller =
          ApiController(CookieManagerImpl(), RequestControllerImpl());
    }
    return _controller;
  }
}
