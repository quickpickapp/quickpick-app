import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendInvitationsTab extends StatefulWidget {
  const FriendInvitationsTab({super.key});

  @override
  State<FriendInvitationsTab> createState() => _FriendInvitationsTabState();
}

class _FriendInvitationsTabState extends State<FriendInvitationsTab> {
  // TODO: Replace with your actual invitations data source
  final List<Map<String, String>> _invitations = [];

  @override
  Widget build(BuildContext context) {
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
        return ListTile(
          leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
          title: Text(invitation["name"] ?? ""),
          subtitle: Text(invitation["message"] ?? ""),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.check_mark_circled,
                    color: Colors.green),
                onPressed: () {
                  // TODO: accept invitation
                  setState(() => _invitations.removeAt(index));
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle, color: Colors.red),
                onPressed: () {
                  // TODO: decline invitation
                  setState(() => _invitations.removeAt(index));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}