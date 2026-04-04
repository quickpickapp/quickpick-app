import 'package:quickpick/product/base/header_account_button.dart';
import 'package:flutter/material.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final Function signInCallback;

  const Header({super.key, required this.signInCallback});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Image.asset(
        'assets/images/logo.png',
        width: 50,
      ),
      titleSpacing: 10,
      actions: <Widget>[
        HeaderAccountButton(signInCallback: widget.signInCallback)
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Container(
          color: Colors.black12,
          height: 1.0,
        ),
      ),
    );
  }
}
