import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickpick/product/pick/pick_create_page.dart';

class PickButton extends StatefulWidget {
  const PickButton({super.key});

  @override
  State<PickButton> createState() => _PickButtonState();
}

class _PickButtonState extends State<PickButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double glowValue = sin(_controller.value * pi);
        return Container(
          height: 70,
          width: 70,
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.6 * min(glowValue + 0.5, 1)),
                blurRadius: 15 * (glowValue + 0.5),
                spreadRadius: 4 * (glowValue + 0.5),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PickCreatePage()),
              );
            },
            backgroundColor:
                Color.lerp(Color(0xFF37479F), Color(0xFF495ED3), glowValue),
            shape: CircleBorder(),
            child: Icon(CupertinoIcons.camera, size: 35),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
