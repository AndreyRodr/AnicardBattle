import 'package:flutter/material.dart';

class LockedCardWidget extends StatelessWidget {
  final Widget cardWidget;
  final double scale;

  const LockedCardWidget({
    super.key,
    required this.cardWidget,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.85),
              BlendMode.srcATop,
            ),
            child: cardWidget,
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: const Icon(
              Icons.lock,
              color: Colors.amber,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}