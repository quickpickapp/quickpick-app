import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/request/request.dart';
import 'package:quickpick/request/request_reset.dart';

class RequestRefresh {
  Future<bool>? _currentRefresh;

  Future<bool> refresh(context) {
    if (_currentRefresh != null) {
      return _currentRefresh!;
    }
    _currentRefresh =
        performRefresh(context).whenComplete(() => _currentRefresh = null);
    return _currentRefresh!;
  }

  Future<bool> performRefresh(context) async {
    const storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: "refreshToken") ?? "";
    if (refreshToken == "") {
      await RequestReset().reset(context);
      return false;
    }
    var response = await Request.post(
        url: "/user/authorization/refresh/",
        body: <String, String>{"refreshToken": refreshToken}).send(context);
    if (response == null || response.statusCode == 409) {
      return false;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] == false) {
      await RequestReset().reset(context);
      return false;
    }
    await storage.write(
        key: "authenticationToken", value: responseBody["authenticationToken"]);
    await storage.write(
        key: "refreshToken", value: responseBody["refreshToken"]);
    return true;
  }
}
