import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart'; // Importando o nosso novo widget

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

                        // Card de Registro responsivo
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
                                  'REGISTRO',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Inputs usando o CustomInputField
                                const CustomInputField(
                                  label: 'Nome de usuário:',
                                ),
                                const SizedBox(height: 20),

                                const CustomInputField(
                                  label: 'Email:',
                                ),
                                const SizedBox(height: 20),

                                const CustomInputField(
                                  label: 'Senha:',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 20),

                                const CustomInputField(
                                  label: 'Confirmar Senha:',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 32),

                                // Botão Registrar
                                ElevatedButton(
                                  onPressed: () {
                                    // Lógica de registro
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
                                    'Registrar',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                
                                const Spacer(),
                                const SizedBox(height: 24),

                                // NAVEGAÇÃO PARA VOLTAR AO LOGIN
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context); // Volta para a tela anterior
                                  },
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