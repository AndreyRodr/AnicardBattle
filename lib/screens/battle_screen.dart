import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

// 👇 Importe seus novos arquivos aqui
import '../models/card_model.dart';
import '../widgets/card_widget.dart';
import '../services/battle_service.dart';
import '../utils/battle_helpers.dart';
import '../widgets/battle_ui_components.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final Color _tableColor = const Color(0xFF6B4E31);
  final Color _dividerColor = Colors.black87;

  // --- Controle de Seleção da Mão ---
  int? _selectedCardIndex; // Guarda qual carta o jogador tocou

  final String? _currentUid = FirebaseAuth.instance.currentUser?.uid;
  final BattleService _battleService = BattleService(); // Instância do novo serviço

  bool _isCarregandoPartida = true;
  int _playerLives = 5;
  int _opponentLives = 5;

  List<CardModel> _playerDeck = [];
  List<CardModel> _playerHand = [];
  List<CardModel> _playerDiscard = [];
  CardModel? _playerCurrentCard;

  List<CardModel> _opponentDeck = [];
  List<CardModel> _opponentHand = [];
  List<CardModel> _opponentDiscard = [];
  CardModel? _opponentCurrentCard;

  String? _resultadoRoundTexto;
  Color _resultadoRoundCor = Colors.transparent;

  final List<String> _atributosPossiveis = ['instintoAssassino', 'forca', 'peso', 'inteligencia', 'agilidade', 'media'];
  String _atributoSorteado = 'forca';

  @override
  void initState() {
    super.initState();
    _inicializarPartida();
  }

  Future<void> _inicializarPartida() async {
    if (_currentUid == null) return;

    try {
      // Uso do serviço abstraído
      List<CardModel> cartasJogador = await _battleService.buscarCartasEquipadas(_currentUid);
      List<CardModel> cartasOponente = await _battleService.buscarCartasEquipadas("d9e8ZKsmAYM5EqNPgWMFTxMeEBY2");

      setState(() {
        _playerDeck = List.from(cartasJogador)..shuffle();
        _opponentDeck = List.from(cartasOponente)..shuffle();

        for (int i = 0; i < 3; i++) {
          if (_playerDeck.isNotEmpty) _playerHand.add(_playerDeck.removeAt(0));
          if (_opponentDeck.isNotEmpty) _opponentHand.add(_opponentDeck.removeAt(0));
        }
        _isCarregandoPartida = false;
      });
    } catch (e) {
      setState(() => _isCarregandoPartida = false);
    }
  }

  Future<void> _resolverRodada() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return; 

    // Uso do helper matemático abstraído
    int valorJogador = BattleHelpers.obterValorAtributo(_playerCurrentCard!, _atributoSorteado);
    int valorOponente = BattleHelpers.obterValorAtributo(_opponentCurrentCard!, _atributoSorteado);

    setState(() {
      if (valorJogador > valorOponente) {
        _opponentLives--;
        _resultadoRoundTexto = "BOAA!";
        _resultadoRoundCor = Colors.greenAccent;
      } else if (valorOponente > valorJogador) {
        _playerLives--;
        _resultadoRoundTexto = "EITA!";
        _resultadoRoundCor = Colors.redAccent;
      } else {
        _resultadoRoundTexto = "EMPATE!";
        _resultadoRoundCor = Colors.grey;
      }
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    setState(() {
      _resultadoRoundTexto = null;

      if (_playerLives <= 0 || _opponentLives <= 0) {
        _finalizarPartida();
        return; 
      }

      _playerDiscard.add(_playerCurrentCard!);
      _playerCurrentCard = null;
      _opponentDiscard.add(_opponentCurrentCard!);
      _opponentCurrentCard = null; 

      if (_playerDeck.isNotEmpty) _playerHand.add(_playerDeck.removeAt(0));
      if (_opponentDeck.isNotEmpty) _opponentHand.add(_opponentDeck.removeAt(0));

      if (_playerHand.isEmpty || _opponentHand.isEmpty) {
        _finalizarPartida();
        return; // Interrompe para não sortear mais nada
      }
      
      _atributoSorteado = (_atributosPossiveis.toList()..shuffle()).first;
    });
  }

  void _finalizarPartida() {
    String tituloResultado;
    Color corResultado;

    // Calcula quem venceu e define as cores
    if (_playerLives > _opponentLives) {
      tituloResultado = "VITÓRIA!";
      corResultado = Colors.greenAccent;
    } else if (_opponentLives > _playerLives) {
      tituloResultado = "DERROTA!";
      corResultado = Colors.redAccent;
    } else {
      tituloResultado = "EMPATE!";
      corResultado = Colors.grey;
    }

    // Exibe o modal na tela de forma que o usuário não consiga fechar clicando fora (barrierDismissible: false)
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return GameOverDialog(
          titulo: tituloResultado,
          playerLives: _playerLives,
          opponentLives: _opponentLives,
          corDestaque: corResultado,
        );
      },
    );
  }

  void _selecionarCarta(int index) {
    setState(() {
      // Se clicar na mesma carta que já está selecionada, ele desmarca. 
      // Se clicar em outra, ele muda a seleção.
      _selectedCardIndex = (_selectedCardIndex == index) ? null : index;
    });
  }

  void _cancelarSelecao() {
    setState(() {
      _selectedCardIndex = null;
    });
  }

  void _jogarCartaSelecionada() {
    if (_selectedCardIndex == null) return;
    
    int cardIndex = _selectedCardIndex!; // Salva o index antes de limpar
    
    setState(() {
      _selectedCardIndex = null; // Limpa a seleção da tela
      
      // Move a carta da mão para o centro da mesa
      _playerCurrentCard = _playerHand.removeAt(cardIndex);
      
      // O Oponente joga a carta dele
      if (_opponentHand.isNotEmpty) {
        _opponentCurrentCard = _opponentHand.removeAt(0);
      }
    });

    // Inicia o ciclo de combate
    _resolverRodada();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCarregandoPartida) {
      return Scaffold(
        backgroundColor: _tableColor,
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: _tableColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // OPONENTE
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(bottom: 8, right: 16, child: LifeHearts(activeLives: _opponentLives)), // Uso do widget abstraído
                      if (_opponentDiscard.isNotEmpty)
                        Positioned(top: 16, left: 16, child: Transform.rotate(angle: math.pi, child: CardWidget(card: _opponentDiscard.last, scale: 0.4, isFacedown: false))),
                      if (_opponentDeck.isNotEmpty)
                        Positioned(top: 16, right: 16, child: Transform.rotate(angle: math.pi, child: CardWidget(card: _opponentDeck.first, scale: 0.4, isFacedown: true))),
                      Positioned(
                        top: -40, left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_opponentHand.length, (index) {
                            return Align(widthFactor: 0.7, child: Transform.rotate(angle: math.pi, child: CardWidget(card: _opponentHand[index], scale: 0.5, isFacedown: true)));
                          }),
                        ),
                      ),
                      if (_opponentCurrentCard != null)
                        Align(alignment: const Alignment(0, 0.4), child: Transform.rotate(angle: math.pi, child: CardWidget(card: _opponentCurrentCard!, scale: 0.7, isFacedown: false))),
                    ],
                  ),
                ),

                Divider(height: 4, thickness: 4, color: _dividerColor),

                // JOGADOR
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(top: 8, left: 16, child: LifeHearts(activeLives: _playerLives)), // Uso do widget abstraído
                      if (_playerCurrentCard != null)
                        Align(alignment: const Alignment(0, -0.4), child: CardWidget(card: _playerCurrentCard!, scale: 0.4, isFacedown: false)),
                      if (_playerDiscard.isNotEmpty)
                        Positioned(bottom: 16, left: 16, child: CardWidget(card: _playerDiscard.last, scale: 0.4, isFacedown: false)),
                      if (_playerDeck.isNotEmpty)
                        Positioned(bottom: 16, right: 16, child: CardWidget(card: _playerDeck.first, scale: 0.4, isFacedown: true)),
                      Positioned(
                        bottom: -40, left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_playerHand.length, (index) {
                            bool isSelected = _selectedCardIndex == index;
                            return Align(
                              widthFactor: 0.7,
                              child: GestureDetector(
                                onTap: () => _selecionarCarta(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutBack,
                                  // Animação de subir
                                  transform: Matrix4.identity()..translate(0.0, isSelected ? -50.0 : 0.0),
                                  child: CardWidget(
                                    card: _playerHand[index],
                                    // Animação de crescer
                                    scale: isSelected ? 1.15 : 0.7, 
                                    isFacedown: false,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedCardIndex != null)
                        Positioned(
                          bottom: 120, // Posiciona logo acima das cartas da mão
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Botão de Cancelar (Vermelho)
                              FloatingActionButton.extended(
                                heroTag: 'btn_cancelar',
                                backgroundColor: const Color(0xFF8B0000), // Vermelho escuro
                                onPressed: _cancelarSelecao,
                                label: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                icon: const Icon(Icons.close, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              // Botão de Confirmar (Verde)
                              FloatingActionButton.extended(
                                heroTag: 'btn_jogar',
                                backgroundColor: const Color(0xFF082611), // Verde escuro da sua paleta
                                onPressed: _jogarCartaSelecionada,
                                label: const Text('Jogar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                icon: const Icon(Icons.check, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
              ],
            ),

            // ATRIBUTO CENTRAL
            Center(
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: BattleHelpers.obterCorAtributo(_atributoSorteado), shape: BoxShape.circle, border: Border.all(color: Colors.black87, width: 3)),
                child: Icon(BattleHelpers.obterIconeAtributo(_atributoSorteado), size: 40, color: Colors.black54), // Uso do helper
              ),
            ),
            
            // BANNER DE RESULTADO
            if (_resultadoRoundTexto != null)
              RoundResultBanner(texto: _resultadoRoundTexto!, cor: _resultadoRoundCor), // Uso do widget abstraído
          ],
        ),
      ),
    );
  }
}