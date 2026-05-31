import 'package:flutter/material.dart';
import 'package:quickpick/product/base/header.dart';
import 'package:quickpick/product/base/navigator.dart';
import 'package:quickpick/product/base/page_body.dart';
import 'package:quickpick/product/friend/friends_body.dart';
import 'package:quickpick/product/pick/pick_button.dart';
import 'package:quickpick/product/pick/pick_list_body.dart';

class ProductPage extends StatefulWidget {
  final int? initialPageIndex;

  const ProductPage({super.key, this.initialPageIndex = 0});

  @override
  State<ProductPage> createState() => ProductPageState();
}

class ProductPageState extends State<ProductPage> {
  final List<ProductPageBody> pageBodies = [
    PickListBody(),
    FriendsBody(),
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: Header(),
        bottomNavigationBar: ProductNavigator(
          selectedIndex: _selectedIndex,
          updateIndex: _onItemTapped,
          pageBodies: pageBodies,
        ),
        body:
            pageBodies[_selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex]
                .content(context),
        backgroundColor: Color(0xFFFAFAFA),
        floatingActionButton: PickButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
