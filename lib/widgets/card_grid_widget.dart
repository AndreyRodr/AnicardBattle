import 'package:flutter/material.dart';

class CardGridWidget extends StatelessWidget {
  final List<dynamic> cards;
  final int? fixedSlots; // NOVO: Permite forçar o grid a ter um tamanho fixo (ex: 9)
  final Function(dynamic card)? onCardTap; 

  const CardGridWidget({
    super.key, 
    required this.cards,
    this.fixedSlots, // Adicionado no construtor
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
      itemCount: count, // Usa a nossa nova variável count
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
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E4032), 
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                card.image, // Puxa do seu modelo
                fit: BoxFit.cover, 
              ),
            ),
          ),
        ],
      ),
    ));
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