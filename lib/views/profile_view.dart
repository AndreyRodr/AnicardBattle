import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👇 Adicionado para buscar do banco
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  bool _isLoading = true;
  String _nomeUsuario = 'Carregando...';
  String _emailUsuario = '';

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  // 👇 1. Método para buscar os dados reais do Firestore
  Future<void> _carregarPerfil() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('User').doc(_currentUser.uid).get();
        if (doc.exists) {
          setState(() {
            _nomeUsuario = doc['username'] ?? 'Sem Nome';
            _emailUsuario = doc['email'] ?? _currentUser.email ?? 'Sem email';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _nomeUsuario = 'Erro ao carregar';
          _isLoading = false;
        });
      }
    }
  }

  // 👇 2. Método para abrir o modal de edição
  void _mostrarDialogoEdicao() {
    final TextEditingController nomeController = TextEditingController(text: _nomeUsuario);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF351F14), // Mantém o tema marrom
          title: const Text(
            'Alterar Nome',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nomeController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Novo nome de usuário',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orangeAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF082611), // Verde escuro
              ),
              onPressed: () async {
                if (nomeController.text.trim().isNotEmpty) {
                  // Fecha o pop-up
                  Navigator.pop(context);
                  
                  // Mostra loading na tela
                  setState(() => _isLoading = true);

                  try {
                    // Chama o serviço de atualização que criamos anteriormente
                    await _authService.atualizarPerfil(
                      uid: _currentUser!.uid,
                      novoUsername: nomeController.text.trim(),
                    );
                    
                    // Recarrega os dados para atualizar a interface
                    await _carregarPerfil();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
                      );
                    }
                  } catch (e) {
                    setState(() => _isLoading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.black.withOpacity(0.3), // Ajustado .withOpacity() compatível
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
              : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botão Alterar Ícone
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implementar lógica de trocar avatarUrl futuramente
                    },
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
                    _nomeUsuario, // 👇 Nome dinâmico vindo do estado local
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
                    _emailUsuario, // 👇 Email dinâmico vindo do estado local
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
                    // 👇 CHAMA A FUNÇÃO CRIADA ACIMA
                    onPressed: _mostrarDialogoEdicao,
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
                      await _authService.deslogar();
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

          // A Logo Redonda
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
                    color: Colors.black.withOpacity(0.4),
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
  }
}