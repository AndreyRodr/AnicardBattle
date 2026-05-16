import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/card_model.dart';
import '../simulator/card_catalog.dart';

class DeckController {
  List<CardModel> equippedCards = [];
  List<CardModel> playerCards = [];

  // Busca os dados iniciais do Firestore
  Future<void> load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final equippedIds = List<int>.from(data['cartasEquipadas'] ?? []);
        final inventoryIds = List<int>.from(data['inventario'] ?? []);

        equippedCards = equippedIds.map((id) => CardCatalog.getById(id)).toList();
        playerCards = inventoryIds.map((id) => CardCatalog.getById(id)).toList();
      }
    } catch (e) {
      print("Erro ao carregar deck do Firestore: $e");
    }
  }

  // 👇 NOVA FUNÇÃO: Move do Inventário para o Deck
  Future<void> equiparCarta(CardModel carta) async {
    if (equippedCards.length >= 9) return; // Trava o limite de 9 cartas!

    playerCards.remove(carta); // Tira da coleção
    equippedCards.add(carta); // Põe no deck

    await _salvarNoFirestore(); // Atualiza a nuvem
  }

  // 👇 NOVA FUNÇÃO: Move do Deck para o Inventário
  Future<void> desequiparCarta(CardModel carta) async {
    equippedCards.remove(carta); // Tira do deck
    playerCards.add(carta); // Volta para a coleção

    await _salvarNoFirestore(); // Atualiza a nuvem
  }

  // 👇 NOVA FUNÇÃO: Pega as listas atuais e joga no banco de dados
  Future<void> _salvarNoFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Transforma os modelos de volta em números (IDs) para salvar leve no banco
    List<int> equippedIds = equippedCards.map((c) => c.id).toList();
    List<int> inventoryIds = playerCards.map((c) => c.id).toList();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'cartasEquipadas': equippedIds,
      'inventario': inventoryIds,
    });
  }
}