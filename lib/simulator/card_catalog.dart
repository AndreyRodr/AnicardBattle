// simula o banco de dados
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/card_model.dart';

class CardCatalog {
  static final Map<int, CardModel> _cards = {};

  static Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/data/cards.json');
    
    final data = json.decode(jsonString);

    for (var item in data['cards']) {
      final card = CardModel.fromJson(item);
      _cards[card.id] = card;
    }
  }

  static CardModel getById(int id) {
    final card = _cards[id];
    if (card == null) { 
      throw Exception('Carta não encontrada: $id');
    }
    return card;
  }
}