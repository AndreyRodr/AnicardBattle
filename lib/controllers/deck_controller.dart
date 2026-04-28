import '../models/card_model.dart';
import '../simulator/deck_datasource.dart';

class DeckController {
  final _datasource = DeckDatasource();

  List<CardModel> playerCards = [];
  List<CardModel> equippedCards = [];

  void equipCard(CardModel card) {

    if (equippedCards.length < 6) {
      equippedCards.add(card);
      playerCards.remove(card);
    }
  }

  void unequipCard(CardModel card) {
    playerCards.add(card);
    equippedCards.remove(card);
  }


  Future<void> load() async {
    final (player, equipped) = await _datasource.loadDeck();

    playerCards = player;
    equippedCards = equipped;
  }
}