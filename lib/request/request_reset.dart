import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/main.dart';
import 'package:quickpick/product/base/page.dart';

class RequestReset {
  Future<void> reset() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: "user");
    await storage.delete(key: "phone_number");
    await storage.delete(key: "name");
    await storage.delete(key: "authentication_token");
    await storage.delete(key: "refresh_token");
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    Alert(
      description: "connection.logout",
      icon: CupertinoIcons.exclamationmark_triangle,
      callback: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    ).show(context);
  }
}
