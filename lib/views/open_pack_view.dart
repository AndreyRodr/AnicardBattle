import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import '../models/card_model.dart';
import '../widgets/card_widget.dart';

class PackModel {
  final String id; 
  final String name;
  final String imagePath;

  PackModel({required this.id, required this.name, required this.imagePath});
}

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
  List<CardModel> _allCatalogCards = [];

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
      print("Erro ao carregar catálogo para a loja: $e");
    }
  }

  void _nextPack() {
    setState(() {
      if (_currentIndex < _availablePacks.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
  }

  void _previousPack() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _availablePacks.length - 1;
      }
    });
  }

  // 🌟 FUNÇÃO ATUALIZADA: Puxa também a lista de cartas equipadas do Firestore
  Future<void> _abrirPacote(int pacotesPossuidos, List<dynamic> inventarioAtual, List<dynamic> cartasEquipadasAtual) async {
    if (pacotesPossuidos < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você não tem pacotes suficientes! Compre na loja.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_allCatalogCards.isEmpty) return;

    setState(() => _isOpening = true);
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

      // Mapeia todas as listas do usuário para String para evitar bugs de tipos no Firestore
      List<String> inventarioString = inventarioAtual.map((id) => id.toString()).toList();
      List<String> equipadasString = cartasEquipadasAtual.map((id) => id.toString()).toList();

      for (int i = 0; i < 3; i++) {
        CardModel carta = cartasDisponiveis[random.nextInt(cartasDisponiveis.length)];
        cartasSorteadas.add(carta);

        List<String> temporariaString = idsParaInventario.map((id) => id.toString()).toList();

        // 🌟 CORREÇÃO AQUI: Agora a carta conta como repetida se estiver no inventário, na lista temporária do pack OU já equipada no deck!
        bool ehRepetida = inventarioString.contains(carta.id.toString()) || 
                          equipadasString.contains(carta.id.toString()) ||
                          temporariaString.contains(carta.id.toString());
        
        statusRepetidas.add(ehRepetida);
        idsParaInventario.add(carta.id);

        print("🔍 Sorteio Gacha - Carta: ${carta.name} (ID: ${carta.id}) | No Deck? ${equipadasString.contains(carta.id.toString())} | Repetida? $ehRepetida");
      }

      // Consome o pacote e adiciona os animais no array do banco
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'pacotes.$currentPackId': FieldValue.increment(-1),
        'inventario': FieldValue.arrayUnion(idsParaInventario),
      });

      if (!mounted) return;
      _mostrarAnimacaoRevelacao(cartasSorteadas, statusRepetidas);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir pacote: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isOpening = false);
    }
  }

  void _mostrarAnimacaoRevelacao(List<CardModel> cartas, List<bool> repetidas) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _PackOpeningDialog(
          cartas: cartas,
          repetidas: repetidas,
        );
      },
    );
  }

  Widget _buildArrowButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1B3320),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green[800]!, width: 2),
        ),
        child: Icon(icon, color: Colors.white70, size: 30),
      ),
    );
  }

  Widget _buildPackDisplay(PackModel pack, int quantity) {
    return SizedBox(
      width: 220, 
      height: 320,
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1B3320),
              border: Border.all(color: Colors.green[800]!, width: 3),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    pack.name, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                ],
              ), 
            ),
          ),
          Positioned(
            bottom: -15,
            right: -15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Text(
                  '$quantity',
                  style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3320),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[800]!, width: 2),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
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
          cartasEquipadasAtual = data['cartasEquipadas'] ?? []; // 🌟 Puxa o array do Deck real do banco
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildArrowButton(
                          icon: Icons.arrow_back,
                          onTap: _isOpening ? () {} : _previousPack,
                        ),
                        _buildPackDisplay(currentPack, pacotesPossuidos),
                        _buildArrowButton(
                          icon: Icons.arrow_forward,
                          onTap: _isOpening ? () {} : _nextPack,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildActionButton(
                    title: _isOpening ? 'SORTEANDO...' : 'ABRIR PAC (3 CARTAS)',
                    onTap: _isOpening ? () {} : () => _abrirPacote(pacotesPossuidos, inventarioAtual, cartasEquipadasAtual),
                  ),
                ],
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

  const _PackOpeningDialog({
    required this.cartas,
    required this.repetidas,
  });

  @override
  State<_PackOpeningDialog> createState() => _PackOpeningDialogState();
}

class _PackOpeningDialogState extends State<_PackOpeningDialog> {
  int _cardIndex = 0; 
  final FlipCardController _flipController = FlipCardController();
  bool _mostrarMoeda = false;
  bool _isFront = true; 

  void _avancarOuFechar() {
    if (_cardIndex < 2) {
      setState(() {
        _cardIndex++;
        _mostrarMoeda = false;
        _isFront = true; 
      });
    }
  }

  void _fecharPacoteNaUltimaCarta() {
    if (_cardIndex == 2 && !_isFront) {
      Navigator.of(context).pop();
    }
  }

  void _revelarCarta() {
    _flipController.toggleCard();
    setState(() {
      _isFront = false; 
    });
  }

  Future<void> _converterRepetidaEAvancar() async {
    _flipController.toggleCard(); 
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'moedas': FieldValue.increment(50),
        });
      } catch (e) {
        print("Erro ao injetar moedas da repetida: $e");
      }
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _mostrarMoeda = true;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        if (_cardIndex < 2) {
          _avancarOuFechar();
        } else {
          setState(() {}); 
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartaAtual = widget.cartas[_cardIndex];
    final ehRepetida = widget.repetidas[_cardIndex];

    return GestureDetector(
      onTap: _cardIndex == 2 && !_isFront 
          ? _fecharPacoteNaUltimaCarta 
          : null,
      behavior: HitTestBehavior.opaque,
      
      child: Material(
        color: Colors.transparent, 
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "CARTA ${_cardIndex + 1} DE 3",
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.5,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(2, 2))]
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: 250,
                height: 350,
                child: FlipCard(
                  key: ValueKey(_cardIndex), 
                  speed: 600,
                  direction: FlipDirection.VERTICAL,
                  controller: _flipController,
                  flipOnTouch: false,
                  front: CardWidget(
                    card: cartaAtual,
                    isFacedown: true,
                    scale: 1.2,
                  ),
                  back: _mostrarMoeda 
                      ? _buildCoinAnimation() 
                      : CardWidget(card: cartaAtual, isFacedown: false, scale: 1.2),
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
              
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "TOQUE NA TELA PARA CONCLUIR PACOTE",
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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

  Widget _buildCoinAnimation() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 100),
          const SizedBox(height: 16),
          const Text(
            "CONVERTIDA!",
            style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
            child: const Text(
              "+50 MOEDAS",
              style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}