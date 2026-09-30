import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/signup/signup_body.dart';
import 'package:quickpick/product/signup/signup_store.dart';
import 'package:quickpick/request/request.dart';

class SignupNamePage extends StatefulWidget {
  final String phoneNumber;
  final String verificationToken;

  const SignupNamePage(
      {super.key, required this.phoneNumber, required this.verificationToken});

  @override
  State<SignupNamePage> createState() => _SignupNamePageState();
}

class _SignupNamePageState extends State<SignupNamePage> {
  final _nameController = TextEditingController();
  bool _hasTyped = false;
  bool _isNameValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    setState(() {
      _hasTyped = true;
      _isNameValid = value.trim().isNotEmpty;
    });
  }

  void _onContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    LoaderAlert().show(context);
    var body = await SignupBody().generate(widget.verificationToken, name);
    var response =
        await Request.post(url: "/signup/complete/", body: body).send();
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (response == null) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] != true) {
      Alert(
        description: "product.signup.name.failed",
        type: AlertType.error,
      ).show(context);
      return;
    }
    await SignupStore().save(responseBody);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPage(),
      ),
    );
  }

  OutlineInputBorder _buildInputBorder() {
    Color borderColor;
    if (!_hasTyped) {
      borderColor = Colors.grey;
    } else {
      borderColor = _isNameValid ? Colors.green : Colors.red;
    }
    return OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 2.0),
      borderRadius: BorderRadius.circular(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.black12, height: 1.0),
        ),
      ),
      resizeToAvoidBottomInset: true,
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
                        SizedBox(height: 50),
                        LocaleText(
                          "product.signup.name.label",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.done,
                          onChanged: _onNameChanged,
                          onSubmitted: (_) => _onContinue(),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            hintText: Locales.string(
                              context,
                              "product.signup.name.placeholder",
                            ),
                            prefixIcon: Icon(Icons.person, size: 25),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            border: _buildInputBorder(),
                            enabledBorder: _buildInputBorder(),
                            focusedBorder: _buildInputBorder(),
                            filled: true,
                            fillColor:
                                Theme.of(context).appBarTheme.backgroundColor,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              _isNameValid
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.5),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(vertical: 16),
                            ),
                            minimumSize: WidgetStateProperty.all(
                              Size(double.infinity, 0),
                            ),
                            alignment: Alignment.center,
                          ),
                          onPressed: _isNameValid ? _onContinue : null,
                          icon: Container(
                            margin: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          label: LocaleText(
                            "product.signup.continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
}
