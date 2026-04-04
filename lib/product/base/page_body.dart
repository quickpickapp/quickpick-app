import 'package:flutter/material.dart';

abstract class ProductPageBody extends StatelessWidget {
  ProductPageBody(
      {super.key,
      required this.name,
      required this.unselectedIcon,
      required this.selectedIcon});

  final String name;
  final IconData unselectedIcon;
  final IconData selectedIcon;
  void Function()? navigatorCallback;

  @override
  Widget build(BuildContext context) {
    return content(context);
  }

  Widget content(BuildContext context);

  Future<int> notifications(context) async {
    return 0;
  }
}
