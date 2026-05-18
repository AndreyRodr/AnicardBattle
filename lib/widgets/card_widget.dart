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
    this.scale = 1.0, // Tamanho padrão é 1.0 (100%)
  });

  @override
  Widget build(BuildContext context) {
    // Definimos o tamanho base da carta e multiplicamos pela escala
    return SizedBox(
      width: 100 * scale,
      height: 140 * scale,
      child: Card(
        elevation: 4, // Dá a sombra natural da carta
        margin: EdgeInsets.zero, // Remove a margem padrão do Card para facilitar o alinhamento
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8 * scale),
          side: BorderSide(color: Colors.black87, width: 2 * scale), // Borda preta
        ),
        clipBehavior: Clip.antiAlias, // Corta a imagem perfeitamente nas bordas arredondadas
        child: isFacedown
            ? Container(
                color: const Color(0xFF082611), // Cor do verso (Verde escuro da sua paleta)
                child: Center(
                  child: Image.asset(
                    'assets/images/AniCard Icon.png', // A logo do jogo estampada nas costas
                    fit: BoxFit.contain,
                    width: 60 * scale,
                  ),
                ),
              )
            : Stack(
                fit: StackFit.expand, // Faz a imagem preencher todo o Card
                children: [
                  Image.asset(
                    card.image, // Puxa a imagem estática do seu modelo
                    fit: BoxFit.cover,
                  ),
                ],
              ),
      ),
    );
  }
}