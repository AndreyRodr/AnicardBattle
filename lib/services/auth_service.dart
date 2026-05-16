import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- NOVO: Pacote do Firestore

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // <-- NOVO: Instância do banco

  // 1. Função para Criar Conta (Agora recebe o nome de usuário também!)
  Future<String?> registrarUsuario({
    required String nomeUsuario, 
    required String email, 
    required String password
  }) async {
    try {
      // Cria a conta no Firebase Auth (Login e Senha)
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Pega o ID único (UID) do usuário que acabou de ser criado
      String uid = credencial.user!.uid;

      // 👇 A MÁGICA DO FIRESTORE ACONTECE AQUI 👇
      // Cria um documento na coleção 'users' com o exato UID do jogador
      await _firestore.collection('users').doc(uid).set({
        'nomeUsuario': nomeUsuario.trim(),
        'email': email.trim(),
        'moedas': 1000,
        
        // Vamos dar 3 cartas iniciais para o jogador (usando os IDs do seu cards.json)
        // Você pode mudar esses números para os IDs das cartas "padrão" do seu jogo
        'cartasEquipadas': [1], 
        'inventario': [1],
        
        'criadoEm': FieldValue.serverTimestamp(), // Salva a data e hora do registro
      });

      return null; // Retorna nulo se deu tudo certo!
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        return 'Já existe uma conta com este e-mail.';
      } else if (e.code == 'invalid-email') {
        return 'O formato do e-mail é inválido.';
      }
      return 'Erro ao criar conta: ${e.message}';
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  // 2. Função para Entrar (Login)
  Future<String?> loginUsuario({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Sucesso!
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'E-mail ou senha incorretos.';
      }
      return 'Erro ao fazer login: ${e.message}';
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  // 3. Função para Deslogar
  Future<void> deslogar() async {
    await _auth.signOut();
  }
}