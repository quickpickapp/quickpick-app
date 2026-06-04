import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/product/signup/signup_verify_page.dart';
import 'package:quickpick/request/request.dart';

class SignupPhonePage extends StatefulWidget {
  const SignupPhonePage({super.key});

  @override
  State<SignupPhonePage> createState() => _SignupPhonePageState();
}

class _SignupPhonePageState extends State<SignupPhonePage> {
  final _phoneController = TextEditingController();
  bool _hasTyped = false;
  bool _isPhoneValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _hasTyped = true;
      _isPhoneValid = digitsOnly.length >= 10;
    });
  }

  void _onContinue() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !_isPhoneValid) {
      return;
    }
    LoaderAlert().show(context);
    var body = <String, String>{"phone_number": phone};
    var response = await Request.post(url: "/signup/request/code/", body: body)
        .send(context);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (response == null || response.statusCode == 429) {
      _showFailedAlert();
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] != true) {
      _showFailedAlert();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupVerifyPage(phoneNumber: phone),
      ),
    );
  }

  void _showFailedAlert() {
    Alert(
      description: "product.signup.phone.failed",
      type: AlertType.error,
    ).show(context);
  }

  OutlineInputBorder _buildInputBorder() {
    Color borderColor;
    if (!_hasTyped) {
      borderColor = Colors.grey;
    } else {
      borderColor = _isPhoneValid ? Colors.green : Colors.red;
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.black12, height: 1.0),
        ),
      ),
      backgroundColor: Color(0xFFFAFAFA),
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
                          "product.signup.phone.label",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\+?\d*'),
                            ),
                            LengthLimitingTextInputFormatter(16),
                          ],
                          onChanged: _onPhoneChanged,
                          onSubmitted: (_) => _onContinue(),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            hintText: Locales.string(
                              context,
                              "product.signup.phone.placeholder",
                            ),
                            prefixIcon: Icon(Icons.phone, size: 25),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            border: _buildInputBorder(),
                            enabledBorder: _buildInputBorder(),
                            focusedBorder: _buildInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[200],
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
                              _isPhoneValid
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
                          onPressed: _isPhoneValid ? _onContinue : null,
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
