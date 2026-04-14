import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quickpick/request/request.dart';

class ProfileLogout {
  Future<void> logout(context) async {
    await Request.get(url: "/user/logout/").send(context);
    await reset(context);
  }

  Future<void> reset(context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: "email");
    await storage.delete(key: "user");
    await storage.delete(key: "authenticationToken");
    await storage.delete(key: "refreshToken");
    await GoogleSignIn.instance.signOut();
  }
}
