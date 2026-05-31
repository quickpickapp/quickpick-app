import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/product/base/page_body.dart';
import 'package:quickpick/product/friend/friend_discover_tab.dart';
import 'package:quickpick/product/friend/friend_list_tab.dart';
import 'package:quickpick/product/friend/friend_invitations_tab.dart';

class FriendsBody extends ProductPageBody {
  final GlobalKey<_FriendListBodyContentState> _key =
  GlobalKey<_FriendListBodyContentState>();

  FriendsBody({super.key})
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

class _FriendListBodyContentState extends State<FriendListBodyContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              labelColor: Color.lerp(Colors.black, Colors.indigo, 0.8),
              unselectedLabelColor: Colors.black54,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                _FriendTab(
                  icon: CupertinoIcons.person_2,
                  label: "Freunde",
                ),
                _FriendTab(
                  icon: CupertinoIcons.person_badge_plus,
                  label: "Entdecken",
                ),
                _FriendTab(
                  icon: CupertinoIcons.bell,
                  label: "Einladungen",
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              FriendListTab(
                searchController: _searchController,
                scrollController: _scrollController,
                onDiscoverTap: () => _tabController.animateTo(1),
              ),
              FriendDiscoverTab(
                searchController: _searchController,
              ),
              const FriendInvitationsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _FriendTab extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FriendTab({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }
}