import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pool de Missões Diárias
  final List<Map<String, dynamic>> _diariasPool = [
    {'id': 'd_facil', 'titulo': 'Derrote o nível Iniciante!', 'meta': 1, 'premioMoedas': 30},
    {'id': 'd_inter', 'titulo': 'Derrote o nível Intermediário!', 'meta': 1, 'premioMoedas': 60},
    {'id': 'd_dificil', 'titulo': 'Derrote o nível Estrategista!', 'meta': 1, 'premioMoedas': 100},
    {'id': 'd_packs_2', 'titulo': 'Abra pacotes de cartas', 'meta': 2, 'premioMoedas': 40},
    {'id': 'd_packs_5', 'titulo': 'Abra pacotes de cartas', 'meta': 5, 'premioMoedas': 80},
    {'id': 'd_jogar_3', 'titulo': 'Jogue 3 partidas quaisquer', 'meta': 3, 'premioMoedas': 45},
  ];

  // Pool de Missões Semanais
  final List<Map<String, dynamic>> _semanaisPool = [
    {'id': 's_dificil_5', 'titulo': 'Derrote o nível Estrategista 5x', 'meta': 5, 'premioMoedas': 300},
    {'id': 's_inter_8', 'titulo': 'Derrote o nível Intermediário 8x', 'meta': 8, 'premioMoedas': 250},
    {'id': 's_packs_10', 'titulo': 'Abra 10 pacotes nesta semana', 'meta': 10, 'premioMoedas': 200},
    {'id': 's_trofeus_100', 'titulo': 'Acumule +100 Troféus', 'meta': 100, 'premioMoedas': 400},
    {'id': 's_vitorias_10', 'titulo': 'Vença 10 partidas no total', 'meta': 10, 'premioMoedas': 300},
  ];

  /// 🌟 VERIFICAÇÃO COM CONTROLE DE TEMPO ABSOLUTO (24h / 168h)
  Future<void> verificarEGerarMissoes(String uid) async {
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final dados = snapshot.data() as Map<String, dynamic>;
    final int agoraMs = DateTime.now().millisecondsSinceEpoch;

    // Constantes de validação de tempo
    const int vinteQuatroHorasMs = 24 * 60 * 60 * 1000;  // 86.400.000 ms
    const int centoSessentaEOitoHorasMs = 168 * 60 * 60 * 1000; // 604.800.000 ms

    // Recupera timestamps salvos no banco (retorna 0 caso seja a primeira vez)
    final int ultimaGeracaoDiaria = dados['ultimaGeracaoDiariaMs'] ?? 0;
    final int ultimaGeracaoSemanal = dados['ultimaGeracaoSemanalMs'] ?? 0;

    Map<String, dynamic> updates = {};
    final random = Random();

    // 🕒 1. VALIDAÇÃO DIÁRIA: Só altera se passou 24h OU se as missões vierem vazias
    if (agoraMs - ultimaGeracaoDiaria >= vinteQuatroHorasMs || dados['missoesDiarias'] == null) {
      List<Map<String, dynamic>> sorteadas = [];
      List<Map<String, dynamic>> copiaPool = List.from(_diariasPool);
      
      int qtdParaSortear = min(3, copiaPool.length);
      for (int i = 0; i < qtdParaSortear; i++) {
        final indice = random.nextInt(copiaPool.length);
        final missao = copiaPool.removeAt(indice);
        sorteadas.add({
          'id': missao['id'],
          'titulo': missao['titulo'],
          'progresso': 0,
          'meta': missao['meta'],
          'premioMoedas': missao['premioMoedas'],
          'coletado': false,
        });
      }
      updates['missoesDiarias'] = sorteadas;
      updates['ultimaGeracaoDiariaMs'] = agoraMs; // Salva o marco de tempo atual
    }

    // 🕒 2. VALIDAÇÃO SEMANAl: Só altera se passou 168h (7 dias) OU se vier vazio
    if (agoraMs - ultimaGeracaoSemanal >= centoSessentaEOitoHorasMs || dados['missoesSemanais'] == null) {
      List<Map<String, dynamic>> sorteadas = [];
      List<Map<String, dynamic>> copiaPool = List.from(_semanaisPool);

      int qtdParaSortear = min(2, copiaPool.length);
      for (int i = 0; i < qtdParaSortear; i++) {
        final indice = random.nextInt(copiaPool.length);
        final missao = copiaPool.removeAt(indice);
        sorteadas.add({
          'id': missao['id'],
          'titulo': missao['titulo'],
          'progresso': 0,
          'meta': missao['meta'],
          'premioMoedas': missao['premioMoedas'],
          'coletado': false,
        });
      }
      updates['missoesSemanais'] = sorteadas;
      updates['ultimaGeracaoSemanalMs'] = agoraMs; // Salva o marco de tempo atual
    }

    if (updates.isNotEmpty) {
      await docRef.update(updates);
    }
  }

  /// ATUALIZA PROGRESSO DAS MISSÕES ATIVAS
  Future<void> atualizarProgressoMissao({
    required String uid,
    required String acaoId,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);

    try {
      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(docRef);
        if (!snap.exists) return;

        final dados = snap.data() as Map<String, dynamic>;
        
        List<dynamic> diarias = List.from(dados['missoesDiarias'] ?? []);
        for (var m in diarias) {
          if (m['id'].toString().contains(acaoId) && m['coletado'] == false) {
            int novoProgresso = (m['progresso'] ?? 0) + 1;
            m['progresso'] = novoProgresso.clamp(0, m['meta']);
          }
        }

        List<dynamic> semanais = List.from(dados['missoesSemanais'] ?? []);
        for (var m in semanais) {
          if (m['id'].toString().contains(acaoId) && m['coletado'] == false) {
            int novoProgresso = (m['progresso'] ?? 0) + 1;
            m['progresso'] = novoProgresso.clamp(0, m['meta']);
          }
        }

        transaction.update(docRef, {
          'missoesDiarias': diarias,
          'missoesSemanais': semanais,
        });
      });
    } catch (e) {
      print("Erro ao atualizar progresso: $e");
    }
  }

  /// COLETA RECOMPENSA DE UMA MISSÃO COMPLETA
  Future<void> coletarPremioMissao({
    required String uid,
    required String idMissao,
    required bool ehSemanal,
    required int moedasPremio,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      if (!snap.exists) return;

      final dados = snap.data() as Map<String, dynamic>;
      int moedasAtuais = dados['moedas'] ?? 0;
      
      String campoLista = ehSemanal ? 'missoesSemanais' : 'missoesDiarias';
      List<dynamic> lista = List.from(dados[campoLista] ?? []);

      for (var i = 0; i < lista.length; i++) {
        if (lista[i]['id'] == idMissao) {
          lista[i]['coletado'] = true;
          moedasAtuais += moedasPremio;
          break;
        }
      }

      transaction.update(docRef, {
        'moedas': moedasAtuais,
        campoLista: lista,
      });
    });
  }
}