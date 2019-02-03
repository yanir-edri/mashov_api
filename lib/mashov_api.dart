library mashov_api;

import 'package:mashov_api/src/controller/api_controller.dart';
import 'package:mashov_api/src/controller/cookie_manager_impl.dart';
import 'package:mashov_api/src/controller/request_controller_impl.dart';

export 'src/controller/api_controller.dart';
export 'src/controller/cookie_manager.dart';
export 'src/controller/cookie_manager_impl.dart';
export 'src/controller/request_controller.dart';
export 'src/controller/request_controller_impl.dart';
export 'src/models.dart';

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
