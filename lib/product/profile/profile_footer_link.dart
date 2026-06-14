import 'package:flutter/material.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileFooterLink extends StatelessWidget {
  final String text;
  final String url;
  final double? fontSize;

  const ProfileFooterLink({
    super.key,
    required this.text,
    required this.url,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await launchUrl(Uri.parse(url));
      },
      child: LocaleText(
        text,
        style: TextStyle(
            decoration: TextDecoration.none, fontSize: fontSize ?? 14),
      ),
    );
  }
}
