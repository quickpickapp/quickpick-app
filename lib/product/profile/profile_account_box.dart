import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/product/profile/profile_logout.dart';
import 'package:quickpick/product/signup/signup_phone_page.dart';

class ProfileAccountBox extends StatelessWidget {
  const ProfileAccountBox({super.key});

  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();
    return FutureBuilder<String?>(
      future: storage.read(key: "phone_number"),
      builder: (context, AsyncSnapshot<String?> phoneNumber) {
        return FutureBuilder<String?>(
          future: storage.read(key: "name"),
          builder: (context, AsyncSnapshot<String?> name) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LocaleText("product.profile.account.name"),
                          Text(": "),
                          Text(name.data ?? "-",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LocaleText("product.profile.account.phone.number"),
                          Text(": "),
                          Text(phoneNumber.data ?? "-",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 20),
                      OverflowBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        overflowAlignment: OverflowBarAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.indigo),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                padding: WidgetStateProperty.all(
                                    EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 8)),
                                alignment: Alignment.center),
                            onPressed: () async {
                              Alert(
                                description: "product.profile.logout.alert",
                                icon: CupertinoIcons.exclamationmark_triangle,
                                confirmButtonText:
                                    "product.profile.logout.continue",
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
          },
        );
      },
    );
  }

  void logout(context) async {
    LoaderAlert().show(context);
    await ProfileLogout().logout(context);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SignupPhonePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero),
      (Route<dynamic> route) => route.isFirst,
    );
  }
}
