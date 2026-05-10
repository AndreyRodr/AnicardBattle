import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para Criar Conta (Registro)
  Future<String?> registrarUsuario({
      required String email, 
      required String password,
      required String username,
    }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? novoUsuario = credential.user;

      if (novoUsuario != null) {
        try {
          UserModel novoJogador = UserModel(
            id: novoUsuario.uid,
            username: username,
            email: email.trim(),
            createdAt: DateTime.now(),
          );

          await _firestore
            .collection("User")
            .doc(novoJogador.id)
            .set(novoJogador.toMap());

          print('Jogador registrado com sucesso');
        } catch (e) {
          print('ERRO AO GRAVAR NO FIRESTORE: $e');
          //rollback
          await novoUsuario.delete();
          throw Exception('Erro ao salvar dados no banco. Tente registrar novamente.');
        }
      }
      return null; // Retorna nulo se deu tudo certo
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

  // Função para Entrar (Login)
  Future<String?> loginUsuario({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          return 'E-mail ou senha incorretos.';
        }
        return 'Erro ao fazer login: ${e.message}';
    } catch (e) {
        return 'Erro desconhecido: $e';
    }
  }

  // Função para Deslogar
  Future<void> deslogar() async {
    await _auth.signOut();
  }
}