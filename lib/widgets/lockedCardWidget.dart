import 'package:flutter/material.dart';

class LockedCardWidget extends StatelessWidget {
  final Widget cardWidget; // Recebe o seu CardWidget original
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
          // 1. Aplica o filtro de silhueta escura por cima de toda a estrutura da carta
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.85), // Intensidade da silhueta
              BlendMode.srcATop, // Pinta por cima mantendo o formato e transparências da carta
            ),
            child: cardWidget,
          ),
          
          // 2. O ícone de cadeado flutuando no centro da silhueta
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: const Icon(
              Icons.lock,
              color: Colors.amber, // Destaca o cadeado com o dourado do jogo
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}