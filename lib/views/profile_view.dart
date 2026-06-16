import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const List<Map<String, String>> _availableAvatars = [
    {'id': 'onca', 'name': 'Onça-Pintada', 'path': 'assets/images/cards/leao.png'},
    {'id': 'leao', 'name': 'Leão da Savana', 'path': 'assets/images/cards/onca-pintada.png'},
    {'id': 'urso', 'name': 'Urso Polar', 'path': 'assets/images/cards/urso-polar.png'},
    {'id': 'logo', 'name': 'AniCard Logo', 'path': 'assets/images/AniCard Icon.png'},
  ];

  void _mostrarSelecaoDeAvatar(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF351F14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Escolha seu Avatar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85, 
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20.0,    
              runSpacing: 24.0, 
              children: _availableAvatars.map((avatar) {
                return GestureDetector(
                  onTap: () async {
                    await FirebaseFirestore.instance.collection('users').doc(uid).update({
                      'avatarIcon': avatar['path'],
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 90, 
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80, 
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber, width: 2.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black38, blurRadius: 4, offset: const Offset(0, 3))
                            ],
                            image: DecorationImage(
                              image: AssetImage(avatar['path']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          avatar['name']!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoAlterarPerfil(BuildContext context, String uid, String nomeAtual) {
    final TextEditingController nameController = TextEditingController(text: nomeAtual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF351F14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Alterar Nome de Usuário',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.amber,
            decoration: const InputDecoration(
              labelText: 'Novo apelido',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF082611)),
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'nomeUsuario': nameController.text.trim(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil updated com sucesso!'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('SALVAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }

        String nomeUsuario = "Jogador";
        String email = user.email ?? "sem@email.com";
        String avatarAtual = 'assets/images/AniCard Icon.png';

        if (snapshot.hasData && snapshot.data!.exists) {
          final dadosDoBanco = snapshot.data!.data() as Map<String, dynamic>;
          nomeUsuario = dadosDoBanco['nomeUsuario'] ?? "Jogador";
          email = dadosDoBanco['email'] ?? email;
          avatarAtual = dadosDoBanco['avatarIcon'] ?? avatarAtual;
        }

        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              // Injetado padding vertical equilibrado para a rolagem respirar limpa
              padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 24.0),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  
                  // 🌟 QUADRADO MARROM: Reajustado para subir e ocupar mais altura simétrica na tela
                  Container(
                    width: 340,
                    // Removido o margin top excessivo que afundava o painel para baixo
                    padding: const EdgeInsets.only(top: 88, bottom: 40, left: 24, right: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF351F14),
                      borderRadius: BorderRadius.circular(16), // Bordas ligeiramente mais arredondadas (estilo card)
                      border: Border.all(color: const Color(0x33FFFFFF), width: 1.5), // Leve borda interna para destaque
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo Usuário
                        const Text(
                          'Usuário:',
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            nomeUsuario,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Campo Email
                        const Text(
                          'Email:',
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            email,
                            style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(height: 48), // Aumentado espaçamento pré-botões para alongar o card verticalmente

                        // Botão Alterar Perfil
                        ElevatedButton.icon(
                          onPressed: () => _mostrarDialogoAlterarPerfil(context, user.uid, nomeUsuario),
                          icon: const Icon(Icons.person, size: 18),
                          label: const Text('Alterar Perfil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF082611),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Botão Sair da Conta
                        ElevatedButton.icon(
                          onPressed: () async {
                            await authService.deslogar();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Sair da conta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF522121),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🌟 AVATAR POSICIONADO: Utiliza margem negativa para flutuar metade para fora do topo do container
                  Positioned(
                    top: -64, // Sobe exatamente metade da altura do círculo de 128px
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF522121),
                            border: Border.all(color: const Color(0xFF351F14), width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              )
                            ],
                            image: DecorationImage(
                              image: AssetImage(avatarAtual),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _mostrarSelecaoDeAvatar(context, user.uid),
                            child: Container(
                              height: 38,
                              width: 36,
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}