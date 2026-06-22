import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;

  // Páginas do tutorial do jogo
  final List<Map<String, String>> _passosTutorial = [
    {
      'titulo': 'BEM-VINDO AO ANICARD!',
      'texto': 'Prepare-se para duelos táticos eletrizantes utilizando o reino animal! Vamos aprender as regras básicas para você se tornar um mestre estrategista.',
      'icone': '🐾'
    },
    {
      'titulo': 'MONTE SEU DECK',
      'texto': 'Seu deck deve conter exatamente 9 cartas! Lembre-se de uma regra de ouro: você só pode ter NO MÁXIMO 1 carta do tipo ALFA equipada por vez para manter o equilíbrio.',
      'icone': '🃏'
    },
    {
      'titulo': 'SISTEMA DE DUELO',
      'texto': 'A cada rodada, um atributo (Força, Agilidade, Peso...) será sorteado aleatoriamente no centro da mesa. Quem jogar a carta com o maior valor naquele atributo ganha a rodada!',
      'icone': '⚔️'
    },
    {
      'titulo': 'VIDAS E RECOMPENSAS',
      'texto': 'Cada jogador começa com 5 vidas. Quem perder todas as vidas perde o jogo! Vença partidas contra os Bots para subir no Ranking e faturar Moedas para abrir novos pacotes!',
      'icone': '🏆'
    },
  ];

  Future<void> _marcarTutorialComoVisto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'tutorialVisto': true,
        });
      } catch (e) {
        debugPrint("Erro ao salvar progresso do tutorial: $e");
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool ultimaPagina = _paginaAtual == _passosTutorial.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        height: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF351F14), // Marrom padrão
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            // Indicador de Progresso (ex: 1/4)
            Text(
              '${_paginaAtual + 1} / ${_passosTutorial.length}',
              style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Carrossel de conteúdo
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _passosTutorial.length,
                onPageChanged: (index) {
                  setState(() => _paginaAtual = index);
                },
                itemBuilder: (context, index) {
                  final passo = _passosTutorial[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        passo['icone']!,
                        style: const TextStyle(fontSize: 50),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        passo['titulo']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          passo['texto']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),

            // Navegação de botões
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão Voltar (Oculto na primeira página)
                _paginaAtual > 0
                    ? TextButton(
                        onPressed: () {
                          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        child: const Text('VOLTAR', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                      )
                    : const SizedBox(width: 80),

                // Botão Avançar / Concluir
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ultimaPagina ? const Color(0xFF2E5E35) : Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    if (ultimaPagina) {
                      _marcarTutorialComoVisto();
                    } else {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                  child: Text(
                    ultimaPagina ? 'JOGAR!' : 'AVANÇAR',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}