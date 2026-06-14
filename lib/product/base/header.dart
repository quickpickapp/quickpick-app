import 'package:flutter/material.dart';
import 'package:quickpick/product/base/header_account_button.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AppBar(
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Image.asset(
        theme.brightness == Brightness.light
            ? 'assets/images/logo.png'
            : 'assets/images/logo-light.png',
        width: 50,
      ),
      titleSpacing: 10,
      actions: <Widget>[HeaderAccountButton()],
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Container(
          color: theme.dividerColor,
          height: 1.0,
        ),
      ),
    );
  }
}
