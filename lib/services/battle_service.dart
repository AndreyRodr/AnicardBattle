import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/card_model.dart';

class BattleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CardModel>> buscarCartasEquipadas(String userId) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/cards.json');
      final Map<String, dynamic> jsonDecodificado = jsonDecode(jsonString);
      final List<dynamic> bancoDeCartasLocal = jsonDecodificado['cards'];

      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();

      if (!snapshot.exists) return [];

      final Map<String, dynamic>? dados = snapshot.data() as Map<String, dynamic>?;
      final List<dynamic> idsEquipados = dados?['cartasEquipadas'] ?? [];
      
      List<CardModel> cartasFiltradas = [];
      for (var id in idsEquipados) {
        final mapaCarta = bancoDeCartasLocal.firstWhere(
          (carta) => carta['id'].toString() == id.toString(),
          orElse: () => null,
        );
        if (mapaCarta != null) {
          cartasFiltradas.add(CardModel.fromJson(mapaCarta));
        }
      }
      return cartasFiltradas;
    } catch (e) {
      print('Erro ao carregar deck: $e');
      return [];
    }
  }

  Future<String> buscarUidoOponenteAleatorio(String currentUid) async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').limit(5).get();
      for (var doc in usersSnapshot.docs) {
        if (doc.id != currentUid) return doc.id; 
      }
    } catch (e) {
      print('Erro ao buscar oponente: $e');
    }
    return currentUid;
  }

  Future<Map<String, String>> buscarCosmeticosEquipados(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      
      if (snapshot.exists) {
        final Map<String, dynamic>? dados = snapshot.data() as Map<String, dynamic>?;
        final Map<String, dynamic> cosmeticos = dados?['cosmeticosEquipados'] ?? {};

        return {
          'arena': cosmeticos['arena']?.toString() ?? 'arena_1',
          'bordaCarta': cosmeticos['bordaCarta']?.toString() ?? 'borda_1',
          'iconeVida': cosmeticos['iconeVida']?.toString() ?? 'vida_1',
        };
      }
    } catch (e) {
      print('Erro ao buscar cosméticos na batalha: $e');
    }
    
    // Retorno de segurança (Fallback) caso dê erro
    return {
      'arena': 'arena_1',
      'bordaCarta': 'borda_1',
      'iconeVida': 'vida_1',
    };
  }

  /// 🌟 GERA O DECK TEMÁTICO DE 9 CARTAS PARA O BOT COM NO MÁXIMO 1 ALFA
  Future<List<CardModel>> gerarDeckTematicoBot(String dificuldadeNome) async {
    try {
      // 1. Carrega todas as cartas do catálogo local
      final String jsonString = await rootBundle.loadString('assets/data/cards.json');
      final Map<String, dynamic> jsonDecodificado = jsonDecode(jsonString);
      final List<dynamic> bancoDeCartasLocal = jsonDecodificado['cards'];
      
      List<CardModel> catalogoCompleto = bancoDeCartasLocal.map((c) => CardModel.fromJson(c)).toList();

      // 2. Define o bioma FOCO com base no texto da dificuldade
      String packIdFoco;
      if (dificuldadeNome == 'iniciante') {
        packIdFoco = 'floresta_amazonica';
      } else if (dificuldadeNome == 'dificil') {
        packIdFoco = 'tundra_polar';
      } else {
        packIdFoco = 'savana_africana';
      }

      // 3. Separa as cartas do bioma FOCO e as dos OUTROS biomas
      List<CardModel> cartasDoBiomaFoco = catalogoCompleto.where((carta) => carta.pack == packIdFoco).toList();
      List<CardModel> cartasDosOutrosBiomas = catalogoCompleto.where((carta) => carta.pack != packIdFoco).toList();

      List<CardModel> deckFinalDoBot = [];
      bool jaPossuiAlfa = false; // 🐺 Controle estrito de Alfa único

      // 4. Adiciona as cartas do bioma foco respeitando o limite de Alfas
      cartasDoBiomaFoco.shuffle();
      for (var carta in cartasDoBiomaFoco) {
        if (deckFinalDoBot.length >= 9) break;

        // Se for Alfa (Substitua '.isAlfa' pela propriedade real do seu CardModel)
        if (carta.isAlpha) {
          if (!jaPossuiAlfa) {
            deckFinalDoBot.add(carta);
            jaPossuiAlfa = true; // Bloqueia novos Alfas
          }
          // Se já possuir Alfa, simplesmente ignora esta carta por enquanto
        } else {
          deckFinalDoBot.add(carta);
        }
      }

      // 5. COMPLETA COM OUTROS BIOMAS (Se o foco não tiver 9 cartas)
      if (deckFinalDoBot.length < 9) {
        cartasDosOutrosBiomas.shuffle();
        
        while (deckFinalDoBot.length < 9 && cartasDosOutrosBiomas.isNotEmpty) {
          final cartaReserva = cartasDosOutrosBiomas.removeAt(0);
          
          if (cartaReserva.isAlpha) {
            if (!jaPossuiAlfa) {
              deckFinalDoBot.add(cartaReserva);
              jaPossuiAlfa = true;
            }
          } else {
            deckFinalDoBot.add(cartaReserva);
          }
        }
      }

      // 6. Salvaguarda extrema de preenchimento (se faltar cartas comuns para fechar 9)
      if (deckFinalDoBot.length < 9) {
        // Puxa apenas as cartas comuns (não-alfa) já presentes no deck para clonar sem quebrar a regra
        List<CardModel> apenasComunsNoDeck = deckFinalDoBot.where((c) => !c.isAlpha).toList();
        final random = Random();
        
        while (deckFinalDoBot.length < 9 && apenasComunsNoDeck.isNotEmpty) {
          deckFinalDoBot.add(apenasComunsNoDeck[random.nextInt(apenasComunsNoDeck.length)]);
        }
      }

      // Embaralha o deck final para que a distribuição de rounds seja justa
      deckFinalDoBot.shuffle();
      return deckFinalDoBot;

    } catch (e) {
      print('Erro ao gerar deck temático com Alfa Único para o bot: $e');
      return [];
    }
  }
}