import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/connection_alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/profile/profile_email_code_page.dart';
import 'package:quickpick/product/profile/profile_sign_up_body.dart';
import 'package:quickpick/request/request.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileEmailConnectPage extends StatefulWidget {
  final Function signInCallback;

  const ProfileEmailConnectPage({super.key, required this.signInCallback});

  @override
  State<ProfileEmailConnectPage> createState() =>
      _ProfileEmailConnectPageState();
}

class _ProfileEmailConnectPageState extends State<ProfileEmailConnectPage> {
  final TextEditingController _controller = TextEditingController();
  bool _legalChecked = false;
  bool _newsletterChecked = false;
  bool _isEmailValid = false;
  bool _hasTyped = false;
  bool _connecting = false;

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              LocaleText(
                "product.profile.email.connect.headline",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                onChanged: _checkEmail,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  hintText: Locales.string(
                    context,
                    "product.profile.email.connect.placeholder",
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    size: 25,
                  ),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: _buildInputBorder(),
                  enabledBorder: _buildInputBorder(),
                  focusedBorder: _buildInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              CheckboxListTile(
                title: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    children: [
                      TextSpan(
                        text: Locales.string(
                            context, "product.legal.compliant.1"),
                      ),
                      TextSpan(
                        text: Locales.string(
                            context, "product.legal.terms.of.service"),
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await launchUrl(Uri.parse(
                                "https://quickpick.com/terms-of-service/"));
                          },
                      ),
                      TextSpan(
                        text: Locales.string(
                            context, "product.legal.compliant.2"),
                      ),
                      TextSpan(
                        text: Locales.string(
                            context, "product.legal.privacy.policy"),
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await launchUrl(
                                Uri.parse("https://quickpick.com/privacy-policy/"));
                          },
                      ),
                      TextSpan(
                        text: Locales.string(
                            context, "product.legal.compliant.3"),
                      ),
                    ],
                  ),
                ),
                value: _legalChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _legalChecked = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                // checkbox before text
                activeColor: Colors.indigo, // optional styling
              ),
              CheckboxListTile(
                title: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    children: [
                      TextSpan(
                        text:
                            Locales.string(context, "product.legal.newsletter"),
                      ),
                    ],
                  ),
                ),
                value: _newsletterChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _newsletterChecked = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                // checkbox before text
                activeColor: Colors.indigo, // optional styling
              ),
              SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          (_isEmailValid && _legalChecked)
                              ? Colors.indigo
                              : Colors.indigo[200]),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      alignment: Alignment.center),
                  onPressed: (_isEmailValid && _legalChecked)
                      ? () {
                          requestBinding(context);
                        }
                      : null,
                  icon: Container(
                    margin: EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.login,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LocaleText(
                        "product.profile.email.connect.button",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      _connecting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  void requestBinding(context) async {
    setState(() {
      _connecting = true;
    });
    const storage = FlutterSecureStorage();
    var language = await storage.read(key: "language") ?? "de";
    var body = <String, Object>{
      "email": _controller.text,
      "language": language
    };
    var response = await Request.post(url: "/authentication/request/", body: body)
        .send(context);
    setState(() {
      _connecting = false;
    });
    if (response == null || response.statusCode == 409) {
      ConnectionAlert().show(context);
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      Alert(
        description: "product.profile.email.connect.failure.email.format",
        type: AlertType.error,
      ).show(context);
      return;
    }
    displayBindingCodePage(context, responseBody["user"]);
  }

  void displayBindingCodePage(context, user) {
    var codeController = TextEditingController();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEmailCodePage(
          controller: codeController,
          email: _controller.text,
          callback: (code) async {
            completeBinding(context, codeController, user, code);
          },
        ),
      ),
    );
  }

  void completeBinding(context, codeController, user, code) async {
    LoaderAlert().show(context);
    var body = <String, Object>{"code": code, "user": user};
    body.addAll(
        await ProfileSignUpBody().generate(_legalChecked, _newsletterChecked));
    var response = await Request.post(url: "/authentication/complete/", body: body)
        .send(context);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (response == null || response.statusCode == 409) {
      ConnectionAlert().show(context);
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      codeController.text = "";
      Alert(
        description: "product.profile.email.connect.failure.complete",
        type: AlertType.error,
      ).show(context);
      return;
    }
    await storeSignInResponse(responseBody);
    Alert(
      description: "product.profile.email.connect.success",
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
    widget.signInCallback();
  }

  Future<void> storeSignInResponse(responseBody) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "email", value: _controller.text);
    if (responseBody["user"] != null &&
        responseBody["authentication_token"] != null &&
        responseBody["refresh_token"] != null) {
      await storage.write(key: "user", value: responseBody["user"]);
      await storage.write(
          key: "authentication_token",
          value: responseBody["authentication_token"]);
      await storage.write(
          key: "refresh_token", value: responseBody["refresh_token"]);
    }
  }

  void _checkEmail(String value) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final isValid = emailRegExp.hasMatch(value);
    setState(() {
      _hasTyped = true;
      _isEmailValid = isValid;
    });
  }

  OutlineInputBorder _buildInputBorder() {
    Color borderColor;
    if (!_hasTyped) {
      borderColor = Colors.grey;
    } else {
      borderColor = _isEmailValid ? Colors.green : Colors.red;
    }
    return OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 2.0),
      borderRadius: BorderRadius.circular(12),
    );
  }
}
