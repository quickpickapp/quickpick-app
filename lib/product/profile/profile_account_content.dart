import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/product/profile/profile_email_change_page.dart';
import 'package:quickpick/product/profile/profile_logout.dart';
import 'package:quickpick/product/profile/profile_page.dart';

class ProfileAccountContent extends StatelessWidget {
  final Function signInCallback;
  final String email;

  const ProfileAccountContent(
      {super.key, required this.email, required this.signInCallback});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: Colors.grey[400]!,
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocaleText(
                "product.profile.account.email.headline",
                style: TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 5),
              Text(
                email,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 20),
              OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                        alignment: Alignment.center),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEmailChangePage(),
                        ),
                      );
                    },
                    icon: Container(
                      margin: EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LocaleText(
                          "product.profile.email.change",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.indigo),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                        alignment: Alignment.center),
                    onPressed: () async {
                      Alert(
                        description: "product.profile.logout.alert",
                        icon: CupertinoIcons.exclamationmark_triangle,
                        confirmButtonText: "product.profile.logout.continue",
                        confirmButtonColor: Colors.redAccent,
                        cancelButton: true,
                        callback: () {
                          logout(context);
                        },
                      ).show(context);
                    },
                    icon: Container(
                      margin: EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LocaleText(
                          "product.profile.logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  void logout(context) async {
    LoaderAlert().show(context);
    await ProfileLogout().logout(context);
    signInCallback();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ProfilePage(
                signInCallback: signInCallback,
              ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero),
      (Route<dynamic> route) => route.isFirst,
    );
  }
}
