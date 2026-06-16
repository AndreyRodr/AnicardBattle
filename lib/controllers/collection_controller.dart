import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/collection_service.dart';

class CollectionController extends ChangeNotifier {
  final CollectionService _service = CollectionService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        
        // Verifica se o mapa de cosméticos existe no documento
        if (dados.containsKey('cosmeticosEquipados')) {
          final cosmeticos = dados['cosmeticosEquipados'] as Map<String, dynamic>;

          // Atualiza as variáveis com o que veio do banco de dados
          arenaEquipada = cosmeticos['arena']?.toString() ?? 'arena_padrao';
          bordaEquipada = cosmeticos['bordaCarta']?.toString() ?? 'borda_padrao';
          iconeEquipado = cosmeticos['iconeVida']?.toString() ?? 'vida_padrao';
          
          // Notifica a interface para se redesenhar com os visuais corretos
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erro ao carregar cosméticos do banco: $e');
    }
  }

  Future<void> equipar(String categoria, String itemId, BuildContext context) async {
    if (_uid == null) return;
    
    if (categoria == 'arena') {
      arenaEquipada = itemId;
    } else if (categoria == 'borda') {
      bordaEquipada = itemId;
    } else if (categoria == 'vida') {
      iconeEquipado = itemId;
    }
    
    notifyListeners();

    try {
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