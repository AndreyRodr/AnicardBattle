import 'package:cloud_firestore/cloud_firestore.dart';

/// Mantém somente as informações que outros jogadores precisam consultar.
/// Dados particulares (moedas, inventário, missões etc.) permanecem em users/{uid}.
class PublicProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Map<String, dynamic> fromPrivateData(Map<String, dynamic> data) {
    final nome = data['nomeUsuario'];
    final trofeus = data['trofeus'];
    final avatar = data['avatarIcon'];
    final cartas = data['cartasEquipadas'];
    final cosmeticos = data['cosmeticosEquipados'];

    return {
      'nomeUsuario': nome is String && nome.trim().isNotEmpty
          ? nome
          : 'Jogador',
      'trofeus': trofeus is int ? trofeus : 0,
      'avatarIcon': avatar is String
          ? avatar
          : 'assets/images/AniCard Icon.png',
      'cartasEquipadas': cartas is List ? cartas : <int>[],
      'cosmeticosEquipados': cosmeticos is Map
          ? Map<String, dynamic>.from(cosmeticos)
          : <String, dynamic>{},
    };
  }

  /// Auto-migração para a própria conta (inclusive sessões já autenticadas).
  /// O script administrativo migra também os jogadores que ainda não entraram.
  Future<void> ensureForCurrentUser(String uid) async {
    final profileRef = _firestore.collection('publicProfiles').doc(uid);
    final profile = await profileRef.get();
    if (profile.exists) return;

    final privateDoc = await _firestore.collection('users').doc(uid).get();
    if (!privateDoc.exists || privateDoc.data() == null) {
      throw StateError('Dados da conta não encontrados.');
    }
    await profileRef.set(fromPrivateData(privateDoc.data()!),
        SetOptions(merge: true));
  }
}
