import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final bool isFacedown;
  final double scale;

  const CardWidget({
    super.key,
    required this.card,
    this.isFacedown = false,
    this.scale = 1.0, 
  });

  @override
  Widget build(BuildContext context) {
    // Definimos o tamanho base da carta e multiplicamos pela escala
    // Aumentei um pouco a proporção base para acomodar os atributos confortavelmente
    final double cardWidth = 200 * scale;
    final double cardHeight = 280 * scale;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Card(
        elevation: 4, 
        margin: EdgeInsets.zero, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8 * scale),
          // Borda inteligente: Dourada se for Alpha, Preta se for normal
          side: BorderSide(
            color: (card.isAlpha && !isFacedown) ? const Color(0xFFFFD700) : Colors.black87, 
            width: (card.isAlpha && !isFacedown ? 3 : 2) * scale,
          ), 
        ),
        clipBehavior: Clip.antiAlias, 
        child: isFacedown
            ? _buildFacedown() // Costas da carta
            : _buildFaceup(),  // Frente detalhada da carta
      ),
    );
  }

  // --- O VERSO DA CARTA (Igual ao seu original) ---
  Widget _buildFacedown() {
    return Container(
      color: const Color(0xFF082611), 
      child: Center(
        child: Image.asset(
          'assets/images/AniCard Icon.png', 
          fit: BoxFit.contain,
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }

  // --- A FRENTE DA CARTA (Com o Layout Detalhado) ---
  Widget _buildFaceup() {
    const Color bgColor = Color(0xFF2D2D2D);
    const Color goldColor = Color(0xFFFFD700);
    const Color attributeBgColor = Color(0xFF3D3D3D);

    // O FittedBox garante que o design nunca quebre/vaze, independente da 'scale'
    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 250, // Proporção interna fixa para desenhar os textos
        height: 350,
        child: Container(
          color: const Color(0xFF1A1A1A), // Fundo interno da carta
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // 1. CABEÇALHO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black54),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.forest, color: goldColor, size: 16),
                    Expanded(
                      child: Text(
                        card.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: goldColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    card.isAlpha
                        ? const Icon(Icons.star, color: goldColor, size: 18)
                        : const Icon(Icons.circle, color: Colors.grey, size: 14),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // 2. A FOTO LIMPA DO ANIMAL
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black54, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Image.asset(
                      card.imagePath, // Puxa a imagem do seu card_model.dart
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 3. OS ATRIBUTOS DINÂMICOS
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAttributeRow(Icons.psychology, "INSTINTO", card.instintoAssassino, goldColor, attributeBgColor),
                      _buildAttributeRow(Icons.fitness_center, "FORÇA", card.forca, goldColor, attributeBgColor),
                      _buildAttributeRow(Icons.scale, "PESO", card.peso, goldColor, attributeBgColor),
                      _buildAttributeRow(Icons.lightbulb, "INTELIG.", card.inteligencia, goldColor, attributeBgColor),
                      _buildAttributeRow(Icons.bolt, "AGILIDADE", card.agilidade, goldColor, attributeBgColor),
                      const Divider(color: Colors.black54, height: 6),
                      _buildAttributeRow(Icons.stars, "MÉDIA", card.media, Colors.white, Colors.black87, isMedia: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Função auxiliar para desenhar a linha de cada atributo ---
  Widget _buildAttributeRow(IconData icon, String label, int value, Color textColor, Color barBgColor, {bool isMedia = false}) {
    return Row(
      children: [
        Icon(icon, color: isMedia ? textColor : textColor.withOpacity(0.8), size: isMedia ? 16 : 14),
        const SizedBox(width: 4),
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: isMedia ? FontWeight.bold : FontWeight.w500,
              fontSize: isMedia ? 11 : 9,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: barBgColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              // Garante que a barra nunca passe de 1.0 (100%)
              widthFactor: (value / 100).clamp(0.0, 1.0), 
              child: Container(
                decoration: BoxDecoration(
                  color: textColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 20,
          child: Text(
            value.toString(),
            textAlign: TextAlign.end,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: isMedia ? 12 : 10,
            ),
          ),
        ),
      ],
    );
  }
}