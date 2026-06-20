import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingDialog extends StatelessWidget {
  const RankingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        height: 450, 
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF351F14), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'RANKING GLOBAL',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E5E35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),

            // Lista dinâmica vinda do Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar o ranking.',
                        style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 13),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.amber));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Nenhum duelista encontrado.', style: TextStyle(color: Colors.white60)),
                    );
                  }

                  List<DocumentSnapshot> listaFiltrada = List.from(snapshot.data!.docs);
                  listaFiltrada.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    
                    final int trofeusA = dataA['trofeus'] ?? 0;
                    final int trofeusB = dataB['trofeus'] ?? 0;

                    int comparacaoTrofeus = trofeusB.compareTo(trofeusA);
                    if (comparacaoTrofeus == 0) {
                      return a.id.compareTo(b.id);
                    }
                    return comparacaoTrofeus;
                  });

                  return ListView.builder(
                    itemCount: listaFiltrada.length,
                    itemBuilder: (context, index) {
                      final data = listaFiltrada[index].data() as Map<String, dynamic>;
                      
                      // 🌟 MAPEAMENTO CORRIGIDO: Puxa o apelido do banco usando a chave correta
                      final String name = data['nomeUsuario'] ?? 'Jogador';
                      final int trofeus = data['trofeus'] ?? 0;
                      
                      // 🌟 AVATAR CORRIGIDO: Lê a string do caminho local e define um fallback padrão limpo
                      final String avatarLocalPath = data['avatarIcon'] ?? 'assets/images/AniCard Icon.png';

                      Color corPosicao = Colors.white70;
                      double tamanhoFonte = 14;
                      if (index == 0) { corPosicao = Colors.amber; tamanhoFonte = 18; }
                      else if (index == 1) { corPosicao = const Color(0xFFC0C0C0); tamanhoFonte = 16; }
                      else if (index == 2) { corPosicao = const Color(0xFFCD7F32); tamanhoFonte = 15; }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: index == 0 
                              ? Colors.amber.withOpacity(0.08) 
                              : Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: index < 3 
                              ? Border.all(color: corPosicao.withOpacity(0.3), width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                '${index + 1}º',
                                style: TextStyle(
                                  color: corPosicao,
                                  fontSize: tamanhoFonte,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // 🌟 EXIBIÇÃO DO AVATAR CORRIGIDA: Usa o AssetImage para ler do armazenamento local do app
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF522121),
                                border: Border.all(color: const Color(0xFF351F14), width: 1),
                                image: DecorationImage(
                                  image: AssetImage(avatarLocalPath),
                                  fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      debugPrint("Erro ao carregar o asset do avatar: $exception");
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$trofeus',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}