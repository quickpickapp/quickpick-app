import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:quickpick/request/request.dart';

class FriendDiscoverTab extends StatefulWidget {
  final TextEditingController searchController;

  const FriendDiscoverTab({super.key, required this.searchController});

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
    _discoverFriends();
  }

  Future<void> _discoverFriends() async {
    setState(() => _isLoading = true);

    final List<String> contacts = await _loadPhoneContacts();

    if (contacts.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasFetched = true;
      });
      return;
    }

    final response = await Request.post(
      url: "/friendship/discover/",
      body: {"contacts": contacts},
    ).send(context);

    if (response == null) {
      setState(() {
        _isLoading = false;
        _hasFetched = true;
      });
      return;
    }

    final responseBody = jsonDecode(response.body);

    if (responseBody["success"] == true) {
      final List<dynamic> raw = responseBody["suggestions"] ?? [];
      setState(() {
        _suggestions = raw.cast<Map<String, dynamic>>();
      });
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
    ).send(context);

    if (response == null) return;

    final responseBody = jsonDecode(response.body);
    if (responseBody["success"] == true) {
      setState(() {
        _suggestions.removeWhere((s) => s["id"].toString() == userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: CupertinoSearchTextField(
            controller: widget.searchController,
            placeholder: "Aus Kontakten vorgeschlagen …",
            enabled:
                false, // Discovery ist kontaktbasiert, kein manuelles Suchen
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: CupertinoActivityIndicator(),
          )
        else
          Expanded(
            child: !_hasFetched || _suggestions.isEmpty
                ? const Center(
                    child: Text(
                      "Keine neuen Vorschläge aus\ndeinen Kontakten gefunden.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final user = _suggestions[index];
                      return ListTile(
                        leading: const CircleAvatar(
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
