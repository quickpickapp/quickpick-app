import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendListEmptyContent extends StatelessWidget {
  final VoidCallback? onDiscoverTap;

  const FriendListEmptyContent({super.key, this.onDiscoverTap});

  @override
  Widget build(BuildContext context) {
    final color = Colors.indigo;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.person_2,
                size: 38,
                color: color.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Noch keine Freunde",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Entdecke Personen, die du kennst, und füge sie als Freunde hinzu.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onDiscoverTap,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(CupertinoIcons.person_badge_plus, size: 18),
              label: const Text(
                "Personen entdecken",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}