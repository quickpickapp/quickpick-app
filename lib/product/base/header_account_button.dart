import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/product/profile/profile_page.dart';

class HeaderAccountButton extends StatefulWidget
    implements PreferredSizeWidget {
  final Function signInCallback;

  const HeaderAccountButton({super.key, required this.signInCallback});

  @override
  State<HeaderAccountButton> createState() => _HeaderAccountButtonState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderAccountButtonState extends State<HeaderAccountButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(CupertinoIcons.person_crop_circle_fill, size: 40),
      color: const Color(0xFFB3B3B3),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              signInCallback: () {
                widget.signInCallback();
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
}
