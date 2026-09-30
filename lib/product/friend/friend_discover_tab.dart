import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/request/request.dart';

class FriendDiscoverTab extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<bool>? onHasSuggestions;

  const FriendDiscoverTab({
    super.key,
    required this.searchController,
    this.onHasSuggestions,
  });

  @override
  State<FriendDiscoverTab> createState() => _FriendDiscoverTabState();
}

class _FriendDiscoverTabState extends State<FriendDiscoverTab> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(() => setState(() {}));
    _discoverFriends();
  }

  @override
  void dispose() {
    widget.searchController.removeListener(() => setState(() {}));
    super.dispose();
  }

  Future<void> _discoverFriends() async {
    setState(() => _isLoading = true);

    final List<String> contacts = await _loadPhoneContacts();

    if (contacts.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasFetched = true;
      });
      widget.onHasSuggestions?.call(false);
      return;
    }

    final response = await Request.post(
      url: "/friendship/discover/",
      body: {"contacts": contacts},
    ).send();

    if (response == null) {
      setState(() {
        _isLoading = false;
        _hasFetched = true;
      });
      widget.onHasSuggestions?.call(false);
      return;
    }

    final responseBody = jsonDecode(response.body);

    if (responseBody["success"] == true) {
      final List<dynamic> raw = responseBody["suggestions"] ?? [];
      setState(() {
        _suggestions = raw.cast<Map<String, dynamic>>();
      });
      widget.onHasSuggestions?.call(_suggestions.isNotEmpty);
    }

    setState(() {
      _isLoading = false;
      _hasFetched = true;
    });
  }

  Future<List<String>> _loadPhoneContacts() async {
    if (await FlutterContacts.permissions.request(PermissionType.read) !=
        PermissionStatus.granted) {
      return [];
    }
    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );
    return contacts
        .expand((c) =>
            c.phones.map((p) => p.number.replaceAll(RegExp(r'[\s\-()]'), '')))
        .toList();
  }

  Future<void> _sendFriendRequest(String userId) async {
    final response = await Request.post(
      url: "/friendship/invitation/create/",
      body: {"target": userId},
    ).send();

    if (response == null) return;

    final responseBody = jsonDecode(response.body);
    if (responseBody["success"] == true) {
      setState(() {
        _suggestions.removeWhere((s) => s["id"].toString() == userId);
      });
      widget.onHasSuggestions?.call(_suggestions.isNotEmpty);
    }
  }

  List<Map<String, dynamic>> get _filteredSuggestions {
    final query = widget.searchController.text.toLowerCase();
    if (query.isEmpty) return _suggestions;
    return _suggestions
        .where(
            (s) => (s["name"] as String? ?? "").toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isLoading && _suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: CupertinoSearchTextField(
              controller: widget.searchController,
              placeholder: Locales.string(context, "product.friend.search"),
            ),
          ),
        if (_isLoading)
          const Expanded(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        else
          Expanded(
            child: !_hasFetched || _filteredSuggestions.isEmpty
                ? Center(
                    child: LocaleText(
                      "product.friend.discover.empty",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredSuggestions.length,
                    itemBuilder: (context, index) {
                      final user = _filteredSuggestions[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          foregroundColor: Colors.white,
                          child: Icon(CupertinoIcons.person),
                        ),
                        title: Text(user["name"] ?? ""),
                        trailing: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              _sendFriendRequest(user["id"].toString()),
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
