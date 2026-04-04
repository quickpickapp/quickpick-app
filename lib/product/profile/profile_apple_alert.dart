import 'dart:convert';

import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/connection_alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/profile/profile_legal_alert.dart';
import 'package:quickpick/product/profile/profile_sign_up_body.dart';
import 'package:quickpick/request/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class ProfileAppleAlert {
  final Function signInCallback;

  ProfileAppleAlert({required this.signInCallback});

  show(context) {
    ProfileLegalAlert(
      callback: (legalChecked, newsletterChecked) {
        processAppleSignIn(context, legalChecked, newsletterChecked);
      },
    ).show(context);
  }

  Future<void> processAppleSignIn(
      context, legalChecked, newsletterChecked) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
      );
      final idToken = credential.identityToken;
      LoaderAlert().show(context);
      await sendInternalAppleSignInRequest(
          context, idToken, legalChecked, newsletterChecked);
    } catch (exception) {
      ConnectionAlert().show(context);
    }
  }

  Future<void> sendInternalAppleSignInRequest(
      context, idToken, legalChecked, newsletterChecked) async {
    var body = <String, Object>{"token": idToken};
    body.addAll(
        await ProfileSignUpBody().generate(legalChecked, newsletterChecked));
    var response =
        await Request.post(url: "/user/bind/apple/", body: body).send(context);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (response == null || response.statusCode == 409) {
      ConnectionAlert().show(context);
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      Alert(
        description: "product.profile.apple.connect.failure",
        type: AlertType.error,
      ).show(context);
      return;
    }
    completeAppleSignIn(context, responseBody);
  }

  void completeAppleSignIn(context, responseBody) async {
    await storeSignInResponse(responseBody);
    Alert(
      description: "product.profile.apple.connect.success",
      type: AlertType.success,
      callback: () {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductPage(),
          ),
          (route) => false,
        );
      },
    ).show(context);
    signInCallback();
  }

  Future<void> storeSignInResponse(responseBody) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "email", value: responseBody["email"]);
    if (responseBody["user"] != null &&
        responseBody["authenticationToken"] != null &&
        responseBody["refreshToken"] != null) {
      await storage.write(key: "user", value: responseBody["user"]);
      await storage.write(
          key: "authenticationToken",
          value: responseBody["authenticationToken"]);
      await storage.write(
          key: "refreshToken", value: responseBody["refreshToken"]);
    }
  }
}
