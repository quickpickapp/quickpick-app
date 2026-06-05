import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/crypto/crypto.dart';
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Decryption failed.";
        _isLoading = false;
      });
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  _GlassIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  if (_creatorName != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      _creatorName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                      ),
                    ),
                  ],
                ],
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