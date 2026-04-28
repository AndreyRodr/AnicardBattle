import 'package:flutter/material.dart';

class InteractiveToggleButton extends StatelessWidget {
  final bool isOn;
  final VoidCallback onTap;

  const InteractiveToggleButton({
    super.key,
    required this.isOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isOn ? const Color(0xFF1CD134) : const Color(0xFFC72424);
    final String text = isOn ? 'Ligado' : 'Desligado';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}