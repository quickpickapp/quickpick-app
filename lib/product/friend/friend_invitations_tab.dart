import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/request/request.dart';

class FriendInvitationsTab extends StatefulWidget {
  const FriendInvitationsTab({super.key});

  @override
  State<FriendInvitationsTab> createState() => _FriendInvitationsTabState();
}

class _FriendInvitationsTabState extends State<FriendInvitationsTab> {
  List<Map<String, dynamic>> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    final response = await Request.get(
      url: "/friendship/invitation/list/",
    ).send(context);

    if (response == null) return;

    final body = jsonDecode(response.body);
    if (body["success"] == true) {
      setState(() {
        _invitations = List<Map<String, dynamic>>.from(body["invitations"]);
        _isLoading = false;
      });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_invitations.isEmpty) {
      return const Center(
        child: Text(
          "Keine offenen Einladungen.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _invitations.length,
      itemBuilder: (context, index) {
        final invitation = _invitations[index];
        final invitationId = invitation["invitation_id"].toString();

        return ListTile(
          leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
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
    );
  }
}