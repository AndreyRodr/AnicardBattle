//Simula o save do jogador
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/card_model.dart';
import 'card_catalog.dart';

class DeckDatasource {
  Future<(List<CardModel>, List<CardModel>)> loadDeck() async {
    final jsonString = await rootBundle.loadString('assets/data/player_deck.json');
    final data = json.decode(jsonString);

    final playerCards = (data['playerCards'] as List)
      .map((id) => CardCatalog.getById(id))
      .toList();

      final equippedCards = (data['equippedCards'] as List)
        .map((id) => CardCatalog.getById(id))
        .toList();

      return (playerCards, equippedCards);
  }
}