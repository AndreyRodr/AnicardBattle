import 'package:flutter/material.dart';
import '../controllers/deck_controller.dart';
import '../controllers/collection_controller.dart';
import '../simulator/card_catalog.dart';
import '../widgets/custom_tab_button.dart';
import '../widgets/filter_bar_widget.dart';
import '../widgets/card_grid_widget.dart';
import '../widgets/card_widget.dart';
import '../widgets/locked_card_widget.dart';
import 'colecao_view.dart';

class DeckView extends StatefulWidget {
  const DeckView({super.key});

  @override
  State<DeckView> createState() => _DeckViewState();
}

class _DeckViewState extends State<DeckView> {
  final controller = DeckController();
  final colController = CollectionController(); 
  bool isLoading = true;

  int _currentIndex = 0;
  String _searchQuery = '';
  String _sortCriteria = 'Nome';
  bool _isAscending = true;

  List<dynamic> get _cartasFiltradas {
    List<dynamic> lista = List.from(controller.playerCards);
    List<dynamic> todasDoCatalogo = CardCatalog.getAllCards();
    
    for (var carta in todasDoCatalogo) {
      bool noInventario = controller.playerCards.any((c) => c.id == carta.id);
      bool noDeck = controller.equippedCards.any((c) => c.id == carta.id);
      
      if (!noInventario && !noDeck) {
        lista.add(carta);
      }
    }

    if (_searchQuery.trim().isNotEmpty) {
      lista = lista.where((carta) {
        return carta.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    lista.sort((a, b) {
      bool aPossui = controller.playerCards.any((c) => c.id == a.id);
      bool bPossui = controller.playerCards.any((c) => c.id == b.id);

      if (aPossui && !bPossui) return -1;
      if (!aPossui && bPossui) return 1;

      int comparacao = 0;
      switch (_sortCriteria) {
        case 'Nome':
          comparacao = a.name.compareTo(b.name);
          break;
        case 'Média':
          comparacao = a.media.compareTo(b.media);
          break;
        default:
          comparacao = 0;
          break;
      }
      return comparacao;
    });

    if (!_isAscending) {
      lista = lista.reversed.toList();
    }

    return lista;
  }

  @override
  void initState() {
    super.initState();
    colController.carregarCosmeticos();
    controller.load().then((_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  void _mostrarCartaAmpliada(BuildContext context, dynamic carta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.all(16),
            child: Center(
              child: Hero(
                tag: 'carta_animacao_${carta.name}',
                child: CardWidget(
                  card: carta,
                  scale: 1.6,
                  isFacedown: false,
                  bordaEquipadaId : colController.bordaEquipada,
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

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildDecksView(),   // Índice 0
                ColecaoView(         // Índice 1 (Nova View Externa chamada por completo)
                  deckController: controller, 
                  colController: colController,
                ), 
              ],
            ),
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDecksView() {
    return Column(
      children: [
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
                bordaEquipadaId: colController.bordaEquipada,
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

        FilterBarWidget(
          searchQuery: _searchQuery,
          sortCriteria: _sortCriteria,
          isAscending: _isAscending,
          onSearchChanged: (value) {
            setState(() => _searchQuery = value);
          },
          onSortChanged: (value) {
            if (value != null) {
              setState(() => _sortCriteria = value);
            }
          },
          onOrderToggled: () {
            setState(() => _isAscending = !_isAscending);
          },
        ),

        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cartasFiltradas.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final carta = _cartasFiltradas[index];
            bool possuiNaColecao = controller.playerCards.any((c) => c.id == carta.id);
            Widget cardVisual = CardWidget(card: carta, isFacedown: false, bordaEquipadaId: colController.bordaEquipada,);

            if (possuiNaColecao) {
              return GestureDetector(
                onTap: () async {
                  if (carta.isAlpha) {
                    final jaTemAlfaEquipado = controller.equippedCards.any((c) => c.isAlpha);
                    if (jaTemAlfaEquipado) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você só pode ter uma carta Alfa equipada no deck!', style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                  }
                  await controller.equiparCarta(carta);
                  if (!mounted) return;
                  setState(() {});
                },
                onLongPress: () => _mostrarCartaAmpliada(context, carta),
                child: cardVisual,
              );
            } else {
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Abra pacotes para desbloquear o(a) ${carta.name}!'),
                      backgroundColor: const Color(0xFF1B3620),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onLongPress: () => _mostrarCartaAmpliada(context, carta),
                child: LockedCardWidget(cardWidget: cardVisual),
              );
            }
          },
        ),
      ],
    );
  }
}