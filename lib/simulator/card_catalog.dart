import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/card_model.dart';

class CardCatalog {
  // 🌟 Lista privada que guarda todas as cartas na memória do app
  static List<CardModel> _todasAsCartas = [];

  // ========================================================
  // 1. CARREGAMENTO INICIAL (Lê o JSON e popula a lista)
  // ========================================================
  static Future<void> load() async {
    try {
      // Lê o arquivo JSON da pasta de assets
      final String jsonString = await rootBundle.loadString('assets/data/cards.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      // Pega a lista de cartas dentro do JSON (supondo que a chave principal seja "cards")
      final List<dynamic> cardsList = jsonData['cards'] ?? [];
      
      // Converte o JSON para a nossa classe CardModel e salva na memória
      _todasAsCartas = cardsList.map((c) => CardModel.fromJson(c)).toList();
      
      print("✅ Catálogo carregado com sucesso: ${_todasAsCartas.length} cartas.");
    } catch (e) {
      print("❌ Erro ao carregar o catálogo de cartas: $e");
    }
  }

  // ========================================================
  // 2. RETORNA A LISTA COMPLETA (Usado no DeckView/Álbum)
  // ========================================================
  static List<CardModel> getAllCards() {
    return _todasAsCartas;
  }

  // ========================================================
  // 3. BUSCA UMA CARTA PELO ID (Usado no DeckController)
  // ========================================================
  static CardModel getById(int id) {
    return _todasAsCartas.firstWhere(
      (carta) => carta.id == id,
      // Fallback de segurança: Se o ID não existir no JSON, retorna uma carta vazia genérica
      // Isso evita que o aplicativo feche (crash) caso o banco do Firebase tenha um ID antigo
      orElse: () => CardModel(
        id: -1,
        name: 'Carta Desconhecida',
        imagePath: 'assets/images/cards/default.png',
        pack: 'desconhecido',
        isAlpha: false,
        audioPath: '',
        instintoAssassino: 0,
        forca: 0,
        peso: 0,
        inteligencia: 0,
        agilidade: 0,
        media: 0,
      ),
    );
  }
}