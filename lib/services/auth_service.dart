import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Função para Criar Conta (Registro)
  Future<String?> registrarUsuario({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Retorna nulo se deu tudo certo!
    } on FirebaseAuthException catch (e) {
      // Traduzindo os erros mais comuns do Firebase para o usuário
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