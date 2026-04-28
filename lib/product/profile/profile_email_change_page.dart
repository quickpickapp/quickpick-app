import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/connection_alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/profile/profile_email_code_page.dart';
import 'package:quickpick/request/request.dart';

class ProfileEmailChangePage extends StatefulWidget {
  const ProfileEmailChangePage({super.key});

  @override
  State<ProfileEmailChangePage> createState() => _ProfileEmailChangePageState();
}

class _ProfileEmailChangePageState extends State<ProfileEmailChangePage> {
  final TextEditingController _controller = TextEditingController();
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
                "product.profile.email.change.headline",
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
                    "product.profile.email.change.placeholder",
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
              SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          _isEmailValid ? Colors.indigo : Colors.indigo[200]),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      alignment: Alignment.center),
                  onPressed: _isEmailValid
                      ? () {
                          requestEmailChange(context);
                        }
                      : null,
                  icon: Container(
                    margin: EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LocaleText(
                        "product.profile.email.change.button",
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

  void requestEmailChange(context) async {
    setState(() {
      _connecting = true;
    });
    const storage = FlutterSecureStorage();
    var language = await storage.read(key: "language") ?? "de";
    var body = <String, Object>{
      "email": _controller.text,
      "language": language
    };
    var response =
        await Request.post(url: "/email/change/request/", body: body)
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
      displayEmailChangeRequestError(context, responseBody["error"]);
      return;
    }
    displayEmailChangeCodePage(context);
  }

  void displayEmailChangeRequestError(context, error) {
    var description = "";
    if (error == 1000) {
      description = "product.profile.email.change.failure.email.format";
    } else if (error == 1001) {
      description = "product.profile.email.change.failure.already.used";
    }
    Alert(
      description: description,
      type: AlertType.error,
    ).show(context);
    return;
  }

  void displayEmailChangeCodePage(context) {
    var codeController = TextEditingController();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEmailCodePage(
          controller: codeController,
          email: _controller.text,
          callback: (code) async {
            completeEmailChange(context, codeController, code);
          },
        ),
      ),
    );
  }

  void completeEmailChange(context, codeController, code) async {
    LoaderAlert().show(context);
    var body = <String, Object>{"code": code};
    var response =
        await Request.post(url: "/email/change/complete/", body: body)
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
      displayEmailChangeCompleteError(context, responseBody["error"]);
      return;
    }
    await storeEmailChangeResponse(responseBody);
    Alert(
      description: "product.profile.email.change.success",
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
  }

  void displayEmailChangeCompleteError(context, error) {
    var description = "";
    if (error == 1000) {
      description = "product.profile.email.change.failure.expired";
    } else if (error == 1001) {
      description = "product.profile.email.change.failure.code";
    } else if (error == 1002) {
      description = "product.profile.email.change.failure.already.used";
    }
    Alert(
      description: description,
      type: AlertType.error,
    ).show(context);
    return;
  }

  Future<void> storeEmailChangeResponse(responseBody) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "email", value: _controller.text);
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
