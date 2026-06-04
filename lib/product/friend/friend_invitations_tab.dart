import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/request/request.dart';

class FriendInvitationsTab extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<int>? onInvitationCountChanged;

  const FriendInvitationsTab({
    super.key,
    required this.searchController,
    this.onInvitationCountChanged,
  });

  @override
  State<FriendInvitationsTab> createState() => _FriendInvitationsTabState();
}

class _FriendInvitationsTabState extends State<FriendInvitationsTab> {
  List<Map<String, dynamic>> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(() => setState(() {}));
    _loadInvitations();
  }

  @override
  void dispose() {
    widget.searchController.removeListener(() => setState(() {}));
    super.dispose();
  }

  Future<void> _loadInvitations() async {
    final response = await Request.get(
      url: "/friendship/invitation/list/",
    ).send(context);

    if (response == null) return;

    final body = jsonDecode(response.body);
    if (body["success"] == true) {
      final invitations = List<Map<String, dynamic>>.from(body["invitations"]);
      setState(() {
        _invitations = invitations;
        _isLoading = false;
      });
      widget.onInvitationCountChanged?.call(invitations.length);
    }
  }

  Future<void> _acceptInvitation(String invitationId) async {
    final response = await Request.post(
      url: "/friendship/invitation/accept/",
      body: {"invitation_id": invitationId},
    ).send(context);

    if (response == null) return;

    final body = jsonDecode(response.body);
    if (body["success"] == true) {
      setState(() {
        _invitations.removeWhere(
              (i) => i["invitation_id"].toString() == invitationId,
        );
      });
      widget.onInvitationCountChanged?.call(_invitations.length);
    }
  }

  Future<void> _declineInvitation(String invitationId) async {
    final response = await Request.post(
      url: "/friendship/invitation/decline/",
      body: {"invitation_id": invitationId},
    ).send(context);

    if (response == null) return;

    final body = jsonDecode(response.body);
    if (body["success"] == true) {
      setState(() {
        _invitations.removeWhere(
              (i) => i["invitation_id"].toString() == invitationId,
        );
      });
      widget.onInvitationCountChanged?.call(_invitations.length);
    }
  }

  List<Map<String, dynamic>> get _filteredInvitations {
    final query = widget.searchController.text.toLowerCase();
    if (query.isEmpty) return _invitations;
    return _invitations
        .where((i) =>
        (i["inviter_name"] as String? ?? "").toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isLoading && _invitations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: CupertinoSearchTextField(
              controller: widget.searchController,
              placeholder: Locales.string(context, "product.friend.search"),
              onChanged: (_) => setState(() {}),
            ),
          ),
        if (_isLoading)
          const Expanded(
            child: Center(child: CupertinoActivityIndicator()),
          )
        else if (_filteredInvitations.isEmpty)
          Expanded(
            child: Center(
              child: LocaleText(
                "product.friend.invitations.empty",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _filteredInvitations.length,
              itemBuilder: (context, index) {
                final invitation = _filteredInvitations[index];
                final invitationId = invitation["invitation_id"].toString();

                return ListTile(
                  leading:
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  title: Text(invitation["inviter_name"] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.check_mark_circled,
                            color: Colors.green),
                        onPressed: () => _acceptInvitation(invitationId),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle,
                            color: Colors.red),
                        onPressed: () => _declineInvitation(invitationId),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}