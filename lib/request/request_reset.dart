import 'package:flutter/cupertino.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/profile/profile_logout.dart';

class RequestReset {
  reset(context) async {
    await ProfileLogout().reset(context);
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
