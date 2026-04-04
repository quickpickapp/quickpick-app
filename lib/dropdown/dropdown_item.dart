import 'package:quickpick/localization/locale_text.dart';
import 'package:flutter/material.dart';

class DropdownItem extends StatelessWidget {
  final String text;
  final Icon icon;
  final Color? color;
  final Function()? click;

  const DropdownItem({
    super.key,
    required this.text,
    required this.icon,
    this.color,
    this.click,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      iconColor: color,
      textColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      title: LocaleText(text),
      onTap: () {
        Navigator.pop(context);
        click?.call();
      },
    );
  }
}
