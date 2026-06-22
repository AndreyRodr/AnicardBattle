import 'package:flutter/material.dart';
import '../controllers/deck_controller.dart';
import '../controllers/collection_controller.dart';
import '../simulator/cosmetics_catalog.dart';
import '../simulator/card_catalog.dart';
import '../utils/cosmetic_helpers.dart';
import '../widgets/colection_item_widget.dart';
import '../widgets/locked_card_widget.dart';
import '../widgets/card_widget.dart';

enum ColecaoState { home, detalhePersonalizavel, detalhePacote }

class ColecaoView extends StatefulWidget {
  final DeckController deckController;
  final CollectionController colController;

  const ColecaoView({
    super.key,
    required this.deckController,
    required this.colController,
  });

  @override
  State<ColecaoView> createState() => _ColecaoViewState();
}

class _ColecaoViewState extends State<ColecaoView> {
  ColecaoState _colecaoState = ColecaoState.home;
  String _detalheTitulo = '';
  String _categoriaAtual = '';

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
                  bordaEquipadaId: widget.colController.bordaEquipada,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _abrirDetalhe(ColecaoState novoEstado, String titulo, [String categoria = '']) {
    setState(() {
      _colecaoState = novoEstado;
      _detalheTitulo = titulo;
      _categoriaAtual = categoria;
    });
  }

