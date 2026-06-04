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
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Stack(
        children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color.lerp(
                Theme.of(context).colorScheme.onSurface,
                Theme.of(context).colorScheme.primary,
                0.8),
            currentIndex: widget.selectedIndex,
            onTap: (index) {
              setState(() {
                notificationCounts[index] = 0;
              });
              widget.updateIndex(index);
            },
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
    var primaryColor = Theme.of(context).colorScheme.primary;
    var textColor = Theme.of(context).colorScheme.onSurface;
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
            color:
                isSelected ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (count != null && count > 9) ? 5 : 0),
            child: Icon(
              isSelected ? body.selectedIcon : body.unselectedIcon,
              size: 30,
              color: isSelected
                  ? Color.lerp(textColor, primaryColor, 0.8)
                  : textColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      ];

      if (count != null && count != 0) {
        iconChildren.add(createNotificationBadge(count));
      }

      items.add(BottomNavigationBarItem(
        icon: Stack(children: iconChildren),
        label: Locales.string(context, body.name),
      ));
    }
    return items;
  }

  Widget createNotificationBadge(int count) {
    if (count == -1) {
      return Positioned(
        right: 0,
        top: 0,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
      );
    }
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: count < 10 ? 20 : null,
        height: 20,
        padding: count < 10
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
