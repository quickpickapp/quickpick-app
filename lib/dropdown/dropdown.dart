import 'package:flutter/material.dart';
import 'package:quickpick/dropdown/dropdown_item.dart';

class Dropdown extends StatelessWidget {
  final Widget icon;
  final List<DropdownItem> items;

  const Dropdown({super.key, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    List<PopupMenuEntry<String>> entries = [];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        entries.add(createDropdownDivider());
      }
      entries.add(
        PopupMenuItem(padding: EdgeInsets.zero, child: items[i]),
      );
    }
    return PopupMenuButton<String>(
      icon: icon,
      offset: Offset(0, 45),
      menuPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
        side: BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      elevation: 0,
      itemBuilder: (BuildContext context) => entries,
    );
  }

  PopupMenuItem<String> createDropdownDivider() {
    return PopupMenuItem(
      enabled: false,
      padding: EdgeInsets.zero,
      height: 1,
      child: Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFE0E0E0),
      ),
    );
  }
}
