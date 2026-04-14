import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileLegalAlert {
  final Function callback;

  ProfileLegalAlert({required this.callback});

  show(context) {
    GlobalKey<_ProfileLegalAlertContentState> contentKey =
        GlobalKey<_ProfileLegalAlertContentState>();
    GlobalKey<AlertState> alertKey = GlobalKey<AlertState>();
    var content = _ProfileLegalAlertContent(
      key: contentKey,
      alertKey: alertKey,
    );
    Alert(
      key: alertKey,
      icon: CupertinoIcons.exclamationmark_triangle,
      confirmButtonText: "alert.continue",
      content: content,
      confirmButtonEnabled: () {
        var state = contentKey.currentState;
        if (state == null) {
          return false;
        }
        return state.legalChecked;
      },
      callback: () {
        var state = contentKey.currentState;
        if (state == null) {
          return false;
        }
        callback(state.legalChecked, state.newsletterChecked);
      },
    ).show(context);
  }
}

class _ProfileLegalAlertContent extends StatefulWidget {
  GlobalKey<AlertState> alertKey;

  _ProfileLegalAlertContent({super.key, required this.alertKey});

  @override
  State<_ProfileLegalAlertContent> createState() =>
      _ProfileLegalAlertContentState();
}

class _ProfileLegalAlertContentState extends State<_ProfileLegalAlertContent> {
  bool legalChecked = false;
  bool newsletterChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Column(
        children: [
          CheckboxListTile(
            title: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                children: [
                  TextSpan(
                    text: Locales.string(context, "product.legal.compliant.1"),
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
                        await launchUrl(
                            Uri.parse("https://quickpick.com/terms-of-service/"));
                      },
                  ),
                  TextSpan(
                    text: Locales.string(context, "product.legal.compliant.2"),
                  ),
                  TextSpan(
                    text:
                        Locales.string(context, "product.legal.privacy.policy"),
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
                    text: Locales.string(context, "product.legal.compliant.3"),
                  ),
                ],
              ),
            ),
            value: legalChecked,
            onChanged: (bool? newValue) {
              widget.alertKey.currentState?.reload();
              setState(() {
                legalChecked = newValue!;
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
                    text: Locales.string(context, "product.legal.newsletter"),
                  ),
                ],
              ),
            ),
            value: newsletterChecked,
            onChanged: (bool? newValue) {
              setState(() {
                newsletterChecked = newValue!;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            // checkbox before text
            activeColor: Colors.indigo, // optional styling
          ),
        ],
      ),
    );
  }
}
