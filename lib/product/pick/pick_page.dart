import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/crypto/crypto.dart';
import 'package:quickpick/product/pick/pick_create_page.dart';
import 'package:quickpick/request/request.dart';

class PickPage extends StatefulWidget {
  final String pickId;

  const PickPage({
    super.key,
    required this.pickId,
  });

  @override
  State<PickPage> createState() => _PickPageState();
}

class _PickPageState extends State<PickPage> {
  Uint8List? _imageBytes;
  String? _creatorName;
  List<PickRecipient> _answerRecipients = [];
  String? _sentAt;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _openPick();
  }

  Future<void> _openPick() async {
    final response = await Request.post(
      url: "/pick/open/",
      body: {"pick_id": widget.pickId},
    ).send(context);

    if (response == null) {
      setState(() {
        _error = "No response from server.";
        _isLoading = false;
      });
      return;
    }

    final body = jsonDecode(response.body);
    if (body["success"] != true) {
      setState(() {
        _error = "Failed to open pick.";
        _isLoading = false;
      });
      return;
    }

    try {
      final bundle = EncryptedBundle(
        decryptionKeys: {
          "user": body["decryption_key"] as String,
        },
        nonce: body["nonce"] as String,
        ciphertext: body["ciphertext"] as String,
        tag: body["tag"] as String,
      );

      final crypto = Crypto();
      final plaintext = await crypto.decrypt(bundle, "user");
      final imageBytes = base64.decode(plaintext);

      setState(() {
        _imageBytes = imageBytes;
        _creatorName = body["creator_name"] as String?;
        if (body["creator_id"] != null && body["creator_public_key"] != null) {
          _answerRecipients = [
            PickRecipient(
              recipientId: body["creator_id"],
              publicKey: body["creator_public_key"],
            )
          ];
        }
        _sentAt = _formatSentAt(body["created_at"]);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Decryption failed.";
        _isLoading = false;
      });
    }
  }

  String? _formatSentAt(dynamic raw) {
    if (raw == null) return null;
    try {
      final ms = (raw is int ? raw : int.parse(raw.toString()));
      final dt = (ms > 1e11
              ? DateTime.fromMillisecondsSinceEpoch(ms)
              : DateTime.fromMillisecondsSinceEpoch(ms * 1000))
          .toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildContent(),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: SizedBox(
                  height: 42,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: _creatorName != null
                            ? Text(
                                _creatorName!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(blurRadius: 6, color: Colors.black54)
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(
                        width: 42,
                        child: _sentAt != null
                            ? Text(
                                _sentAt!,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(blurRadius: 6, color: Colors.black54)
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PickCreatePage(
                          recipients: _answerRecipients,
                        ),
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.reply,
                            color: Colors.black, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Antworten',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle,
                color: Colors.white54, size: 40),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: Center(
        child: Image.memory(
          _imageBytes!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black45,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
