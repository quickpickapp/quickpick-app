import 'package:flutter/cupertino.dart';
import 'package:quickpick/product/base/page_body.dart';

class PickListBody extends ProductPageBody {
  final GlobalKey<_PickListBodyContentState> _key =
      GlobalKey<_PickListBodyContentState>();

  PickListBody({super.key})
      : super(
          name: "product.pick.list.label",
          unselectedIcon: CupertinoIcons.text_bubble,
          selectedIcon: CupertinoIcons.text_bubble_fill,
        );

  @override
  Widget content(BuildContext context) {
    return PickListBodyContent(key: _key);
  }
}

class PickListBodyContent extends StatefulWidget {
  const PickListBodyContent({super.key});

  @override
  State<PickListBodyContent> createState() => _PickListBodyContentState();
}

class _PickListBodyContentState extends State<PickListBodyContent> {
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
