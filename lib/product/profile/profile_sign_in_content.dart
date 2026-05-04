import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/product/profile/profile_apple_alert.dart';
import 'package:quickpick/product/profile/profile_email_connect_page.dart';
import 'package:quickpick/product/profile/profile_google_alert.dart';

class ProfileSignInContent extends StatelessWidget {
  final Function signInCallback;
  bool showDisclaimer;

  ProfileSignInContent(
      {super.key, required this.signInCallback, this.showDisclaimer = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showDisclaimer ? Container(
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
                "product.profile.account.disclaimer.headline",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 5),
              LocaleText(
                "product.profile.account.disclaimer.description",
                style: TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ) : SizedBox.shrink(),
        showDisclaimer ? SizedBox(height: 25) : SizedBox.shrink(),
        createSignInButton(
          Colors.indigo,
          Colors.white,
          FontAwesomeIcons.envelope,
          "product.profile.account.email.button",
              () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfileEmailConnectPage(
                      signInCallback: signInCallback,
                    ),
              ),
            );
          },
        ),
        SizedBox(height: Platform.isIOS ? 10 : 0),
        Platform.isIOS
            ? createSignInButton(
          Colors.black,
          Colors.white,
          FontAwesomeIcons.apple,
          "product.profile.account.apple.button",
              () async {
            ProfileAppleAlert(signInCallback: signInCallback)
                .show(context);
          },
        )
            : SizedBox.shrink(),
        SizedBox(height: 10),
        createSignInButton(
          Platform.isIOS ? Colors.white : Colors.black,
          Platform.isIOS ? Colors.black : Colors.white,
          FontAwesomeIcons.google,
          "product.profile.account.google.button",
              () async {
            ProfileGoogleAlert(signInCallback: signInCallback).show(context);
          },
        ),
      ],
    );
  }

  Widget createSignInButton(backgroundColor, foregroundColor, icon, text,
      onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(backgroundColor),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.black12,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          padding: WidgetStateProperty.all(EdgeInsets.all(15)),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              alignment: Alignment.center,
              child: FaIcon(
                icon,
                color: foregroundColor,
                size: 25,
              ),
            ),
            SizedBox(width: 15),
            LocaleText(
              text,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
