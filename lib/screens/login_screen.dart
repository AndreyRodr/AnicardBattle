import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../widgets/custom_input_field.dart'; // Importando o nosso novo widget
import 'home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _lembrarUsuario = false;

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

                        // Card de Login responsivo
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
                                // Título
                                const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Input: Usuário/Email usando o CustomInputField
                                const CustomInputField(
                                  label: 'Nome de usuário ou Email:',
                                ),
                                const SizedBox(height: 20),

                                // Input: Senha usando o CustomInputField
                                const CustomInputField(
                                  label: 'Senha:',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 12),

                                // Checkbox
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _lembrarUsuario,
                                        onChanged: (value) {
                                          setState(() {
                                            _lembrarUsuario = value ?? false;
                                          });
                                        },
                                        side: const BorderSide(color: Colors.white, width: 2),
                                        activeColor: const Color(0xFF17361A),
                                        checkColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Lembrar deste usuário',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Botão Entrar
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AniCardScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B3D21),
                                    foregroundColor: const Color(0xFFC0C0C0),
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.black.withValues(alpha: 0.5),
                                  ),
                                  child: const Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                
                                const Spacer(),
                                const SizedBox(height: 24),

                                // Links de Ação
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Esqueci minha senha',
                                    style: TextStyle(
                                      color: Color(0xFF17361A),
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // NAVEGAÇÃO PARA TELA DE REGISTRO
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'Criar conta',
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