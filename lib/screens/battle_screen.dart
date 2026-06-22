import 'dart:math';
import 'package:anicard/services/quest_service.dart';
import 'package:anicard/utils/cosmetic_helpers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🌟 Adicionado para o Ranking
import '../models/card_model.dart';
import '../widgets/card_widget.dart';
import '../services/battle_service.dart';
import '../utils/battle_helpers.dart';
import '../utils/sound_manager.dart';
import '../utils/dialog_helpers.dart';
import '../widgets/battle_ui_components.dart';

// 🌟 Enum de controle de dificuldades
enum BotDifficulty { iniciante, intermediario, dificil }

class BattleScreen extends StatefulWidget {
  final BotDifficulty dificuldade; // 🌟 Recebe qual bot o jogador escolheu enfrentar

  const BattleScreen({
    super.key, 
    this.dificuldade = BotDifficulty.intermediario, // Padrão caso não passe
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final Color _tableColor = const Color(0xFF6B4E31);

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

  // 🌟 Dicionário para exibir os nomes limpos e elegantes na tela
  final Map<String, String> _nomesAtributos = {
    'instintoAssassino': 'Instinto Assassino',
    'forca': 'Força',
    'peso': 'Peso',
    'inteligencia': 'Inteligência',
    'agilidade': 'Agilidade',
    'media': 'Média Geral',
  };

  @override
  void initState() {
    super.initState();
    _inicializarPartida();
  }

  Future<void> _inicializarPartida() async {
    if (_currentUid == null) return;

    try {
      // Carrega o deck customizado do duelista jogador
      List<CardModel> cartasJogador = await _battleService.buscarCartasEquipadas(_currentUid!);
      
      // 🌟 DECK DO BOT ATUALIZADO:
      // Agora ele invoca o método temático passando a dificuldade vinda da escolha do menu!
      List<CardModel> cartasOponente = await _battleService.gerarDeckTematicoBot(widget.dificuldade.name);

      Map<String, String> cosmeticosJogador = await _battleService.buscarCosmeticosEquipados(_currentUid!);

      setState(() {
        _arenaEquipadaId = cosmeticosJogador['arena'] ?? 'arena_1';
        _bordaCartaEquipadaId = cosmeticosJogador['bordaCarta'] ?? 'borda_1';
        _iconeVidaEquipadoId = cosmeticosJogador['iconeVida'] ?? 'vida_1';

        _playerDeck = List.from(cartasJogador)..shuffle();
        
        // Clona e embaralha o deck temático para as compras de round do Bot
        _opponentDeck = List.from(cartasOponente)..shuffle();

        for (int i = 0; i < 3; i++) {
          if (_playerDeck.isNotEmpty) _playerHand.add(_playerDeck.removeAt(0));
          if (_opponentDeck.isNotEmpty) _opponentHand.add(_opponentDeck.removeAt(0));
        }
        _isCarregandoPartida = false;
      });

      // Mostra o aviso do primeiro atributo sorteado no início da partida
      _mostrarAvisoAtributo(_atributoSorteado);
    } catch (e) {
      setState(() => _isCarregandoPartida = false);
    }
  }

  // 🌟 FUNÇÃO DE TEXTO DO ATRIBUTO: Mostra um banner na tela estilo o RoundResultBanner
  void _mostrarAvisoAtributo(String atributo) {
    setState(() {
      _resultadoRoundTexto = "Atributo: ${_nomesAtributos[atributo]}";
      _resultadoRoundCor = Colors.amberAccent;
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _resultadoRoundTexto != null && _resultadoRoundTexto!.contains("Atributo:")) {
        setState(() {
          _resultadoRoundTexto = null;
        });
      }
    });
  }

  void _jogarCartaSelecionada() {
    if (_selectedCardIndex == null) return;

    int cardIndex = _selectedCardIndex!; 

    setState(() {
      _selectedCardIndex = null; 
      _playerCurrentCard = _playerHand.removeAt(cardIndex);

      if (_opponentHand.isNotEmpty) {
        // 🌟 IMPLEMENTAÇÃO DA INTELIGÊNCIA DOS BOTS:
        _opponentCurrentCard = _executarMenteDoBot();
      }
    });
    _resolverRodada();
  }

  /// 🧠 ENGINE DE DECISÃO INTEGRADA DOS BOTS
  CardModel _executarMenteDoBot() {
    final Random random = Random();
    
    switch (widget.dificuldade) {
      case BotDifficulty.iniciante:
        // 🟢 Joga 100% aleatório sem olhar o atributo da rodada
        int index = random.nextInt(_opponentHand.length);
        return _opponentHand.removeAt(index);

      case BotDifficulty.intermediario:
        // 🟡 Sempre escolhe o maior valor bruto para o atributo ativo
        int melhorIndex = 0;
        int maiorValor = -1;
        for (int i = 0; i < _opponentHand.length; i++) {
          int v = BattleHelpers.obterValorAtributo(_opponentHand[i], _atributoSorteado);
          if (v > maiorValor) {
            maiorValor = v;
            melhorIndex = i;
          }
        }
        return _opponentHand.removeAt(melhorIndex);

      case BotDifficulty.dificil:
        // 🔴 Estrategista: Ordena para conhecer a mais forte e a mais fraca
        List<int> indicesOrdenados = List.generate(_opponentHand.length, (i) => i);
        indicesOrdenados.sort((a, b) => 
          BattleHelpers.obterValorAtributo(_opponentHand[b], _atributoSorteado)
          .compareTo(BattleHelpers.obterValorAtributo(_opponentHand[a], _atributoSorteado))
        );

        int indexMaisForte = indicesOrdenados.first;
        int indexMaisFraca = indicesOrdenados.last;

        int maiorValorDoBot = BattleHelpers.obterValorAtributo(_opponentHand[indexMaisForte], _atributoSorteado);

        // Se o melhor valor do bot for muito baixo (menor que 48), ele assume que perdeu o round.
        // Em vez de queimar carta boa, ele descarta a pior da mão para estocar poder.
        if (maiorValorDoBot < 48 && _opponentHand.length > 1) {
          return _opponentHand.removeAt(indexMaisFraca);
        }
        return _opponentHand.removeAt(indexMaisForte);
    }
  }

  Future<void> _resolverRodada() async {
    print("🔍 ENTROU NA FUNÇÃO _resolverRodada!");
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    print("🔍 PASSOU PELO PRIMEIRO DELAY! Mounted: $mounted");
    int valorJogador = BattleHelpers.obterValorAtributo(_playerCurrentCard!, _atributoSorteado);
    int valorOponente = BattleHelpers.obterValorAtributo(_opponentCurrentCard!, _atributoSorteado);

    print("🃏 Áudio na carta do Jogador: '${_playerCurrentCard!.audioPath}'");
    print("🃏 Áudio na carta do Oponente: '${_opponentCurrentCard!.audioPath}'");

    String? audioParaTocar;
    if (valorJogador > valorOponente) {
      audioParaTocar = _playerCurrentCard!.audioPath;
    } else if (valorOponente > valorJogador) {
      audioParaTocar = _opponentCurrentCard!.audioPath;
    }

    setState(() {
      if (valorJogador > valorOponente) {
        _opponentLives--;
        _resultadoRoundTexto = "Vitória!";
        _resultadoRoundCor = Colors.greenAccent;
      } else if (valorOponente > valorJogador) {
        _playerLives--;
        _resultadoRoundTexto = "Derrota!";
        _resultadoRoundCor = Colors.redAccent;
      } else {
        _resultadoRoundTexto = "Empate!";
        _resultadoRoundCor = Colors.grey;
      }
    });

    print("🔍 Valor do áudio capturado: '$audioParaTocar'");

    if (audioParaTocar != null && audioParaTocar!.isNotEmpty) {
      SoundManager.reproduzirSomVitoria(audioParaTocar!);
    } else {
      print("⚠️ Som não foi chamado porque a string é nula ou vazia!");
    }


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

    // 🌟 Exibe por extenso qual foi o novo atributo sorteado para a próxima rodada!
    _mostrarAvisoAtributo(_atributoSorteado);
  }

  void _finalizarPartida() {
    String tituloResultado;
    Color corResultado;
    bool jogadorVenceu = false;

    if (_playerLives > _opponentLives) {
      tituloResultado = "VITÓRIA!";
      corResultado = Colors.greenAccent;
      jogadorVenceu = true;
    } else if (_opponentLives > _playerLives) {
      tituloResultado = "DERROTA!";
      corResultado = Colors.redAccent;
    } else {
      tituloResultado = "EMPATE!";
      corResultado = Colors.grey;
    }

    // --- Cálculo de Recompensas Visuais para o Dialog ---
    int trofeusMostrados = 0;
    int moedasMostradas = 0;

    

    if (jogadorVenceu) {
      if (widget.dificuldade == BotDifficulty.iniciante) { trofeusMostrados = 10; moedasMostradas = 15; }
      else if (widget.dificuldade == BotDifficulty.intermediario) { trofeusMostrados = 25; moedasMostradas = 35; }
      else if (widget.dificuldade == BotDifficulty.dificil) { trofeusMostrados = 50; moedasMostradas = 70; }
    } else {
      // Se perdeu, exibe a perda de troféus (moedas continua 0)
      if (widget.dificuldade == BotDifficulty.iniciante) trofeusMostrados = -5;
      else if (widget.dificuldade == BotDifficulty.intermediario) trofeusMostrados = -15;
      else if (widget.dificuldade == BotDifficulty.dificil) trofeusMostrados = -25;
    }

    // Dentro do método _finalizarPartida() da BattleScreen:
    if (_currentUid != null) {
      _atualizarTrofeusNoFirestore(
        uid: _currentUid!, 
        dificuldade: widget.dificuldade, 
        venceu: jogadorVenceu
      );

    // 🌟 GATILHO DE MISSÕES DA PARTIDA:
    final questService = QuestService();
    
    // 1. Sempre computa progresso na missão geral de "jogar partidas"
    questService.atualizarProgressoMissao(uid: _currentUid!, acaoId: 'jogar');

    // 2. Se o jogador venceu, computa progresso na missão específica da dificuldade
    if (jogadorVenceu) {
      if (widget.dificuldade == BotDifficulty.iniciante) {
        questService.atualizarProgressoMissao(uid: _currentUid!, acaoId: 'facil');
      } else if (widget.dificuldade == BotDifficulty.intermediario) {
        questService.atualizarProgressoMissao(uid: _currentUid!, acaoId: 'inter');
      } else if (widget.dificuldade == BotDifficulty.dificil) {
        questService.atualizarProgressoMissao(uid: _currentUid!, acaoId: 'dificil');
      }
    }
  }

    // Gravação no banco de dados (Mantido idêntico)
    if (_currentUid != null) {
      _atualizarTrofeusNoFirestore(
        uid: _currentUid!, 
        dificuldade: widget.dificuldade, 
        venceu: jogadorVenceu
      );
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
          // 🌟 PASSANDO OS NOVOS PARÂMETROS PARA O SEU DIALOG:
          moedasGanhas: moedasMostradas,
          trofeusGanhos: trofeusMostrados,
        );
      },
    );
  }

  /// 🏆 SISTEMA DE PONTUAÇÃO VIA TRANSACTION ATÔMICA
  Future<void> _atualizarTrofeusNoFirestore({
    required String uid,
    required BotDifficulty dificuldade,
    required bool venceu,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    int saldoTrofeus = 0;
    int saldoMoedas = 0;

    if (venceu) {
      if (dificuldade == BotDifficulty.iniciante) { saldoTrofeus = 10; saldoMoedas = 15; }
      else if (dificuldade == BotDifficulty.intermediario) { saldoTrofeus = 25; saldoMoedas = 35; }
      else if (dificuldade == BotDifficulty.dificil) { saldoTrofeus = 50; saldoMoedas = 70; }
    } else {
      if (dificuldade == BotDifficulty.iniciante) saldoTrofeus = -5;
      else if (dificuldade == BotDifficulty.intermediario) saldoTrofeus = -15;
      else if (dificuldade == BotDifficulty.dificil) saldoTrofeus = -25;
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        int trofeusAtuais = snapshot.data()?['trofeus'] ?? 0;
        int moedasAtuais = snapshot.data()?['moedas'] ?? 0;

        int novosTrofeus = (trofeusAtuais + saldoTrofeus).clamp(0, 99999);
        int novasMoedas = moedasAtuais + saldoMoedas;

        transaction.update(docRef, {
          'trofeus': novosTrofeus,
          'moedas': novasMoedas,
        });
      });
    } catch (e) {
      debugPrint("Erro ao salvar dados pós-batalha: $e");
    }
  }

  void _confirmarFuga() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF351F14),
          title: const Text('Abandonar Batalha', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Se você sair agora, isso contará como uma DERROTA e você perderá troféus. Deseja fugir?',
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
                // Se fugir, aplica penalidade de derrota na dificuldade atual
                if (_currentUid != null) {
                  _atualizarTrofeusNoFirestore(uid: _currentUid!, dificuldade: widget.dificuldade, venceu: false);
                }
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

  Widget _buildHandCard(int index, bool showOnlySelected) {
    bool isSelected = _selectedCardIndex == index;
    bool isVisible = showOnlySelected ? isSelected : !isSelected;

    return Align(
      widthFactor: 0.7,
      child: Visibility(
        visible: isVisible,
        maintainSize: true, 
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
              // 1. ATRIBUTO CENTRAL
              Center(
                child: GestureDetector(
                  // 🌟 CLIQUE NO ÍCONE: Mostra um balão informativo informando o nome por extenso
                  onTap: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Atributo em disputa: ${_nomesAtributos[_atributoSorteado]}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: BattleHelpers.obterCorAtributo(_atributoSorteado),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
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
              ),

              // 2. COLUNA PRINCIPAL (Mesa e Cartas)
              Column(
                children: [
                  // OPONENTE
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 25,
                          right: 16,
                          child: LifeHearts(activeLives: _opponentLives, iconeId: 'vida_1'),
                        ),
                        if (_opponentDiscard.isNotEmpty)
                          Positioned(
                            top: 175,
                            left: 16,
                            child: CardWidget(
                              card: _opponentDiscard.last,
                              scale: 0.4,
                              isFacedown: false,
                              bordaEquipadaId: _bordaCartaEquipadaId,
                            ),
                          ),
                        if (_opponentDeck.isNotEmpty)
                          Positioned(
                            top: 175,
                            right: 16,
                            child: CardWidget(
                              card: _opponentDeck.first,
                              scale: 0.4,
                              isFacedown: true,
                              bordaEquipadaId: _bordaCartaEquipadaId,
                            ),
                          ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_opponentHand.length, (index) {
                              return Align(
                                widthFactor: 0.7,
                                child: CardWidget(
                                  card: _opponentHand[index],
                                  scale: 0.5,
                                  isFacedown: true,
                                  bordaEquipadaId: _bordaCartaEquipadaId,
                                ),
                              );
                            }),
                          ),
                        ),
                        if (_opponentCurrentCard != null)
                          Align(
                            alignment: const Alignment(0, 0.4),
                            child: CardWidget(
                              card: _opponentCurrentCard!,
                              scale: 0.7,
                              isFacedown: false,
                              bordaEquipadaId: _bordaCartaEquipadaId,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // JOGADOR
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          top: 25,
                          left: 16,
                          child: LifeHearts(activeLives: _playerLives, iconeId: _iconeVidaEquipadoId),
                        ),
                        if (_playerCurrentCard != null)
                          Align(
                            alignment: const Alignment(0, -0.4),
                            child: CardWidget(
                              card: _playerCurrentCard!,
                              scale: 0.7,
                              isFacedown: false,
                              bordaEquipadaId: _bordaCartaEquipadaId,
                            ),
                          ),
                        if (_playerDiscard.isNotEmpty)
                          Positioned(
                            bottom: 175,
                            left: 16,
                            child: CardWidget(
                              card: _playerDiscard.last,
                              scale: 0.4,
                              isFacedown: false,
                              bordaEquipadaId: _bordaCartaEquipadaId,
                            ),
                          ),
                        if (_playerDeck.isNotEmpty)
                          Positioned(
                            bottom: 175,
                            right: 16,
                            child: CardWidget(
                              card: _playerDeck.first,
                              scale: 0.4,
                              isFacedown: true,
                              bordaEquipadaId: _bordaCartaEquipadaId,
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_playerHand.length, (index) => _buildHandCard(index, false)),
                              ),
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

              // 3. BOTÕES DE AÇÃO
              if (_selectedCardIndex != null)
                Positioned(
                  bottom: 0,
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

              // 4. ELEMENTOS SOLTOS DA TELA (Resultado e Avisos de Atributos)
              if (_resultadoRoundTexto != null)
                RoundResultBanner(
                  texto: _resultadoRoundTexto!,
                  cor: _resultadoRoundCor,
                ),

              Positioned(
                left: 20,
                child: Column(
                  children: [
                    Container(
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
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white70, size: 28),
                        onPressed: () => DialogHelpers.mostrarSettings(context, onDialogClosed: () {
                          setState(() {}); 
                        }),
                        tooltip: 'Configurações',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}