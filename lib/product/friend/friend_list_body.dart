import 'package:quickpick/product/base/page_body.dart';
import 'package:flutter/cupertino.dart';

class FriendListBody extends ProductPageBody {
  final GlobalKey<_FriendListBodyContentState> _key =
  GlobalKey<_FriendListBodyContentState>();

  FriendListBody({super.key})
      : super(
    name: "product.friend.list.label",
    unselectedIcon: CupertinoIcons.group,
    selectedIcon: CupertinoIcons.group_solid,
  );

  @override
  Widget content(BuildContext context) {
    return FriendListBodyContent(key: _key);
  }
}

class FriendListBodyContent extends StatefulWidget {
  const FriendListBodyContent({super.key});

  @override
  State<FriendListBodyContent> createState() => _FriendListBodyContentState();
}

class _FriendListBodyContentState extends State<FriendListBodyContent> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
