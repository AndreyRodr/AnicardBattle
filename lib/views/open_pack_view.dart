import 'package:flutter/material.dart';

// Mock de um modelo de pacote para o exemplo
class PackModel {
  final String id;
  final String name;
  final String imagePath; // Caminho do seu asset do pacote
  final int quantity;

  PackModel({required this.id, required this.name, required this.imagePath, required this.quantity});
}

class OpenPackView extends StatefulWidget {
  const OpenPackView({super.key});

  @override
  State<OpenPackView> createState() => _OpenPackViewState();
}

class _OpenPackViewState extends State<OpenPackView> {
  // Mock da sua lista de pacotes vinda de um controller
  final List<PackModel> _availablePacks = [
    PackModel(id: '1', name: 'Tanzânia', imagePath: 'assets/pacote_tanzania.png', quantity: 0),
    PackModel(id: '2', name: 'Europa', imagePath: 'assets/pacote_europa.png', quantity: 5),
  ];

  int _currentIndex = 0;

  void _nextPack() {
    setState(() {
      if (_currentIndex < _availablePacks.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Volta para o primeiro se chegar no fim
      }
    });
  }

  void _previousPack() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _availablePacks.length - 1; // Vai para o último se estiver no início
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPack = _availablePacks[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.transparent, // Permite que o fundo da sua MainView apareça
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Área do Pacote e Setas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildArrowButton(
                      icon: Icons.arrow_back,
                      onTap: _previousPack,
                    ),
                    
                    // Imagem do pacote com Badge de quantidade
                    _buildPackDisplay(currentPack),
                    
                    _buildArrowButton(
                      icon: Icons.arrow_forward,
                      onTap: _nextPack,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),

              //Botões de Ação
              _buildActionButton(
                title: 'ABRIR',
                onTap: () {
                  // TODO: Lógica para abrir 1 pacote
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                title: 'ABRIR 10',
                onTap: () {
                  // TODO: Lógica para abrir 10 pacotes
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Setas de navegação
  Widget _buildArrowButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1B3320), // Cor verde escura do design
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green[800]!, width: 2),
        ),
        child: Icon(icon, color: Colors.white70, size: 30),
      ),
    );
  }

  // Display do Pacote com Stack
  Widget _buildPackDisplay(PackModel pack) {
    return SizedBox(
      width: 220, 
      height: 320,
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white24, // Mock de cor caso a imagem não carregue
              // TODO: Descomente abaixo e ajuste quando tiver as imagens na pasta assets
              /*
              image: DecorationImage(
                image: AssetImage(pack.imagePath),
                fit: BoxFit.cover,
              ),
              */
            ),
            child: const Center(
              child: Text('Imagem do Pacote', style: TextStyle(color: Colors.white)), 
            ),
          ),
          
          // Badge circular de quantidade
          Positioned(
            bottom: -15,
            right: -15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${pack.quantity}',
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Botões de abrir
  Widget _buildActionButton({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3320), // Verde escuro
          border: Border.all(color: Colors.green[800]!, width: 2),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}