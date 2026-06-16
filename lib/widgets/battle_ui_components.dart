import 'package:flutter/material.dart';
import '../utils/cosmetic_helpers.dart';

// O Banner de Vitória/Derrota
class RoundResultBanner extends StatelessWidget {
  final String texto;
  final Color cor;

  const RoundResultBanner({super.key, required this.texto, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor, width: 2),
          boxShadow: [
            BoxShadow(
              color: cor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ]
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: cor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// Os Corações de Vida
class LifeHearts extends StatelessWidget {
  final int activeLives;
  final String iconeId;

  const LifeHearts({super.key, required this.activeLives, this.iconeId = 'vida_1',});

  @override
  Widget build(BuildContext context) {

    final estilo = CosmeticHelpers.obterEstiloVida(iconeId);
    final IconData iconeVisual = estilo['icone'];
    final Color corAtiva = estilo['corAtiva'];

    return Row(
      children: List.generate(5, (index) {
        return Icon(
          iconeVisual,
          color: index < activeLives ? corAtiva : Colors.white24,
          size: 24,
        );
      }),
    );
  }
}

// Modal de Fim de Jogo
class GameOverDialog extends StatelessWidget {
  final String titulo;
  final int playerLives;
  final int opponentLives;
  final Color corDestaque;

  const GameOverDialog({
    super.key,
    required this.titulo,
    required this.playerLives,
    required this.opponentLives,
    required this.corDestaque,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF351F14), // Fundo marrom escuro
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: corDestaque, width: 3),
      ),
      title: Text(
        titulo,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: corDestaque,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Placar Final',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('Você', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(playerLives.toString(), style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const Text('X', style: TextStyle(color: Colors.white54, fontSize: 20)),
              Column(
                children: [
                  const Text('Oponente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(opponentLives.toString(), style: const TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: corDestaque,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          onPressed: () {
            // Esse comando fecha todas as telas da pilha até chegar na primeira tela do app (a Home)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('Voltar para a Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

}

