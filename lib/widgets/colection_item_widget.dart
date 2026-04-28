import 'package:flutter/material.dart';

class ColectionItemWidget extends StatelessWidget {
  final String titulo;
  final VoidCallback onTap;
  final bool isPacote;
  final IconData? icon; // Usando ícone como mock, depois você troca por Image.asset

  const ColectionItemWidget({
    super.key,
    required this.titulo,
    required this.onTap,
    this.isPacote = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: isPacote ? 120 : 90, // Retângulo se for pacote, quadrado se for personalizável
            decoration: BoxDecoration(
              color: Colors.brown[400], 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.brown[200]!, width: 2),
            ),
            child: Center(
              child: isPacote 
                  ? const Icon(Icons.photo_album, size: 40, color: Colors.white54) // Mock da capa da coleção
                  : Icon(icon, size: 50, color: Colors.white70), // Mock das arenas/bordas
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}