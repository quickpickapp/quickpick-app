import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendDiscoverTab extends StatefulWidget {
  final TextEditingController searchController;

  const FriendDiscoverTab({super.key, required this.searchController});

  @override
  State<FriendDiscoverTab> createState() => _FriendDiscoverTabState();
}

class _FriendDiscoverTabState extends State<FriendDiscoverTab> {
  // TODO: Hook up to your actual search / user-discovery service
  final List<Map<String, String>> _results = [];
  bool _isSearching = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    // TODO: Replace with real API call
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: CupertinoSearchTextField(
            controller: widget.searchController,
            onSubmitted: _search,
            placeholder: "Benutzernamen suchen …",
          ),
        ),
        if (_isSearching) const CupertinoActivityIndicator(),
        Expanded(
          child: _results.isEmpty
              ? const Center(
            child: Text(
              "Suche nach Benutzernamen,\num neue Freunde zu finden.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final user = _results[index];
              return ListTile(
                leading: const CircleAvatar(
                    child: Icon(CupertinoIcons.person)),
                title: Text(user["name"] ?? ""),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // TODO: send friend request
                  },
                  child: const Icon(CupertinoIcons.person_badge_plus),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}