import 'package:flutter/material.dart';

class CardGridWidget extends StatelessWidget {
  // Recebe a lista de cartas do seu Controller
  // Se você tiver um modelo específico (ex: List<CartaModel>), pode alterar aqui!
  final List<dynamic> cards; 

  const CardGridWidget({
    super.key, 
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    // Se a lista de cartas estiver vazia, mostra um aviso para não ficar um buraco preto
    if (cards.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Nenhuma carta encontrada.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // O Grid das Cartas
    return GridView.builder(
      // 👇 AS DUAS LINHAS QUE CORRIGEM O TRAVAMENTO INFINITO 👇
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(), 
      // 👆 =================================================== 👆
      
      padding: const EdgeInsets.all(12.0),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Mostra 3 cartas por linha
        childAspectRatio: 0.7, // Proporção da carta (0.7 faz ela ser mais alta que larga)
        crossAxisSpacing: 10, // Espaço horizontal entre as cartas
        mainAxisSpacing: 10,  // Espaço vertical entre as cartas
      ),
      itemBuilder: (context, index) {
        final card = cards[index];

        // Aqui é o visual de cada carta individual
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2E4032), // Um fundo verde escuro/cinza para a carta
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
                    card.image,
                    fit:BoxFit.cover,
                  ),
              ),
            ),
            ],
          ),
        );
      },
    );
  }
}