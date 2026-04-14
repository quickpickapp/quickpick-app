import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/product/profile/profile_page.dart';

class FriendListEmptyContent extends StatelessWidget {
  final Function signInCallback;

  const FriendListEmptyContent({super.key, required this.signInCallback});

  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();
    return FutureBuilder<String?>(
      future: storage.read(key: "email"),
      builder: (context, AsyncSnapshot<String?> email) {
        return Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 20, bottom: 75),
          child: Stack(
            children: [
              email.data == null || email.data == ""
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child:
                    LocaleText("product.friend.list.new.description"),
                  ),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 0),
                        minimumSize: Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                signInCallback: signInCallback),
                          ),
                        );
                      },
                      child: LocaleText(
                        "product.friend.list.new.login",
                        style: TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
