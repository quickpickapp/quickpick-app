import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/product/base/page_body.dart';
import 'package:quickpick/product/friend/friend_discover_tab.dart';
import 'package:quickpick/product/friend/friend_invitations_tab.dart';
import 'package:quickpick/product/friend/friend_list_tab.dart';
import 'package:quickpick/request/request.dart';

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

  @override
  Future<int> notifications(BuildContext context) async {
    final invitationsResponse = await Request.get(
      url: "/friendship/invitation/list/",
    ).send(context);
    if (invitationsResponse != null) {
      final body = jsonDecode(invitationsResponse.body);
      if (body["success"] == true) {
        final invitations =
            List<Map<String, dynamic>>.from(body["invitations"] ?? []);
        if (invitations.isNotEmpty) {
          return invitations.length;
        }
      }
    }
    return 0;
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

  bool _hasSuggestions = false;
  int _invitationCount = 0;

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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              labelColor: Color.lerp(colorScheme.onSurface, colorScheme.primary, 0.8),
              unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 5),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                const _FriendTab(
                  icon: CupertinoIcons.person_2,
                  label: "product.friend.tab.friends",
                ),
                _FriendTab(
                  icon: CupertinoIcons.person_badge_plus,
                  label: "product.friend.tab.discover",
                  showDot: _hasSuggestions,
                ),
                _FriendTab(
                  icon: CupertinoIcons.bell,
                  label: "product.friend.tab.invitations",
                  badgeCount: _invitationCount,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _EagerTabBarView(
            controller: _tabController,
            children: [
              FriendListTab(
                searchController: _searchController,
                scrollController: _scrollController,
                onDiscoverTap: () => _tabController.animateTo(1),
              ),
              FriendDiscoverTab(
                searchController: _searchController,
                onHasSuggestions: (has) {
                  if (_hasSuggestions != has) {
                    setState(() => _hasSuggestions = has);
                  }
                },
              ),
              FriendInvitationsTab(
                searchController: _searchController,
                onInvitationCountChanged: (count) {
                  if (_invitationCount != count) {
                    setState(() => _invitationCount = count);
                  }
                },
              ),
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
  final bool showDot;
  final int badgeCount;

  const _FriendTab({
    required this.icon,
    required this.label,
    this.showDot = false,
    this.badgeCount = 0,
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
          LocaleText(label),
          if (showDot) ...[
            const SizedBox(width: 4),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ] else if (badgeCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EagerTabBarView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;

  const _EagerTabBarView({
    required this.controller,
    required this.children,
  });

  @override
  State<_EagerTabBarView> createState() => _EagerTabBarViewState();
}

class _EagerTabBarViewState extends State<_EagerTabBarView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.controller.index,
      children: widget.children,
    );
  }
}
