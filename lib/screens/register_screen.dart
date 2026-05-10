import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart';
import '../services/auth_service.dart'; // Importando o serviço que criamos
import 'home_screen.dart'; // Importando a tela principal para redirecionar

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para pegar os textos digitados
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false; // Controle da bolinha de carregamento

  // Função disparada ao clicar no botão
  void _fazerRegistro() async {
    // 1. Validação básica de senhas
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem!'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Inicia o carregamento
    setState(() {
      _isLoading = true;
    });

    // 3. Chama o Firebase
    String? erro = await _authService.registrarUsuario(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    );

    // 4. Termina o carregamento e verifica o resultado
    setState(() {
      _isLoading = false;
    });

    if (erro == null) {
      // Sucesso! Vai para a tela do jogo e impede de voltar para o registro
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AniCardScreen()),
          (route) => false,
        );
      }
    } else {
      // Erro! Mostra mensagem para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    // Limpa os controladores da memória ao fechar a tela
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF326437),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo do App
                        Image.asset(
                          'assets/images/AniCard Icon.png', 
                          width: 240,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),

                        // Card de Registro
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0, bottom: 40.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B9D5F),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'REGISTRO',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Passando os controladores para o CustomInputField
                                CustomInputField(
                                  label: 'Nome de usuário:',
                                  controller: _usernameController,
                                ),
                                const SizedBox(height: 20),

                                CustomInputField(
                                  label: 'Email:',
                                  controller: _emailController,
                                ),
                                const SizedBox(height: 20),

                                CustomInputField(
                                  label: 'Senha:',
                                  obscureText: true,
                                  controller: _passwordController,
                                ),
                                const SizedBox(height: 20),

                                CustomInputField(
                                  label: 'Confirmar Senha:',
                                  obscureText: true,
                                  controller: _confirmPasswordController,
                                ),
                                const SizedBox(height: 32),

                                // Botão Registrar
                                SizedBox(
                                  width: double.infinity, // Faz o botão ocupar toda a largura
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _fazerRegistro, // Desativa se estiver carregando
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B3D21),
                                      foregroundColor: const Color(0xFFC0C0C0),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 8,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                          )
                                        : const Text(
                                            'Registrar',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                  ),
                                ),
                                
                                const Spacer(),
                                const SizedBox(height: 24),

                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Text(
                                    'Voltar ao login',
                                    style: TextStyle(
                                      color: Color(0xFF17361A),
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}