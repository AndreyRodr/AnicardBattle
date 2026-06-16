import 'package:flutter/material.dart';
import '../controllers/deck_controller.dart';
import '../controllers/collection_controller.dart';
import '../simulator/cosmetics_catalog.dart';
import '../utils/cosmetic_helpers.dart';
import '../widgets/colection_item_widget.dart';
import '../widgets/locked_card_widget.dart';
import '../widgets/card_grid_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.colController,
      builder: (context, _) {
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
        isCartas
            ? CardGridWidget(
                cards: widget.deckController.playerCards,
                bordaEquipadaId: widget.colController.bordaEquipada,
                onCardLongPress: (carta) => _mostrarCartaAmpliada(context, carta),
              )
            : _buildGridPersonalizaveis(),
      ],
    );
  }

  Widget _buildGridPersonalizaveis() {
    String itemEquipadoAtual;
    if (_categoriaAtual == 'arena') {
      itemEquipadoAtual = widget.colController.arenaEquipada;
    } else if (_categoriaAtual == 'borda') {
      itemEquipadoAtual = widget.colController.bordaEquipada;
    } else {
      itemEquipadoAtual = widget.colController.iconeEquipado;
    }

    // 👇 BUSCA OS ITENS DIRETAMENTE DO CATALOGO JSON
    final List<Map<String, dynamic>> itensDoCatalogo = CosmeticsCatalog.getPorCategoria(_categoriaAtual);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itensDoCatalogo.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Reduzido para 2 por linha para dar mais espaço ao preview visual
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final itemData = itensDoCatalogo[index];
        String idItemAtual = itemData['id'];
        String nomeItem = itemData['nome'];
        bool isEquipado = idItemAtual == itemEquipadoAtual;
        bool isBloqueado = itemData['isBloqueadoPadrao']; // Usa a regra do JSON

        // --- CONSTRUÇÃO DO PREVIEW VISUAL CONFORME A CATEGORIA ---
        Widget previewVisual = const Icon(Icons.star, size: 40, color: Colors.white);

        if (_categoriaAtual == 'arena') {
          previewVisual = Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: AssetImage(CosmeticHelpers.obterCaminhoArena(idItemAtual)),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else if (_categoriaAtual == 'borda') {
          previewVisual = Container(
            height: 60,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: CosmeticHelpers.obterCorBorda(idItemAtual),
                width: 4,
              ),
            ),
            child: const Center(
              child: Icon(Icons.portrait, color: Colors.white30, size: 30),
            ),
          );
        } else if (_categoriaAtual == 'vida') {
          final estiloVida = CosmeticHelpers.obterEstiloVida(idItemAtual);
          previewVisual = Icon(
            estiloVida['icone'],
            color: estiloVida['corAtiva'],
            size: 45,
          );
        }

        Widget conteudoItem = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Expanded(child: Center(child: previewVisual)), // Mostra o preview dinâmico
            const SizedBox(height: 8),
            Text(
              nomeItem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              itemData['raridade'],
              style: TextStyle(
                color: itemData['raridade'] == 'Lendária' 
                    ? Colors.amber 
                    : itemData['raridade'] == 'Épica' 
                        ? Colors.purpleAccent 
                        : Colors.white54,
                fontSize: 10,
              ),
            ),
            const Spacer(),
            if (!isBloqueado)
              isEquipado
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text('EQUIPADO', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 28),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () => widget.colController.equipar(_categoriaAtual, idItemAtual, context),
                      child: const Text('Equipar', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ),
          ],
        );

        Widget cardBase = Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.brown[700],
            border: Border.all(color: isEquipado ? Colors.greenAccent : Colors.brown[900]!, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: conteudoItem,
        );

        return isBloqueado ? LockedCardWidget(cardWidget: cardBase) : cardBase;
      },
    );
  }
}