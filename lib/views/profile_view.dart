import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importante para ler o banco
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Pega o usuário logado para sabermos o UID dele
    final user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();

    // Se por algum motivo não houver usuário logado, mostra um carregamento
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Usamos o FutureBuilder para buscar o documento do usuário no Firestore
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        // Enquanto os dados estão vindo da nuvem...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }

        // Se houver falha ou o documento não existir, definimos valores padrão
        String nomeUsuario = "Jogador";
        String email = user.email ?? "sem@email.com";

        if (snapshot.hasData && snapshot.data!.exists) {
          final dadosDoBanco = snapshot.data!.data() as Map<String, dynamic>;
          nomeUsuario = dadosDoBanco['nomeUsuario'] ?? "Jogador";
          email = dadosDoBanco['email'] ?? email;
          // Se quiser usar as moedas aqui no futuro: int moedas = dadosDoBanco['moedas'] ?? 0;
        }

        // 3. O seu layout original com os dados REAIS do banco de dados
        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              
              // O Card Marrom Escuro
              Container(
                width: 300,
                margin: const EdgeInsets.only(top: 64), 
                padding: const EdgeInsets.only(top: 80, bottom: 32, left: 32, right: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF351F14), 
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botão Alterar Ícone
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF082611), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Alterar icone',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Texto Usuário
                    const Text(
                      'Usuário:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                      child: Text(
                        nomeUsuario, // 👈 Agora vem do Firestore!
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Texto Email
                    const Text(
                      'Email:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                      child: Text(
                        email, // 👈 Agora vem do Firestore!
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botão Alterar Perfil
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF082611),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Alterar Perfil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botão Sair da Conta
                    Center(
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF522121),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Sair da conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // A Logo Redonda (Posicionada no topo)
              Positioned(
                top: 0,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF522121),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/AniCard Icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}