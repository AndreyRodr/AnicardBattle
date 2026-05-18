import 'package:flutter/material.dart';
import '../controllers/deck_controller.dart';
import '../widgets/custom_tab_button.dart';
import '../widgets/filter_bar_widget.dart';
import '../widgets/card_grid_widget.dart';
import '../widgets/colection_item_widget.dart';
import '../widgets/card_widget.dart'; 

class DeckView extends StatefulWidget {
  const DeckView({super.key});

  @override
  State<DeckView> createState() => _DeckViewState();
}

enum ColecaoState { home, detalhePersonalizavel, detalhePacote }

class _DeckViewState extends State<DeckView> {
  final controller = DeckController();
  bool isLoading = true;

  // Estados de controle
  int _currentIndex = 0;
  String _searchQuery = '';
  String _sortCriteria = 'Aquisição';
  bool _isAscending = true;

  ColecaoState _colecaoState = ColecaoState.home;
  String _detalheTitulo = '';

  @override
  void initState() {
    super.initState();
    // Simulando o carregamento do banco de dados/Firebase
    controller.load().then((_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  // Função para exibir a carta em tela cheia com animação
  void _mostrarCartaAmpliada(BuildContext context, dynamic carta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          // Tocar em qualquer lugar (fundo ou carta) fecha o popup
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            backgroundColor: Colors.transparent, // Fundo invisível
            elevation: 0, 
            insetPadding: const EdgeInsets.all(16),
            child: Center(
              child: Hero(
                tag: 'carta_animacao_${carta.name}', // Deve ser a MESMA tag do grid
                child: CardWidget(
                  card: carta,
                  scale: 1.6, // Deixa a carta gigante na tela
                  isFacedown: false,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- Seção de Abas (Decks / Coleção) ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTabButton(
                  title: 'Decks',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                const SizedBox(width: 8),
                CustomTabButton(
                  title: 'Coleção',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ],
            ),
          ),

          // --- Área de visualização principal ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildDecksView(),   // Índice 0
                _buildColecaoView(), // Índice 1
              ],
            ),
          ),
          
          // Espaço extra no final para a barra de baixo (Bottom Nav Bar) não cobrir a última carta
          const SizedBox(height: 100), 
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 1: DECKS
  // ==========================================
  Widget _buildDecksView() {
    return Column(
      children: [
        // Container das Cartas Equipadas
        Container(
          decoration: BoxDecoration(
            color: Colors.brown[800],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.brown[900]!, width: 4),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Cartas no Deck',
                  style: TextStyle(
                    color: Colors.amber[200],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CardGridWidget(
                cards: controller.equippedCards,
                fixedSlots: 9, 
                onCardTap: (carta) async {
                  await controller.desequiparCarta(carta);
                  if (!mounted) return; 
                  setState(() {});
                },
                onCardLongPress: (carta) => _mostrarCartaAmpliada(context, carta),
              ),
              const Divider(color: Colors.brown, thickness: 2, height: 1),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Barra de Filtros
        FilterBarWidget(
          searchQuery: _searchQuery,
          sortCriteria: _sortCriteria,
          isAscending: _isAscending,
          onSearchChanged: (value) {
            setState(() => _searchQuery = value);
            // controller.filterCards(value);
          },
          onSortChanged: (value) {
            if (value != null) {
              setState(() => _sortCriteria = value);
              // controller.sortCards(value);
            }
          },
          onOrderToggled: () {
            setState(() => _isAscending = !_isAscending);
            // controller.reverseCards();
          },
        ),

        const SizedBox(height: 16),

        // Cartas do Jogador (Inventário)
        CardGridWidget(
          cards: controller.playerCards,
          onCardTap: (carta) async {
            // REGRA DO ALFA: Verifica se a carta clicada é Alpha
            if (carta.isAlpha) {
              // Verifica se já existe alguma carta Alpha equipada no deck
              final jaTemAlfaEquipado = controller.equippedCards.any((c) => c.isAlpha);
              
              if (jaTemAlfaEquipado) {
                // Mostra um aviso visual para o jogador e cancela a ação
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Você só pode ter uma carta Alfa equipada no deck!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 2),
                  ),
                );
                return; 
              }
            }

            // Se não barrou no Alfa, equipa normalmente
            await controller.equiparCarta(carta);
            if (!mounted) return;
            setState(() {});
          },
          onCardLongPress: (carta) => _mostrarCartaAmpliada(context, carta),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 2: COLEÇÃO
  // ==========================================
  Widget _buildColecaoView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.brown[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown[900]!, width: 4),
      ),
      child: switch (_colecaoState) {
        ColecaoState.home => _buildColecaoHome(),
        ColecaoState.detalhePersonalizavel => _buildColecaoDetalhe(isCartas: false),
        ColecaoState.detalhePacote => _buildColecaoDetalhe(isCartas: true),
      },
    );
  }

  // --- Home das Coleções ---
  Widget _buildColecaoHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personalizáveis:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ColectionItemWidget(
              titulo: 'Arena',
              icon: Icons.grid_on,
              onTap: () => _abrirDetalhe(ColecaoState.detalhePersonalizavel, 'Arenas:'),
            ),
            ColectionItemWidget(
              titulo: 'Borda',
              icon: Icons.crop_square,
              onTap: () => _abrirDetalhe(ColecaoState.detalhePersonalizavel, 'Bordas:'),
            ),
            ColectionItemWidget(
              titulo: 'Vida',
              icon: Icons.favorite,
              onTap: () => _abrirDetalhe(ColecaoState.detalhePersonalizavel, 'Vida:'),
            ),
          ],
        ),

        const SizedBox(height: 32),

        const Text(
          'Coleções:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ColectionItemWidget(
              titulo: 'Tanzânia',
              isPacote: true,
              onTap: () => _abrirDetalhe(ColecaoState.detalhePacote, 'Coleção Tanzânia:'),
            ),
            ColectionItemWidget(
              titulo: 'EUROPA',
              isPacote: true,
              onTap: () => _abrirDetalhe(ColecaoState.detalhePacote, 'Coleção EUROPA:'),
            ),
          ],
        ),
      ],
    );
  }

  // --- Tela de Detalhes da Coleção ---
  Widget _buildColecaoDetalhe({required bool isCartas}) {
    return Column(
      children: [
        // Cabeçalho com botão de Voltar
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent, size: 28),
              onPressed: () {
                setState(() {
                  _colecaoState = ColecaoState.home; 
                });
              },
            ),
            Expanded(
              child: Text(
                _detalheTitulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 48), // Espaço vazio para manter o texto centralizado
          ],
        ),
        const SizedBox(height: 16),

        // Mostra o Grid de Cartas ou o Grid de Itens Personalizáveis
        isCartas
            ? CardGridWidget(
                cards: controller.playerCards,
                onCardLongPress: (carta) => _mostrarCartaAmpliada(context, carta),
              ) 
            : _buildGridPersonalizaveis(),
      ],
    );
  }

  // --- Grid específico para bordas, arenas, etc ---
  Widget _buildGridPersonalizaveis() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9, 
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, index) {
        return ColectionItemWidget(
          titulo: 'Item ${index + 1}',
          icon: Icons.star,
          onTap: () {
            // Ação ao equipar/visualizar uma arena ou borda
          },
        );
      },
    );
  }

  // Função auxiliar para navegar internamente na aba de coleções
  void _abrirDetalhe(ColecaoState novoEstado, String titulo) {
    setState(() {
      _colecaoState = novoEstado;
      _detalheTitulo = titulo;
    });
  }
}