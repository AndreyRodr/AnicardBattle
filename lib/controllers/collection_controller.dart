import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/collection_service.dart';

class CollectionController extends ChangeNotifier {
  final CollectionService _service = CollectionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🌟 CORREÇÃO: Usar um getter garante que o UID sempre reflita o estado real da sessão
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Valores iniciais de segurança (caso o banco falhe ou a conta seja nova)
  String arenaEquipada = 'arena_padrao';
  String bordaEquipada = 'borda_padrao';
  String iconeEquipado = 'vida_padrao';

  /// Busca os cosméticos salvos no Firestore e atualiza o estado da tela
  Future<void> carregarCosmeticos() async {
    if (_uid == null) return;

    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(_uid).get();

      if (snapshot.exists && snapshot.data() != null) {
        final dados = snapshot.data() as Map<String, dynamic>;
        
        if (dados.containsKey('cosmeticosEquipados')) {
          final cosmeticos = dados['cosmeticosEquipados'] as Map<String, dynamic>;

          arenaEquipada = cosmeticos['arena']?.toString() ?? 'arena_padrao';
          bordaEquipada = cosmeticos['bordaCarta']?.toString() ?? 'borda_padrao';
          iconeEquipado = cosmeticos['iconeVida']?.toString() ?? 'vida_padrao';
          
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar cosméticos do banco: $e');
    }
  }

  Future<void> equipar(String categoria, String itemId, BuildContext context) async {
    if (_uid == null) return;
    
    // Atualiza a memória local instantaneamente para resposta rápida da UI
    if (categoria == 'arena') {
      arenaEquipada = itemId;
    } else if (categoria == 'borda') {
      bordaEquipada = itemId;
    } else if (categoria == 'vida') {
      iconeEquipado = itemId;
    }
    
    notifyListeners();

    try {
      // Sincroniza com o backend
      await _service.atualizarCosmeticoEquipado(
        userId: _uid!,
        categoria: categoria,
        itemId: itemId,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visual equipado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar alteração no servidor.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}