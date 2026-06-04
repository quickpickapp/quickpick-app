import 'dart:ffi';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignupStore {
  Future<Void?> save(response) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "user", value: response["user"]);
    await storage.write(key: "phone_number", value: response["phone_number"]);
    await storage.write(key: "name", value: response["name"]);
    await storage.write(
        key: "authentication_token",
        value: response["authentication_token"]);
    await storage.write(
        key: "refresh_token", value: response["refresh_token"]);
  }
}