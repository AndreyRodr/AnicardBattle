import 'dart:convert';
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
}