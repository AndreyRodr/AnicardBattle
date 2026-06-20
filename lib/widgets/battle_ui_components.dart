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
  final int moedasGanhas;   // 🌟 Adicionado
  final int trofeusGanhos;

  const GameOverDialog({
    super.key,
    required this.titulo,
    required this.playerLives,
    required this.opponentLives,
    required this.corDestaque,
    required this.moedasGanhas,
    required this.trofeusGanhos,
  });

  @override
  Widget build(BuildContext context) {
    // Detecta se os troféus são positivos ou negativos para colocar o sinal de + ou -
    final String sinalTrofeu = trofeusGanhos >= 0 ? "+" : "";
    final Color corTrofeu = trofeusGanhos >= 0 ? Colors.amber : Colors.redAccent;

    return AlertDialog(
      backgroundColor: const Color(0xFF221108), // Tom marrom escuro de madeira
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        titulo,
        textAlign: TextAlign.center,
        style: TextStyle(color: corDestaque, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Placar de Vidas (ex: 5 x 2)
          Text(
            '$playerLives x $opponentLives',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // 🌟 LINHA DE RECOMPENSAS COMPACTA (Estilo Clash Royale)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bloco de Troféus
              Row(
                children: [
                  Text(
                    '$sinalTrofeu$trofeusGanhos',
                    style: TextStyle(color: corTrofeu, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 22), // Ícone de Troféu
                ],
              ),
              const SizedBox(width: 24), // Espaçamento entre os dois
              
              // Bloco de Moedas (Apenas exibe se for maior que zero)
              if (moedasGanhas > 0)
                Row(
                  children: [
                    Text(
                      '+$moedasGanhas',
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 22), // Ícone de Moeda
                  ],
                ),
            ],
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3620)),
            onPressed: () {
              // Volta para a HomeScreen limpando a pilha de navegação
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Voltar ao Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}