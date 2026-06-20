import 'dart:convert';
import 'dart:math';
import 'package:anicard/services/quest_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import '../models/card_model.dart';
import '../models/pack_model.dart';
import '../widgets/card_widget.dart';
import '../widgets/pack_display_widget.dart';
import '../widgets/pack_explosion_widget.dart';

class OpenPackView extends StatefulWidget {
  const OpenPackView({super.key});

  @override
  State<OpenPackView> createState() => _OpenPackViewState();
}

class _OpenPackViewState extends State<OpenPackView> {
  final List<PackModel> _availablePacks = [
    PackModel(id: 'floresta_amazonica', name: 'Floresta Amazônica', imagePath: 'assets/images/packs/amazon_pack.png'),
    PackModel(id: 'savana_africana', name: 'Savana Africana', imagePath: 'assets/images/packs/savanna_pack.png'),
    PackModel(id: 'tundra_polar', name: 'Tundra Polar', imagePath: 'assets/images/packs/tundra_pack.png'),
  ];

  int _currentIndex = 0;
  bool _isOpening = false;
  bool _skipAnimation = false; 
  List<CardModel> _allCatalogCards = [];

  List<CardModel> _cartasSorteadasTemp = [];
  List<bool> _statusRepetidasTemp = [];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final String response = await rootBundle.loadString('assets/data/cards.json');
      final data = json.decode(response);
      setState(() {
        _allCatalogCards = (data['cards'] as List).map((c) => CardModel.fromJson(c)).toList();
      });
    } catch (e) {
      print("Erro ao carregar catálogo: $e");
    }
  }

  void _nextPack() {
    if (_isOpening) return;
    setState(() {
      _currentIndex = (_currentIndex < _availablePacks.length - 1) ? _currentIndex + 1 : 0;
    });
  }

  void _previousPack() {
    if (_isOpening) return;
    setState(() {
      _currentIndex = (_currentIndex > 0) ? _currentIndex - 1 : _availablePacks.length - 1;
    });
  }

  Future<void> _abrirPacote(int pacotesPossuidos, List<dynamic> inventarioAtual, List<dynamic> cartasEquipadasAtual) async {
    if (pacotesPossuidos < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você não tem pacotes suficientes! Compre na loja.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_allCatalogCards.isEmpty) return;

    setState(() {
      _isOpening = true;
      _skipAnimation = false; 
    });
    
    final user = FirebaseAuth.instance.currentUser;
    final currentPackId = _availablePacks[_currentIndex].id;

    try {
      List<CardModel> cartasDisponiveis = _allCatalogCards.where((c) => c.pack == currentPackId).toList();

      if (cartasDisponiveis.isEmpty) {
        throw Exception("Nenhuma carta configurada para o bioma $currentPackId no JSON.");
      }

      final random = Random();
      List<CardModel> cartasSorteadas = [];
      List<bool> statusRepetidas = [];
      List<int> idsParaInventario = [];

      List<String> inventarioString = inventarioAtual.map((id) => id.toString()).toList();
      List<String> equipadasString = cartasEquipadasAtual.map((id) => id.toString()).toList();

      for (int i = 0; i < 3; i++) {
        CardModel carta = cartasDisponiveis[random.nextInt(cartasDisponiveis.length)];
        cartasSorteadas.add(carta);

        List<String> temporariaString = idsParaInventario.map((id) => id.toString()).toList();

        bool ehRepetida = inventarioString.contains(carta.id.toString()) || 
                          equipadasString.contains(carta.id.toString()) ||
                          temporariaString.contains(carta.id.toString());
        
        statusRepetidas.add(ehRepetida);
        idsParaInventario.add(carta.id);
      }

      _cartasSorteadasTemp = cartasSorteadas;
      _statusRepetidasTemp = statusRepetidas;

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'pacotes.$currentPackId': FieldValue.increment(-1),
        'inventario': FieldValue.arrayUnion(idsParaInventario),
      });

      // 🌟 O GATILHO COMPATIVEL COM AS MISSÕES DIÁRIAS/SEMANAIS:
      // Executa apenas se a gravação do pacote foi um sucesso completo
      try {
        await QuestService().atualizarProgressoMissao(uid: user.uid, acaoId: 'packs');
      } catch (e) {
        debugPrint("Erro ao registrar progresso de abertura de pack: $e");
      }

    } catch (e) {
      setState(() => _isOpening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir pacote: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _finalizarAbertura() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isOpening = false;
      });
      _mostrarAnimacaoRevelacao(_cartasSorteadasTemp, _statusRepetidasTemp);
    });
  }

  void _mostrarAnimacaoRevelacao(List<CardModel> cartas, List<bool> repetidas) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PackOpeningDialog(cartas: cartas, repetidas: repetidas),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentPack = _availablePacks[_currentIndex];

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        int pacotesPossuidos = 0;
        List<dynamic> inventarioAtual = [];
        List<dynamic> cartasEquipadasAtual = [];
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final pacotesMap = data['pacotes'] as Map<String, dynamic>? ?? {};
          
          pacotesPossuidos = pacotesMap[currentPack.id] ?? 0;
          inventarioAtual = data['inventario'] ?? [];
          cartasEquipadasAtual = data['cartasEquipadas'] ?? []; 
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: _isOpening ? () => setState(() => _skipAnimation = true) : null,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isOpening) ...[
                            GestureDetector(
                              onTap: _previousPack,
                              child: Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(color: const Color(0xFF1B3320), shape: BoxShape.circle, border: Border.all(color: Colors.green[800]!, width: 2)),
                                child: const Icon(Icons.arrow_back, color: Colors.white70, size: 30),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          
                          Flexible(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isOpening
                                  ? PackExplosionWidget(
                                      key: ValueKey('explosion_${currentPack.id}'),
                                      imagePath: currentPack.imagePath,
                                      skipTriggered: _skipAnimation, 
                                      onExplosionComplete: _finalizarAbertura,
                                    )
                                  : PackDisplayWidget(
                                      key: ValueKey('display_${currentPack.id}'),
                                      pack: currentPack, 
                                      quantity: pacotesPossuidos,
                                    ),
                            ),
                          ),
                          
                          if (!_isOpening) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _nextPack,
                              child: Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(color: const Color(0xFF1B3320), shape: BoxShape.circle, border: Border.all(color: Colors.green[800]!, width: 2)),
                                child: const Icon(Icons.arrow_forward, color: Colors.white70, size: 30),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _isOpening ? () => setState(() => _skipAnimation = true) : () => _abrirPacote(pacotesPossuidos, inventarioAtual, cartasEquipadasAtual),
                      child: Container(
                        width: 240,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3320),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[800]!, width: 2),
                        ),
                        child: Text(
                          _isOpening ? 'TOCAR PARA PULAR' : 'ABRIR PACOTE',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

class _PackOpeningDialog extends StatefulWidget {
  final List<CardModel> cartas;
  final List<bool> repetidas;
  const _PackOpeningDialog({required this.cartas, required this.repetidas});
  @override
  State<_PackOpeningDialog> createState() => _PackOpeningDialogState();
}

class _PackOpeningDialogState extends State<_PackOpeningDialog> {
  int _cardIndex = 0; 
  final FlipCardController _flipController = FlipCardController();
  bool _mostrarMoeda = false;
  bool _isFront = true; 
  bool _animandoTransicao = false; 

  void _avancarOuFechar() {
    if (_cardIndex < 2) {
      setState(() { 
        _cardIndex++; 
        _mostrarMoeda = false; 
        _isFront = true; 
        _animandoTransicao = false;
      });
    }
  }

  void _fecharPacoteNaUltimaCarta() {
    if (_cardIndex == 2 && !_isFront) Navigator.of(context).pop();
  }

  // 🌟 FUNÇÃO CENTRAL DE INTERAÇÃO NA TELA INTEIRA
  void _lidarComToqueNaTela() {
    if (_animandoTransicao) return;

    if (_isFront) {
      // Se a carta está fechada, vira para revelar o animal
      _revelarCarta();
    } else if (widget.repetidas[_cardIndex] && !_mostrarMoeda) {
      // Se a carta está aberta e é repetida, converte em moedas
      _converterRepetidaEAvancar();
    } else {
      // Se for a última carta concluída, fecha o dialog
      _fecharPacoteNaUltimaCarta();
    }
  }

  void _revelarCarta() {
    if (_animandoTransicao) return;
    
    _flipController.toggleCard();
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isFront = false);
      
      final ehRepetida = widget.repetidas[_cardIndex];
      if (!ehRepetida && _cardIndex < 2) {
        setState(() => _animandoTransicao = true);
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) _avancarOuFechar();
        });
      }
    });
  }

  Future<void> _converterRepetidaEAvancar() async {
    if (_animandoTransicao) return;
    
    setState(() {
      _animandoTransicao = true;
      _mostrarMoeda = true; 
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'moedas': FieldValue.increment(50)});
      } catch (e) { print("Erro ao atualizar moedas: $e"); }
    }
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        if (_cardIndex < 2) {
          _avancarOuFechar(); 
        } else {
          setState(() {
            _animandoTransicao = false; 
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartaAtual = widget.cartas[_cardIndex];
    final ehRepetida = widget.repetidas[_cardIndex];
    
    
    return GestureDetector(
      // 🌟 MUDANÇA: Agora o detector de gestos chama a função central mapeando cliques em qualquer parte vazia da tela
      onTap: _lidarComToqueNaTela,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent, 
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("CARTA ${_cardIndex + 1} DE 3", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(2, 2))])),
              const SizedBox(height: 24),
              
              // O Card em si também aceita cliques para rodar a lógica sem travar
              GestureDetector(
                onTap: _lidarComToqueNaTela,
                child: SizedBox(
                  width: 250, height: 350,
                  child: FlipCard(
                    key: ValueKey(_cardIndex), 
                    speed: 600,
                    direction: FlipDirection.VERTICAL,
                    controller: _flipController,
                    flipOnTouch: false,
                    front: CardWidget(card: cartaAtual, isFacedown: true, scale: 1.2),
                    back: _mostrarMoeda ? _buildCoinAnimation() : CardWidget(card: cartaAtual, isFacedown: false, scale: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              if (_isFront)
                ElevatedButton.icon(
                  onPressed: _revelarCarta, 
                  icon: const Icon(Icons.touch_app), 
                  label: const Text("REVELAR ANIMAL"), 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                )
              else if (ehRepetida && !_mostrarMoeda)
                ElevatedButton.icon(
                  onPressed: _converterRepetidaEAvancar, 
                  icon: const Icon(Icons.cached), 
                  label: const Text("REPETIDA! REIVINDICAR +50 MOEDAS"), 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                )
              else if (_cardIndex < 2)
                const SizedBox(height: 40)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text("TOQUE NA TELA PARA CONCLUIR PACOTE", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinAnimation() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber, width: 3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 100),
          const SizedBox(height: 16),
          const Text("CONVERTIDA!", style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
            child: const Text("+50 MOEDAS", style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}