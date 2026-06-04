import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/product/signup/signup_phone_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupLegalPage extends StatefulWidget {
  const SignupLegalPage({super.key});

  @override
  State<SignupLegalPage> createState() => _SignupLegalPageState();
}

class _SignupLegalPageState extends State<SignupLegalPage> {
  bool _accepted = false;

  void _onGetStarted() async {
    if (!_accepted) {
      return;
    }
    const storage = FlutterSecureStorage();
    await storage.write(key: "legal_accepted", value: "true");
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SignupPhonePage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _openTerms() async {
    await launchUrl(Uri.parse("https://quickpick.com/terms-of-service/"));
  }

  void _openPrivacyPolicy() async {
    await launchUrl(Uri.parse("https://quickpick.com/privacy-policy/"));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
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
                          SizedBox(height: 60),
                          Center(
                            child: Image.asset(
                              theme.brightness == Brightness.light
                                  ? 'assets/images/logo.png'
                                  : 'assets/images/logo-light.png',
                              width: 100,
                            ),
                          ),
                          SizedBox(height: 28),
                          LocaleText(
                            "product.signup.legal.title",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.9),
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          LocaleText(
                            "product.signup.legal.subtitle",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _accepted = !_accepted),
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _accepted,
                                      onChanged: (val) => setState(
                                          () => _accepted = val ?? false),
                                      activeColor: theme.colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey[400]!,
                                        width: 1.5,
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: Locales.string(context,
                                                "product.signup.legal.checkbox.prefix"),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          TextSpan(
                                            text: Locales.string(context,
                                                "product.signup.legal.checkbox.terms"),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  theme.colorScheme.primary,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = _openTerms,
                                          ),
                                          TextSpan(
                                            text: Locales.string(context,
                                                "product.signup.legal.checkbox.and"),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          TextSpan(
                                            text: Locales.string(context,
                                                "product.signup.legal.checkbox.privacy"),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  theme.colorScheme.primary,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = _openPrivacyPolicy,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  _accepted
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.primary
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
                              onPressed: _accepted ? _onGetStarted : null,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
