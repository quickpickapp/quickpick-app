import 'package:flutter/material.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/product/base/page_body.dart';

class ProductNavigator extends StatefulWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) updateIndex;
  final List<ProductPageBody> pageBodies;

  const ProductNavigator(
      {super.key,
      required this.selectedIndex,
      required this.updateIndex,
      required this.pageBodies});

  @override
  State<ProductNavigator> createState() => _ProductNavigatorState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProductNavigatorState extends State<ProductNavigator> {
  Map<int, int> notificationCounts = {};
  final _color = Colors.indigo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadNotifications(context);
      for (var i = 0; i < widget.pageBodies.length; i++) {
        var pageBody = widget.pageBodies[i];
        pageBody.controller.navigatorCallback = () {
          pageBody.notifications(context).then((count) {
            setState(() {
              notificationCounts[i] = count;
            });
          });
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: Stack(
        children: [
          BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color.lerp(Colors.black, _color, 0.8),
            currentIndex: widget.selectedIndex,
            onTap: widget.updateIndex,
            unselectedFontSize: 13,
            selectedFontSize: 13,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            items: navigationBarItems(context),
          ),
        ],
      ),
    );
  }

  void loadNotifications(context) {
    for (var i = 0; i < widget.pageBodies.length; i++) {
      widget.pageBodies[i].notifications(context).then((count) {
        setState(() {
          notificationCounts[i] = count;
        });
      });
    }
  }

  List<BottomNavigationBarItem> navigationBarItems(BuildContext context) {
    List<BottomNavigationBarItem> items = [];
    for (var i = 0; i < widget.pageBodies.length; i++) {
      var body = widget.pageBodies[i];
      bool isSelected = widget.selectedIndex == i;
      final count = notificationCounts[i];

      List<Widget> iconChildren = [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? _color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (count != null && count > 9) ? 5 : 0),
            child: Icon(
              isSelected ? body.selectedIcon : body.unselectedIcon,
              size: 30,
              color: isSelected
                  ? Color.lerp(Colors.black, _color, 0.8)
                  : Colors.black54,
            ),
          ),
        ),
      ];

      if (count != null && count > 0) {
        iconChildren.add(createNotificationBadge(count));
      }

      items.add(BottomNavigationBarItem(
        icon: Stack(children: iconChildren),
        label: Locales.string(context, body.name),
      ));
    }
    return items;
  }

  Widget createNotificationBadge(count) {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: count < 10 ? 16 : null,
        height: 16,
        padding: count < 10
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1)),
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            height: 1, // helps vertically center text
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
