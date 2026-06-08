import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/crypto/crypto.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/request/request.dart';

class FriendSelectSheet extends StatefulWidget {
  const FriendSelectSheet();

  @override
  State<FriendSelectSheet> createState() => _FriendSelectSheetState();
}

class _FriendSelectSheetState extends State<FriendSelectSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _friends = [];
  final Set<String> _selected = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final response = await Request.get(url: '/friendship/list/').send(context);
    if (response == null) return;
    final body = jsonDecode(response.body);
    if (body['success'] == true) {
      setState(() {
        _friends = List<Map<String, dynamic>>.from(body['friendships']);
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _friends;
    return _friends
        .where((f) => (f['name'] as String).toLowerCase().contains(q))
        .toList();
  }

  void _toggle(String id) {
    setState(() {
      _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    });
  }

  void _confirm() {
    final recipients = _friends
        .where((f) => _selected.contains(f['id'].toString()))
        .map((f) => PickRecipient(
              recipientId: f['id'].toString(),
              publicKey: f['public_key'] as String,
            ))
        .toList();
    Navigator.pop(context, recipients);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    var theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Locales.string(context, 'product.friend.select'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_selected.isNotEmpty)
                  Text(
                    '${_selected.length}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: Locales.string(context, 'product.friend.search'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Flexible(child: _buildList()),
          _ConfirmButton(
            count: _selected.length,
            onTap: _selected.isEmpty ? null : _confirm,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: CupertinoActivityIndicator(),
      );
    }

    final list = _filtered;

    if (_friends.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: LocaleText(
          'product.friend.list.empty.title',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: LocaleText(
          'product.friend.list.no.results',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var theme = Theme.of(context);
        final friend = list[index];
        final id = friend['id'].toString();
        final isSelected = _selected.contains(id);

        return ListTile(
          onTap: () => _toggle(id),
          leading: CircleAvatar(
            backgroundColor:
                isSelected ? theme.colorScheme.primary : Colors.white12,
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : const Icon(CupertinoIcons.person,
                    color: Colors.white54, size: 18),
          ),
          title: Text(
            friend['name'] ?? '',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          trailing: isSelected
              ? Icon(CupertinoIcons.checkmark_circle_fill,
                  color: theme.colorScheme.primary, size: 22)
              : const Icon(CupertinoIcons.circle,
                  color: Colors.white24, size: 22),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _ConfirmButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color:
              active ? Theme.of(context).colorScheme.primary : Colors.white12,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              active
                  ? Locales.string(context, 'product.pick.send')
                  : Locales.string(context, 'product.friend.select'),
              style: TextStyle(
                color: active ? Colors.white : Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
