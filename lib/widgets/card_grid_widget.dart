import 'package:flutter/material.dart';
import '../models/card_model.dart'; // Garante que o grid conheça a estrutura da carta
import 'card_widget.dart'; // Importa o nosso novo molde visual

class CardGridWidget extends StatelessWidget {
  final List<dynamic> cards;
  final int? fixedSlots; // Permite forçar o grid a ter um tamanho fixo (ex: 9)
  final Function(dynamic card)? onCardTap;
  final Function(dynamic card)? onCardLongPress; // 👈 1. Adicionada a propriedade
  final String bordaEquipadaId;

  const CardGridWidget({
    super.key, 
    required this.cards,
    this.fixedSlots, 
    this.onCardTap,
    this.onCardLongPress, 
    this.bordaEquipadaId = 'borda_1',
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
    // Fazemos o cast aqui para facilitar o acesso às propriedades
    final cardModel = card as CardModel; 

    return GestureDetector(
      onTap: () {
        if (onCardTap != null){
          onCardTap!(card);
        }
      },
      // 👇 3. Chama a função de clique longo!
      onLongPress: () {
        if (onCardLongPress != null) {
          onCardLongPress!(card);
        }
      },
      // 👇 4. O Widget Hero para a animação. 
      // Dica: Use cardModel.name ou cardModel.id (se tiver) para a tag ser única
      child: Hero(
        tag: 'carta_animacao_${cardModel.name}', 
        child: CardWidget(
          card: cardModel,
          isFacedown: false,
          bordaEquipadaId: bordaEquipadaId,
        ),
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