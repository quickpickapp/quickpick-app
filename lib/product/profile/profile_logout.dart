import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/request/request.dart';

class ProfileLogout {
  Future<void> logout() async {
    await Request.get(url: "/user/logout/").send();
    await reset();
  }

  Future<void> reset() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: "user");
    await storage.delete(key: "phone_number");
    await storage.delete(key: "name");
    await storage.delete(key: "authentication_token");
    await storage.delete(key: "refresh_token");
  }
}
