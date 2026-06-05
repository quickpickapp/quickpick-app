import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/product/friend/friend_list_empty.dart';
import 'package:quickpick/request/request.dart';

class FriendListTab extends StatefulWidget {
  final TextEditingController searchController;
  final ScrollController scrollController;
  final VoidCallback? onDiscoverTap;

  const FriendListTab({
    super.key,
    required this.searchController,
    required this.scrollController,
    required this.onDiscoverTap,
  });

  @override
  State<FriendListTab> createState() => _FriendListTabState();
}

class _FriendListTabState extends State<FriendListTab> {
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final response = await Request.get(
      url: "/friendship/list/",
    ).send(context);

    if (response == null) return;

    final body = jsonDecode(response.body);
    if (body["success"] == true) {
      setState(() {
        _friends = List<Map<String, dynamic>>.from(body["friendships"]);
        _isLoading = false;
      });
    }
  }

  void _removeFriend(Map<String, dynamic> friend) {
    final friendId = friend["id"].toString();
    Alert(
      type: AlertType.error,
      description: "product.friend.remove.confirm",
      cancelButton: true,
      confirmButtonText: "product.friend.remove.confirm.button",
      confirmButtonColor: Colors.red,
      callback: () async {
        final response = await Request.post(
          url: "/friendship/delete/",
          body: {"friend_id": friendId},
        ).send(context);

        if (response == null) return;

        final body = jsonDecode(response.body);
        if (body["success"] == true) {
          setState(() {
            _friends.removeWhere((f) => f["id"].toString() == friendId);
          });
        }
      },
    ).show(context);
  }

  List<Map<String, dynamic>> get _filteredFriends {
    final query = widget.searchController.text.toLowerCase();
    if (query.isEmpty) return _friends;
    return _friends
        .where((f) => (f["name"] as String).toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_friends.isEmpty) {
      return FriendListEmptyContent(onDiscoverTap: widget.onDiscoverTap);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: CupertinoSearchTextField(
            controller: widget.searchController,
            placeholder: Locales.string(context, "product.friend.search"),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: _filteredFriends.isEmpty
              ? const Center(
                  child: LocaleText(
                    "product.friend.list.no.results",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: widget.scrollController,
                  itemCount: _filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = _filteredFriends[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        foregroundColor: Colors.white,
                        child: Icon(CupertinoIcons.person),
                      ),
                      title: Text(friend["name"] ?? ""),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _removeFriend(friend),
                        child: const Icon(
                          CupertinoIcons.person_badge_minus,
                          color: Colors.redAccent,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
