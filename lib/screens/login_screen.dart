import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../widgets/custom_input_field.dart';
import '../services/auth_service.dart'; // Importando o serviço
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _lembrarUsuario = false;
  bool _isLoading = false;

  void _fazerLogin() async {
    setState(() {
      _isLoading = true;
    });

    String? erro = await _authService.loginUsuario(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (erro == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AniCardScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                        
                        Image.asset(
                          'assets/images/AniCard Icon.png', 
                          width: 240,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),

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
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                CustomInputField(
                                  label: 'Email:', // Firebase usa Email para login por padrão
                                  controller: _emailController,
                                ),
                                const SizedBox(height: 20),

                                CustomInputField(
                                  label: 'Senha:',
                                  obscureText: true,
                                  controller: _passwordController,
                                ),
                                const SizedBox(height: 12),

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
                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _fazerLogin,
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
                                            'ENTRAR',
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