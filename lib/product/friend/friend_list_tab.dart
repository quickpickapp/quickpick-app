import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/product/friend/friend_list_empty.dart';

class FriendListTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final List<String> friends = [];

    if (friends.isEmpty) {
      return FriendListEmptyContent(
        onDiscoverTap: onDiscoverTap,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: CupertinoSearchTextField(controller: searchController),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
                title: Text(friends[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}