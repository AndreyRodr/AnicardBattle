import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Painel para a oferta principal (Mantido seu layout)
class MainOfferWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String oldPrice;
  final String newPrice;
  final VoidCallback onTap;

  const MainOfferWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.oldPrice,
    required this.newPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B3620),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap, 
        borderRadius: BorderRadius.circular(8), 
        child: SizedBox(
          width: 358,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.asset(
                  imagePath, 
                  width: double.infinity,
                  height: 330,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title, 
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              oldPrice, 
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.white70,
                                decorationThickness: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                            const SizedBox(width: 4),
                            Text(
                              newPrice, 
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
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

// Widget de compra de moedas (Mantido seu layout)
class CoinOfferWidget extends StatelessWidget {
  final String coinValue;
  final String price;
  final VoidCallback onTap;

  const CoinOfferWidget({
    super.key,
    required this.coinValue,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B3620),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 110,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber, 
                  size: 32, 
                ),
                const SizedBox(height: 8), 
                Text(
                  "$coinValue moedas", 
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14, 
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D9E4E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "R\$ $price", 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
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
}

// Card individual dos pacotes (Ajustado para cobrir a área inteira com a imagem)
class PackOfferWidget extends StatelessWidget {
  final String packName;
  final String packPrice;
  final String? imagePath; 
  final IconData fallbackIcon; 
  final VoidCallback onTap;

  const PackOfferWidget({
    super.key,
    required this.packName,
    required this.packPrice,
    required this.fallbackIcon,
    required this.onTap,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B3620),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity, // Ocupa o tamanho do slide do PageView (200x330)
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // 🌟 Se tiver imagem, o fundo cinza fica transparente para não vazar nas bordas
                    color: imagePath != null ? Colors.transparent : const Color(0x1AFFFFFF), 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            imagePath!, 
                            fit: BoxFit.fill, // 🌟 Alterado de contain para fill para cobrir 100% da área cinza
                          ),
                        )
                      : Icon(fallbackIcon, color: Colors.greenAccent, size: 54),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                packName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.black, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      packPrice,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
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

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;
  final int _totalPacks = 3; 

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _totalPacks - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; 
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _comprarPacoteGenerico(BuildContext context, int custo, String packIdFirestore, int quantidade) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return;

      final data = userDoc.data() as Map<String, dynamic>;
      int moedasAtuais = data['moedas'] ?? 0;

      if (moedasAtuais < custo) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saldo de moedas insuficiente!'), backgroundColor: Colors.red),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'moedas': FieldValue.increment(-custo),
        'pacotes.$packIdFirestore': FieldValue.increment(quantidade),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compra realizada com sucesso!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na compra: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _simularCompraMoedas(BuildContext context, String quantidadeTexto) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    int quantidade = int.tryParse(quantidadeTexto) ?? 0;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'moedas': FieldValue.increment(quantidade),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('+$quantidade moedas adicionadas à sua carteira!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao processar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SEÇÃO 1: OFERTAS PRINCIPAIS ---
          const Text(
            "Ofertas:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 16),
          
          Center(
            child: MainOfferWidget(
              imagePath: "assets/images/packs/amazon_pack.png",
              title: "Combo: 3 Pacotes Floresta",
              oldPrice: '1050',
              newPrice: '800', 
              onTap: () => _comprarPacoteGenerico(context, 800, 'floresta_amazonica', 3),
            ),
          ),
          
          const SizedBox(height: 32), 

          // --- SEÇÃO 2: CARROSSEL AUTOMÁTICO DE UM PACOTE ---
          const Text(
            "Pacotes:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 16),

Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Seta para a Esquerda (Agora sempre ativa)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                color: Colors.white, // 🌟 Sempre branca
                iconSize: 32,
                onPressed: () {
                  if (_currentPage == 0) {
                    // Se estiver no primeiro, vai lá para o último (índice 2)
                    _pageController.animateToPage(
                      2,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // Comportamento normal
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),

              // 2. O seu Carrossel Original
              SizedBox(
                width: 200,
                height: 330,
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    PackOfferWidget(
                      packName: "Floresta Amazônica",
                      packPrice: "350",
                      imagePath: "assets/images/packs/amazon_pack.png",
                      fallbackIcon: Icons.forest,
                      onTap: () => _comprarPacoteGenerico(context, 350, 'floresta_amazonica', 1),
                    ),
                    PackOfferWidget(
                      packName: "Savana Africana",
                      packPrice: "350",
                      imagePath: "assets/images/packs/savanna_pack.png",
                      fallbackIcon: Icons.wb_sunny,
                      onTap: () => _comprarPacoteGenerico(context, 350, 'savana_africana', 1),
                    ),
                    PackOfferWidget(
                      packName: "Tundra Polar",
                      packPrice: "350",
                      imagePath: "assets/images/packs/tundra_pack.png",
                      fallbackIcon: Icons.ac_unit,
                      onTap: () => _comprarPacoteGenerico(context, 350, 'tundra_polar', 1),
                    ),
                  ],
                ),
              ),

              // 3. Seta para a Direita (Agora sempre ativa)
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                color: Colors.white, // 🌟 Sempre branca
                iconSize: 32,
                onPressed: () {
                  if (_currentPage == 2) {
                    // Se estiver no último, volta lá para o primeiro (índice 0)
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // Comportamento normal
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
          
          const SizedBox(height: 12),

          // BARRINHAS DE INDICADOR DE PÁGINA
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPacks, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 6,
                width: _currentPage == index ? 24 : 8, 
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.amber : Colors.white38,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          const SizedBox(height: 32), 
          
          // --- SEÇÃO 3: COMPRA DE MOEDAS ---
          const Text(
            "Moedas:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center, 
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                CoinOfferWidget(
                  coinValue: '100', 
                  price: '6.50',    
                  onTap: () => _simularCompraMoedas(context, '100'),
                ),
                CoinOfferWidget(
                  coinValue: '300',
                  price: '15.00',
                  onTap: () => _simularCompraMoedas(context, '300'),
                ),
                CoinOfferWidget(
                  coinValue: '500',
                  price: '25.00',
                  onTap: () => _simularCompraMoedas(context, '500'),
                ),
                CoinOfferWidget(
                  coinValue: '1000',
                  price: '45.00',
                  onTap: () => _simularCompraMoedas(context, '1000'),
                ),
                CoinOfferWidget(
                  coinValue: '2500',
                  price: '100.00',
                  onTap: () => _simularCompraMoedas(context, '2500'),
                ),
                CoinOfferWidget(
                  coinValue: '5000',
                  price: '180.00',
                  onTap: () => _simularCompraMoedas(context, '5000'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 120), 
        ],
      ),
    );
  }
}