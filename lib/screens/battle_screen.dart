import 'package:anicard/utils/cosmetic_helpers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  int? _selectedCardIndex; 

  final String? _currentUid = FirebaseAuth.instance.currentUser?.uid;
  final BattleService _battleService = BattleService(); 

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

  // --- Controle de Cosméticos ---
  String _arenaEquipadaId = 'arena_1';
  String _bordaCartaEquipadaId = 'borda_1';
  String _iconeVidaEquipadoId = 'vida_1';

  final List<String> _atributosPossiveis = [
    'instintoAssassino',
    'forca',
    'peso',
    'inteligencia',
    'agilidade',
    'media',
  ];
  String _atributoSorteado = 'forca';

  @override
  void initState() {
    super.initState();
    _inicializarPartida();
  }

  Future<void> _inicializarPartida() async {
    if (_currentUid == null) return;

    try {
      List<CardModel> cartasJogador = await _battleService.buscarCartasEquipadas(_currentUid!);
      List<CardModel> cartasOponente = await _battleService.buscarCartasEquipadas("d9e8ZKsmAYM5EqNPgWMFTxMeEBY2");

      Map<String, String> cosmeticosJogador = await _battleService.buscarCosmeticosEquipados(_currentUid!);

      setState(() {
        _arenaEquipadaId = cosmeticosJogador['arena'] ?? 'arena_1';
        _bordaCartaEquipadaId = cosmeticosJogador['bordaCarta'] ?? 'borda_1';
        _iconeVidaEquipadoId = cosmeticosJogador['iconeVida'] ?? 'vida_1';

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
        return; 
      }

      _atributoSorteado = (_atributosPossiveis.toList()..shuffle()).first;
    });
  }

  void _finalizarPartida() {
    String tituloResultado;
    Color corResultado;

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

  void _confirmarFuga() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF351F14),
          title: const Text('Abandonar Batalha', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Se você sair agora, isso contará como uma DERROTA. Tem certeza que deseja fugir?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Desistir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _selecionarCarta(int index) {
    setState(() {
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

    int cardIndex = _selectedCardIndex!; 

    setState(() {
      _selectedCardIndex = null; 
      _playerCurrentCard = _playerHand.removeAt(cardIndex);

      if (_opponentHand.isNotEmpty) {
        _opponentCurrentCard = _opponentHand.removeAt(0);
      }
    });
    _resolverRodada();
  }

  // --- Método Auxiliar para desenhar a carta (Resolve a sobreposição) ---
  Widget _buildHandCard(int index, bool showOnlySelected) {
    bool isSelected = _selectedCardIndex == index;
    // Lógica da sobreposição: Cria "fantasmas" invisíveis para manter o layout perfeito
    bool isVisible = showOnlySelected ? isSelected : !isSelected;

    return Align(
      widthFactor: 0.7,
      child: Visibility(
        visible: isVisible,
        maintainSize: true, // Mantém o espaço exato da carta
        maintainAnimation: true,
        maintainState: true,
        child: GestureDetector(
          onTap: () => _selecionarCarta(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            transform: Matrix4.identity()..translate(0.0, isSelected ? -50.0 : 0.0),
            child: CardWidget(
              card: _playerHand[index],
              scale: isSelected ? 0.9 : 0.7,
              isFacedown: false,
              bordaEquipadaId : _bordaCartaEquipadaId,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCarregandoPartida) {
      return Scaffold(
        backgroundColor: _tableColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(CosmeticHelpers.obterCaminhoArena(_arenaEquipadaId)),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 1. ATRIBUTO CENTRAL (Movido para o fundo do Stack para ser coberto pelas cartas)
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: BattleHelpers.obterCorAtributo(_atributoSorteado),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 3),
                  ),
                  child: Icon(
                    BattleHelpers.obterIconeAtributo(_atributoSorteado),
                    size: 40,
                    color: Colors.black54,
                  ),
                ),
              ),

              // 2. COLUNA PRINCIPAL (Mesa e Cartas)
              Column(
                children: [
                  // OPONENTE
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 25, right: 16,
                          child: LifeHearts(activeLives: _opponentLives, iconeId: 'vida_1'),
                        ),
                        if (_opponentDiscard.isNotEmpty)
                          Positioned(
                            top: 175, left: 16,
                            child: CardWidget(card: _opponentDiscard.last, scale: 0.4, isFacedown: false, bordaEquipadaId : _bordaCartaEquipadaId,),
                          ),
                        if (_opponentDeck.isNotEmpty)
                          Positioned(
                            top: 175, right: 16,
                            child: CardWidget(card: _opponentDeck.first, scale: 0.4, isFacedown: true, bordaEquipadaId : _bordaCartaEquipadaId,),
                          ),
                        Positioned(
                          top: 0, left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_opponentHand.length, (index) {
                              return Align(
                                widthFactor: 0.7,
                                child: CardWidget(card: _opponentHand[index], scale: 0.5, isFacedown: true, bordaEquipadaId : _bordaCartaEquipadaId,),
                              );
                            }),
                          ),
                        ),
                        if (_opponentCurrentCard != null)
                          Align(
                            alignment: const Alignment(0, 0.4),
                            child: CardWidget(card: _opponentCurrentCard!, scale: 0.7, isFacedown: false, bordaEquipadaId : _bordaCartaEquipadaId,),
                          ),
                      ],
                    ),
                  ),


                  // JOGADOR
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          top: 25, left: 16,
                          child: LifeHearts(activeLives: _playerLives, iconeId: _iconeVidaEquipadoId),
                        ),
                        if (_playerCurrentCard != null)
                          Align(
                            alignment: const Alignment(0, -0.4),
                            child: CardWidget(card: _playerCurrentCard!, scale: 0.7, isFacedown: false, bordaEquipadaId : _bordaCartaEquipadaId,),
                          ),
                        if (_playerDiscard.isNotEmpty)
                          Positioned(
                            bottom: 175, left: 16,
                            child: CardWidget(card: _playerDiscard.last, scale: 0.4, isFacedown: false, bordaEquipadaId : _bordaCartaEquipadaId,),
                          ),
                        if (_playerDeck.isNotEmpty)
                          Positioned(
                            bottom: 175, right: 16,
                            child: CardWidget(card: _playerDeck.first, scale: 0.4, isFacedown: true, bordaEquipadaId : _bordaCartaEquipadaId,),
                          ),
                        
                        // MÃO DO JOGADOR (Em Duas Camadas)
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Camada Base: Desenha as cartas não selecionadas
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_playerHand.length, (index) => _buildHandCard(index, false)),
                              ),
                              // Camada Topo: Desenha APENAS a carta selecionada
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_playerHand.length, (index) => _buildHandCard(index, true)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 3. BOTÕES DE AÇÃO (Retirados da Coluna, agora livres no Stack)
              if (_selectedCardIndex != null)
                Positioned(
                  bottom: 0, // Subi um pouco para afastar da carta grande
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: 'btn_cancelar',
                        backgroundColor: const Color(0xFF8B0000),
                        onPressed: _cancelarSelecao,
                        label: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton.extended(
                        heroTag: 'btn_jogar',
                        backgroundColor: const Color(0xFF082611),
                        onPressed: _jogarCartaSelecionada,
                        label: const Text('Jogar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        icon: const Icon(Icons.check, color: Colors.white),
                      ),
                    ],
                  ),
                ),

              // 4. ELEMENTOS SOLTOS DA TELA
              if (_resultadoRoundTexto != null)
                RoundResultBanner(
                  texto: _resultadoRoundTexto!,
                  cor: _resultadoRoundCor,
                ),
              
              Positioned(
                top: 16, left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white70, size: 28),
                    onPressed: _confirmarFuga,
                    tooltip: 'Abandonar Batalha',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}