  List<dynamic> _obterCartasDaColecao(String pacote) {
    List<dynamic> todasDoCatalogo = CardCatalog.getAllCards();
    return todasDoCatalogo.where((carta) {
      return carta.pack.toLowerCase() == pacote.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraDisponivel = constraints.maxWidth;

        // 👇 1. CENTRA O CONTEÚDO GLOBAL EM TELAS MAIORES
        return Center(
          child: AnimatedBuilder(
            animation: widget.colController,
            builder: (context, _) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                // 👇 2. LIMITA A LARGURA MÁXIMA PARA O RETÂNGULO NÃO FICAR ESTICADO DEMAIS
                constraints: const BoxConstraints(
                  maxWidth: 600, // Largura ideal para manter o formato de card/box centralizado
                ),
                decoration: BoxDecoration(
                  color: Colors.brown[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown[900]!, width: 4),
                ),
                child: switch (_colecaoState) {
                  ColecaoState.home => _buildColecaoHome(larguraDisponivel),
                  ColecaoState.detalhePersonalizavel => _buildColecaoDetalhe(isCartas: false, largura: larguraDisponivel),
                  ColecaoState.detalhePacote => _buildColecaoDetalhe(isCartas: true, largura: larguraDisponivel),
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildColecaoHome(double largura) {
    final double espacamento = largura > 600 ? 24.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: double.infinity,
          child: Text(
            'Personalizáveis:',
            textAlign: TextAlign.center, // Centraliza o título da seção
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 👇 3. ALINHAMENTO DOS ATALHOS DOS PERSONALIZÁVEIS
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: espacamento,
            runSpacing: espacamento,
            alignment: WrapAlignment.center, // Centraliza os itens na linha horizontal
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ColectionItemWidget(
                titulo: 'Arena',
                icon: Icons.grid_on,
                onTap: () => _abrirDetalhe(ColecaoState.detalhePersonalizavel, 'Arenas:', 'arena'),
              ),
              ColectionItemWidget(
                titulo: 'Borda',
                icon: Icons.crop_square,
                onTap: () => _abrirDetalhe(ColecaoState.detalhePersonalizavel, 'Bordas:', 'borda'),
              ),
              ColectionItemWidget(
                titulo: 'Vida',
                icon: Icons.favorite,
                onTap: () => _abrirDetalhe(ColecaoState.detalhePersonalizavel, 'Ícones de Vida:', 'vida'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const SizedBox(
          width: double.infinity,
          child: Text(
            'Coleções:',
            textAlign: TextAlign.center, // Centraliza o título da seção
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 👇 4. ALINHAMENTO DOS ATALHOS DOS PACOTES/EXPANSÕES
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: espacamento,
            runSpacing: espacamento,
            alignment: WrapAlignment.center, // Centraliza os pacotes horizontalmente
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ColectionItemWidget(
                titulo: 'Savana Africana',
                isPacote: true,
                onTap: () => _abrirDetalhe(ColecaoState.detalhePacote, 'Coleção Savana Africana', 'savana_africana'),
              ),
              ColectionItemWidget(
                titulo: 'Floresta Amazônica',
                isPacote: true,
                onTap: () => _abrirDetalhe(ColecaoState.detalhePacote, 'Coleção Floresta Amazônica', 'floresta_amazonica'),
              ),
              ColectionItemWidget(
                titulo: 'Tundra Polar',
                isPacote: true,
                onTap: () => _abrirDetalhe(ColecaoState.detalhePacote, 'Coleção Tundra Polar', 'tundra_polar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColecaoDetalhe({required bool isCartas, required double largura}) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent, size: 28),
              onPressed: () {
                setState(() {
                  _colecaoState = ColecaoState.home;
                  _categoriaAtual = '';
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
        isCartas ? _buildGridCartasColecao(largura) : _buildGridPersonalizaveis(largura),
      ],
    );
  }

  Widget _buildGridCartasColecao(double largura) {
    final listCartasDoPacote = _obterCartasDaColecao(_categoriaAtual);

    if (listCartasDoPacote.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            "Nenhuma carta registrada para esta coleção.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      );
    }

    int colunas = 3;
    if (largura > 750) {
      colunas = 4;
    } else if (largura < 360) {
      colunas = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listCartasDoPacote.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colunas,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final carta = listCartasDoPacote[index];
        
        bool possuiNaColecao = widget.deckController.playerCards.any((c) => c.id == carta.id) || 
                              widget.deckController.equippedCards.any((c) => c.id == carta.id);

        Widget cardVisual = CardWidget(
          card: carta,
          isFacedown: false,
          bordaEquipadaId: widget.colController.bordaEquipada,
        );

        if (possuiNaColecao) {
          return GestureDetector(
            onTap: () {}, 
            onLongPress: () => _mostrarCartaAmpliada(context, carta), 
            child: cardVisual,
          );
        } else {
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Abra boosters da expansão $_detalheTitulo para liberar o(a) ${carta.name}!'),
                  backgroundColor: const Color(0xFF1B3620),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onLongPress: () => _mostrarCartaAmpliada(context, carta), 
            child: LockedCardWidget(
              cardWidget: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.black54,
                  BlendMode.darken,
                ),
                child: cardVisual,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildGridPersonalizaveis(double largura) {
    String itemEquipadoAtual;
    if (_categoriaAtual == 'arena') {
      itemEquipadoAtual = widget.colController.arenaEquipada;
    } else if (_categoriaAtual == 'borda') {
      itemEquipadoAtual = widget.colController.bordaEquipada;
    } else {
      itemEquipadoAtual = widget.colController.iconeEquipado;
    }

    final List<Map<String, dynamic>> itensDoCatalogo = CosmeticsCatalog.getPorCategoria(_categoriaAtual);

    int colunas = 2;
    double proporcao = 0.85;

    if (largura > 750) {
      colunas = 3;
    }
    if (largura < 350) {
      proporcao = 0.75;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itensDoCatalogo.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colunas, 
        childAspectRatio: proporcao,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final itemData = itensDoCatalogo[index];
        String idItemAtual = itemData['id'];
        String nomeItem = itemData['nome'];
        bool isEquipado = idItemAtual == itemEquipadoAtual;
        bool isBloqueado = itemData['isBloqueadoPadrao'];

        Widget previewVisual = const Icon(Icons.star, size: 40, color: Colors.white);

        if (_categoriaAtual == 'arena') {
          previewVisual = Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: AssetImage(CosmeticHelpers.obterCaminhoArena(idItemAtual)),
                fit: BoxFit.contain,
              ),
            ),
          );
        } else if (_categoriaAtual == 'borda') {
          previewVisual = Container(
            height: 55,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: CosmeticHelpers.obterCorBorda(idItemAtual),
                width: 3.5,
              ),
            ),
            child: const Center(
              child: Icon(Icons.portrait, color: Colors.white30, size: 26),
            ),
          );
        } else if (_categoriaAtual == 'vida') {
          final estiloVida = CosmeticHelpers.obterEstiloVida(idItemAtual);
          previewVisual = Icon(
            estiloVida['icone'],
            color: estiloVida['corAtiva'],
            size: 40,
          );
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.brown[700],
            border: Border.all(color: isEquipado ? Colors.greenAccent : Colors.brown[900]!, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Center(child: previewVisual)), 
              const SizedBox(height: 4),
              Text(
                nomeItem,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                itemData['raridade'],
                style: TextStyle(
                  color: itemData['raridade'] == 'Lendária' 
                      ? Colors.amber 
                      : itemData['raridade'] == 'Épica' 
                          ? Colors.purpleAccent 
                          : Colors.white54,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 4),
              if (!isBloqueado)
                isEquipado
                    ? const Text('EQUIPADO', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 10))
                    : SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: () => widget.colController.equipar(_categoriaAtual, idItemAtual, context),
                          child: const Text('Equipar', style: TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                      ),
            ],
          ),
        );
      },
    );
  }
}