import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/crypto/crypto.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
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

  String? _selectedReaction;
  bool _isReacting = false;
  static const _kReactions = ['👍', '👎', '😂', '😯', '❤️', '🔥'];

  @override
  void initState() {
    super.initState();
    _openPick();
  }

  Future<void> _openPick() async {
    final response = await Request.post(
      url: "/pick/open/",
      body: {"pick_id": widget.pickId},
    ).send();

    if (response == null) {
      return;
    }

    final body = jsonDecode(response.body);
    if (body["success"] != true) {
      setState(() {
        _error = Locales.string(context, "product.pick.open.failed");
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
        _error = Locales.string(context, "product.pick.decryption.failed");
        _isLoading = false;
      });
    }
  }

  Future<void> _sendReaction(String reaction) async {
    if (_isReacting) return;

    setState(() {
      _selectedReaction = reaction;
      _isReacting = true;
    });

    final response = await Request.post(
      url: "/pick/react/",
      body: {
        "pick_id": widget.pickId,
        "reaction": reaction,
      },
    ).send();

    if (!mounted) return;

    final ok = response != null && jsonDecode(response.body)["success"] == true;

    setState(() {
      if (!ok) _selectedReaction = null;
      _isReacting = false;
    });

    Navigator.pop(context);
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isLoading && _error == null)
                      _ReactionBar(
                        reactions: _kReactions,
                        selected: _selectedReaction,
                        disabled: _isReacting,
                        onReact: _sendReaction,
                      ),
                    const SizedBox(height: 14),
                    GestureDetector(
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
                            LocaleText(
                              "product.pick.reply",
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
                  ],
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

class _ReactionBar extends StatelessWidget {
  final List<String> reactions;
  final String? selected;
  final bool disabled;
  final ValueChanged<String> onReact;

  const _ReactionBar({
    required this.reactions,
    required this.selected,
    required this.disabled,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((emoji) {
          final isSelected = selected == emoji;
          return _ReactionButton(
            emoji: emoji,
            isSelected: isSelected,
            disabled: disabled,
            onTap: () => onReact(emoji),
          );
        }).toList(),
      ),
    );
  }
}

class _ReactionButton extends StatefulWidget {
  final String emoji;
  final bool isSelected;
  final bool disabled;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
    required this.isSelected,
    required this.disabled,
    required this.onTap,
  });

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.disabled) return;
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isSelected
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
          child: Center(
            child: Text(
              widget.emoji,
              style: TextStyle(
                fontSize: widget.isSelected ? 24 : 22,
              ),
            ),
          ),
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
