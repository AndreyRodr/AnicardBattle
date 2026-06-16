import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Atualiza o cosmético equipado do usuário usando dot notation para segurança
  Future<void> atualizarCosmeticoEquipado({
    required String userId,
    required String categoria,
    required String itemId,
  }) async {
    try {
      // Mapeia o identificador da UI para a chave exata criada no banco
      String chaveMap;
      if (categoria == 'arena') {
        chaveMap = 'arena';
      } else if (categoria == 'borda') {
        chaveMap = 'borda';
      } else {
        chaveMap = 'iconeVida';
      }

      // Atualiza apenas a chave específica dentro do mapa 'cosmeticosEquipados'
      await _firestore.collection('users').doc(userId).set({
        'cosmeticosEquipados': {
          chaveMap: itemId,
        }
      }, SetOptions(merge: true));
      
      print('Cosmético [$itemId] salvo com sucesso no Firestore.');
    } catch (e) {
      print('Erro ao atualizar cosmético no Firestore: $e');
      rethrow; // Repassa o erro para a UI tratar se necessário
    }
  }
}