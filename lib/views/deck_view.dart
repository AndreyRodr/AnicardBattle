import 'package:flutter/material.dart';
import '../controllers/deck_controller.dart';
import '../simulator/card_catalog.dart'; 
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
  String _sortCriteria = 'Nome';
  bool _isAscending = true;

  ColecaoState _colecaoState = ColecaoState.home;
  String _detalheTitulo = '';

  // 🌟 LÓGICA ATUALIZADA: Agrupa por Desbloqueadas primeiro, e Bloqueadas por último
  List<dynamic> get _cartasFiltradas {
    // 1. Começamos com as cartas que estão livres e disponíveis no inventário
    List<dynamic> lista = List.from(controller.playerCards);

    // 2. Buscamos o catálogo completo para injetar as cartas de exibição BLOQUEADAS
    List<dynamic> todasDoCatalogo = CardCatalog.getAllCards();
    
    for (var carta in todasDoCatalogo) {
      bool noInventario = controller.playerCards.any((c) => c.id == carta.id);
      bool noDeck = controller.equippedCards.any((c) => c.id == carta.id);
      
      // Se o jogador não tem no inventário E NEM no deck, ela entra como bloqueada
      if (!noInventario && !noDeck) {
        lista.add(carta);
      }
    }

    // 3. Aplicar a Pesquisa por Nome (se houver texto digitado)
    if (_searchQuery.trim().isNotEmpty) {
      lista = lista.where((carta) {
        return carta.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 4. 🌟 ORDENAÇÃO DUPLO ESTÁGIO: Bloqueio primeiro, Critério depois
    lista.sort((a, b) {
      // Verifica se o jogador possui fisicamente cada uma das cartas na coleção
      bool aPossui = controller.playerCards.any((c) => c.id == a.id);
      bool bPossui = controller.playerCards.any((c) => c.id == b.id);

      // CRITÉRIO 1: Se uma for desbloqueada e a outra bloqueada, a desbloqueada vem primeiro
      if (aPossui && !bPossui) return -1; // 'a' sobe na lista
      if (!aPossui && bPossui) return 1;  // 'b' sobe na lista

      // CRITÉRIO 2 (Desempate): Se ambas forem do mesmo tipo (ambas liberadas ou ambas trancadas),
      // aí sim aplica o filtro selecionado pelo usuário (Nome ou Média)
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

    // 5. Aplicar a inversão de ordem (Crescente ou Decrescente)
    if (!_isAscending) {
      lista = lista.reversed.toList();
    }

    return lista;
  }

  @override
  void initState() {
    super.initState();
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
                _buildColecaoView(), // Índice 1
              ],
            ),
          ),
          
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

            Widget cardVisual = CardWidget(card: carta, isFacedown: false);

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

  // ==========================================
  // VIEW 2: COLEÇÃO (Mantida igual)
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


  Widget _buildColecaoDetalhe({required bool isCartas}) {
    return Column(
      children: [
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
            const SizedBox(width: 48), 
          ],
        ),
        const SizedBox(height: 16),

        isCartas
            ? CardGridWidget(
                cards: controller.playerCards,
                onCardLongPress: (carta) => _mostrarCartaAmpliada(context, carta),
              ) 
            : _buildGridPersonalizaveis(),
      ],
    );
  }

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
          onTap: () {},
        );
      },
    );
  }

  void _abrirDetalhe(ColecaoState novoEstado, String titulo) {
    setState(() {
      _colecaoState = novoEstado;
      _detalheTitulo = titulo;
    });
  }
}

class LockedCardWidget extends StatelessWidget {
  final Widget cardWidget;
  final double scale;

  const LockedCardWidget({
    super.key,
    required this.cardWidget,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.85),
              BlendMode.srcATop,
            ),
            child: cardWidget,
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: const Icon(
              Icons.lock,
              color: Colors.amber,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}