import 'package:flutter/material.dart';
import 'package:quickpick/product/base/header.dart';
import 'package:quickpick/product/base/navigator.dart';
import 'package:quickpick/product/base/page_body.dart';
import 'package:quickpick/product/friend/friend_list_body.dart';
import 'package:quickpick/product/pick/pick_list_body.dart';

class ProductPage extends StatefulWidget {
  int? initialPageIndex = 0;

  ProductPage({super.key, this.initialPageIndex});

  @override
  State<ProductPage> createState() => ProductPageState();
}

class ProductPageState extends State<ProductPage> {
  final List<ProductPageBody> pageBodies = [
    PickListBody(),
    FriendListBody(),
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPageIndex ?? 0;
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        signInCallback: () => {},
      ),
      bottomNavigationBar: ProductNavigator(
        selectedIndex: _selectedIndex,
        updateIndex: _onItemTapped,
        pageBodies: pageBodies,
      ),
      body: pageBodies[_selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex]
          .content(context),
      backgroundColor: Color(0xFFFAFAFA),
    );
  }
}
