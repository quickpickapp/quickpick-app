import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/product/profile/profile_logout.dart';
import 'package:quickpick/product/profile/profile_name_dialog.dart';
import 'package:quickpick/product/signup/signup_phone_page.dart';

class ProfileAccountBox extends StatefulWidget {
  const ProfileAccountBox({super.key});

  @override
  State<ProfileAccountBox> createState() => _ProfileAccountBoxState();
}

class _ProfileAccountBoxState extends State<ProfileAccountBox> {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
                    color: theme.appBarTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: theme.dividerColor,
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
                          Expanded(
                            child: Text(name.data ?? "-",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await ProfileNameDialog.show(context, name.data);
                              setState(() {});
                            },
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
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
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).colorScheme.primary),
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

  Future<void> logout(BuildContext context) async {
    LoaderAlert().show(context);
    await ProfileLogout().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SignupPhonePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero),
      (Route<dynamic> route) => route.isFirst,
    );
  }
}
