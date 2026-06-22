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

  final List<Map<String, String>> _passosTutorial = [
    {
      'titulo': 'BEM-VINDO AO ANICARD!',
      'texto': 'Prepare-se para duelos táticos eletrizantes utilizando o reino animal! Vamos aprender como funciona o aplicativo de forma rápida.',
      'icone': '🐾'
    },
    {
      'titulo': '1. COMPRE NA LOJA',
      'texto': 'Na aba de Loja (último ícone), você usa suas moedas para comprar novos boosters temáticos de biomas como Floresta Amazônica, Savana ou Tundra!',
      'icone': '🏪'
    },
    {
      'titulo': '2. ABRA SEUS PACOTES',
      'texto': 'Na aba de Packs (quarto ícone), você gerencia e abre seus boosters comprados. Cada pacote garante 3 cartas de animais aleatórias para sua coleção!',
      'icone': '🃏'
    },
    {
      'titulo': '3. MONTE SEU DECK',
      'texto': 'Na aba de Decks (segundo ícone), você gerencia sua equipe. Seu deck deve ter exatamente 9 cartas. Regra de ouro: é permitido NO MÁXIMO 1 carta do tipo ALFA por time!',
      'icone': '⚔️'
    },
    {
      'titulo': '4. ARENA DE BATALHA',
      'texto': 'No menu principal, escolha a dificuldade do Bot e clique em BATTLE! A cada round, um atributo é sorteado. Quem tiver o maior valor no atributo ganha o round!',
      'icone': '🏆'
    },
  ];

  Future<void> _concluirTutorial() async {
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
        height: 420,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF351F14), // Marrom padrão
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(
              '${_paginaAtual + 1} / ${_passosTutorial.length}',
              style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _passosTutorial.length,
                onPageChanged: (index) => setState(() => _paginaAtual = index),
                itemBuilder: (context, index) {
                  final passo = _passosTutorial[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(passo['icone']!, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        passo['titulo']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        passo['texto']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _paginaAtual > 0
                    ? TextButton(
                        onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                        child: const Text('VOLTAR', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                      )
                    : const SizedBox(width: 80),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ultimaPagina ? const Color(0xFF2E5E35) : Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (ultimaPagina) {
                      _concluirTutorial();
                    } else {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                  child: Text(ultimaPagina ? 'ENTENDIDO!' : 'AVANÇAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}