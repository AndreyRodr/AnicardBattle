import 'package:flutter/material.dart';
import '../models/card_model.dart'; // Garante que o grid conheça a estrutura da carta
import 'card_widget.dart'; // Importa o nosso novo molde visual

class CardGridWidget extends StatelessWidget {
  final List<dynamic> cards;
  final int? fixedSlots; // Permite forçar o grid a ter um tamanho fixo (ex: 9)
  final Function(dynamic card)? onCardTap; 

  const CardGridWidget({
    super.key, 
    required this.cards,
    this.fixedSlots, 
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    // Define quantos itens o grid vai desenhar.
    // Se fixedSlots tiver um número, usa ele. Senão, usa a quantidade de cartas.
    final int count = fixedSlots ?? cards.length;

    if (count == 0) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Nenhuma carta.',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(), 
      padding: const EdgeInsets.all(12.0),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        childAspectRatio: 0.7, 
        crossAxisSpacing: 10, 
        mainAxisSpacing: 10,  
      ),
      itemBuilder: (context, index) {
        // Verifica se ainda existem cartas para esse índice
        if (index < cards.length) {
          final card = cards[index];
          return _buildRealCard(card); // Desenha a carta verdadeira
        } else {
          return _buildEmptySlot(); // Desenha o espaço vazio
        }
      },
    );
  }

  // --- O VISUAL DA CARTA REAL ---
  Widget _buildRealCard(dynamic card) {
    return GestureDetector(
      onTap: () {
        if (onCardTap != null){
          onCardTap!(card);
        }
      },
      // 👇 Aqui está a grande mágica! O GridView cuida do tamanho 
      // e o CardWidget cuida de desenhar todos os detalhes visuais.
      child: CardWidget(
        card: card as CardModel, // Converte o dynamic para CardModel
      ),
    );
  }

  // --- O VISUAL DO ESPAÇO VAZIO ---
  Widget _buildEmptySlot() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3), // Fundo translúcido escuro
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 2), // Borda cinza clara
      ),
      child: const Center(
        child: Icon(
          Icons.add_circle_outline, // Ícone de +
          color: Colors.white24,
          size: 32,
        ),
      ),
    );
  }
}