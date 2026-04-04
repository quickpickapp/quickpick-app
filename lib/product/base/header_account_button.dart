import 'package:quickpick/product/profile/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    const storage = FlutterSecureStorage();
    return FutureBuilder<String?>(
      future: storage.read(key: "email"),
      builder: (context, AsyncSnapshot<String?> email) {
        return Stack(
          children: [
            IconButton(
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
            ),
            email.data == null || email.data == ""
                ? Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
