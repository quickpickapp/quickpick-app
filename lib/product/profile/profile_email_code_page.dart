import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ProfileEmailCodePage extends StatefulWidget {
  final TextEditingController controller;
  final String email;
  final Function(String) callback;

  const ProfileEmailCodePage({
    super.key,
    required this.controller,
    required this.email,
    required this.callback,
  });

  @override
  State<ProfileEmailCodePage> createState() => _ProfileEmailCodePageState();
}

class _ProfileEmailCodePageState extends State<ProfileEmailCodePage> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.key, size: 35, color: Colors.grey[900]),
                ),
              ),
              SizedBox(height: 30),
              LocaleText(
                "product.profile.email.code.headline",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  children: [
                    TextSpan(
                      text: Locales.string(
                          context, "product.profile.email.code.description.1"),
                    ),
                    TextSpan(
                      text: widget.email,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: Locales.string(
                          context, "product.profile.email.code.description.2"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                animationType: AnimationType.scale,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  fieldOuterPadding: EdgeInsets.symmetric(horizontal: 5),
                  inactiveFillColor: Colors.transparent,
                  inactiveColor: Colors.grey[700],
                  selectedFillColor: Colors.transparent,
                  selectedColor: Colors.grey[700],
                  activeFillColor: Colors.transparent,
                  activeColor: Colors.grey[700],
                ),
                cursorColor: Colors.grey[700],
                animationDuration: const Duration(milliseconds: 100),
                enableActiveFill: true,
                autoFocus: true,
                mainAxisAlignment: MainAxisAlignment.center,
                controller: widget.controller,
                keyboardType: TextInputType.datetime,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onCompleted: (v) {
                  widget.callback(v);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
