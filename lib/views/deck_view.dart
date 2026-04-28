import 'package:flutter/material.dart';
import '../controllers/deck_controller.dart';
import '../widgets/custom_tab_button.dart';
import '../widgets/filter_bar_widget.dart';
import '../widgets/card_grid_widget.dart';
import '../widgets/colection_item_widget.dart';

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
    controller.load().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Seção de Abas
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

          // Área de visualização (Decks ou Coleção)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: IndexedStack(
              index: _currentIndex,
              children: [_buildDecksView(), _buildColecaoView()],
            ),
          ),
        ],
      ),
    );
  }

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
              CardGridWidget(cards: controller.equippedCards),
              const Divider(color: Colors.brown, thickness: 2, height: 1),
            ],
          ),
        ),

        const SizedBox(height: 8),

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

        const SizedBox(height: 8),

        // Cartas do Jogador (Inventário)
        CardGridWidget(cards: controller.playerCards),
      ],
    );
  }

  Widget _buildColecaoView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown[900]!, width: 4),
        ),
        child: switch (_colecaoState) {
          ColecaoState.home => _buildColecaoHome(),
          ColecaoState.detalhePersonalizavel => _buildColecaoDetalhe(
            isCartas: false,
          ),
          ColecaoState.detalhePacote => _buildColecaoDetalhe(isCartas: true),
        },
      ),
    );
  }

  // Home das Coleções
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
              onTap: () =>
                  _abrirDetalhe(ColecaoState.detalhePersonalizavel, 'Arenas:'),
            ),
            ColectionItemWidget(
              titulo: 'Borda',
              icon: Icons.crop_square,
              onTap: () =>
                  _abrirDetalhe(ColecaoState.detalhePersonalizavel, 'Bordas:'),
            ),
            ColectionItemWidget(
              titulo: 'Vida',
              icon: Icons.favorite,
              onTap: () =>
                  _abrirDetalhe(ColecaoState.detalhePersonalizavel, 'Vida:'),
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
              onTap: () => _abrirDetalhe(
                ColecaoState.detalhePacote,
                'Coleção Tanzânia:',
              ),
            ),
            ColectionItemWidget(
              titulo: 'EUROPA',
              isPacote: true,
              onTap: () =>
                  _abrirDetalhe(ColecaoState.detalhePacote, 'Coleção EUROPA:'),
            ),
          ],
        ),
      ],
    );
  }

  // Detalhes
  Widget _buildColecaoDetalhe({required bool isCartas}) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
              onPressed: () {
                setState(() {
                  _colecaoState = ColecaoState.home; // Volta pra home
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
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 16),

        // TODO: Aqui você chamará o CardGridWidget para cartas, ou um novo Grid genérico para arenas
        isCartas
            ? CardGridWidget(
                cards: controller.playerCards,
              ) // Passe a lista filtrada do pacote aqui
            : _buildGridPersonalizaveis(),
      ],
    );
  }

  Widget _buildGridPersonalizaveis() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9, // Mock
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, index) {
        return ColectionItemWidget(
          titulo: 'Arena ${index + 1}',
          icon: Icons.grid_on,
          onTap: () {},
        );
      },
    );
  }

  // Função auxiliar para trocar de tela e definir o título
  void _abrirDetalhe(ColecaoState novoEstado, String titulo) {
    setState(() {
      _colecaoState = novoEstado;
      _detalheTitulo = titulo;
    });
  }
}
