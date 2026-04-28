import 'package:flutter/material.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/profile/profile_sign_in_content.dart';

class SignupConnectPage extends StatefulWidget {
  const SignupConnectPage({super.key});

  @override
  State<SignupConnectPage> createState() => _SignupConnectPageState();
}

class _SignupConnectPageState extends State<SignupConnectPage> {
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
                  children: [
                    SizedBox(height: 50),
                    ProfileSignInContent(
                      signInCallback: () => {},
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () => {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductPage()))
                      },
                      child: LocaleText(
                        "product.signup.connect.skip",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
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
