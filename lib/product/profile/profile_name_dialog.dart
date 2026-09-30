import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/request/request.dart';

class ProfileNameDialog {
  static Future<void> show(BuildContext context, String? currentName) async {
    final controller = TextEditingController(text: currentName);

    OutlineInputBorder buildInputBorder() {
      return OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      );
    }

    Alert(
      icon: CupertinoIcons.pencil,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 50,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.grey[500]),
            hintText: Locales.string(
              context,
              "product.profile.account.name",
            ),
            prefixIcon: Icon(Icons.person, size: 25),
            isDense: true,
            counterText: "",
            contentPadding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            border: buildInputBorder(),
            enabledBorder: buildInputBorder(),
            focusedBorder: buildInputBorder(),
            filled: true,
            fillColor: Theme.of(context).appBarTheme.backgroundColor,
          ),
        ),
      ),
      cancelButton: true,
      confirmButtonText: "product.profile.save",
      callback: () {
        final newName = controller.text.trim();
        if (newName.isEmpty) return;
        _changeName(context, newName);
      },
    ).show(context);
  }

  static Future<void> _changeName(BuildContext context, String newName) async {
    LoaderAlert().show(context);
    var body = <String, String>{"name": newName};
    var response =
        await Request.post(url: "/user/name/change/", body: body).send();
    if (!context.mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (response == null || response.statusCode == 429) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] != true) {
      return;
    }
    const storage = FlutterSecureStorage();
    await storage.write(key: "name", value: newName);
  }
}
