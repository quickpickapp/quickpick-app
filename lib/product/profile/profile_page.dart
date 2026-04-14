import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/product/profile/profile_account_content.dart';
import 'package:quickpick/product/profile/profile_footer_link.dart';
import 'package:quickpick/product/profile/profile_language_selection.dart';
import 'package:quickpick/product/profile/profile_notification_toggle.dart';
import 'package:quickpick/product/profile/profile_sign_in_content.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfilePage extends StatefulWidget {
  final Function signInCallback;

  const ProfilePage({super.key, required this.signInCallback});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget? accountContentElement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black12,
            height: 1.0,
          ),
        ),
      ),
      backgroundColor: Color(0xFFFAFAFA),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 30),
                        LocaleText(
                          "product.profile.account",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 5),
                        accountContent(),
                        SizedBox(height: 30),
                        LocaleText(
                          "product.profile.language",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        ProfileLanguageSelection(),
                        SizedBox(height: 30),
                        LocaleText(
                          "product.profile.notification",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        ProfileNotificationToggle(),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: 50),
                        Divider(
                          color: Colors.grey[300],
                          height: 2,
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.center,
                            children: [
                              ProfileFooterLink(
                                  text: "product.profile.imprint",
                                  url: "https://quickpick.com/imprint/"),
                              ProfileFooterLink(
                                  text: "product.profile.terms.of.service",
                                  url: "https://quickpick.com/terms-of-service/"),
                              ProfileFooterLink(
                                  text: "product.profile.privacy.policy",
                                  url: "https://quickpick.com/privacy-policy/"),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              return Text(
                                "Version ${snapshot.data?.version ?? ""}",
                                style: TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget accountContent() {
    if (accountContentElement != null) {
      return accountContentElement!;
    }
    const storage = FlutterSecureStorage();
    return FutureBuilder<String?>(
      future: storage.read(key: "email"),
      builder: (context, AsyncSnapshot<String?> email) {
        if (email.connectionState == ConnectionState.done) {
          if (email.data != null && email.data != "") {
            accountContentElement = ProfileAccountContent(
                signInCallback: widget.signInCallback, email: email.data ?? "");
          } else {
            accountContentElement =
                ProfileSignInContent(signInCallback: widget.signInCallback);
          }
          return accountContentElement!;
        }
        return Skeletonizer(
          enabled: email.connectionState != ConnectionState.done,
          child: Skeleton.leaf(
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
