import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importe a tela para onde o app vai depois de carregar

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Configura um timer de 3 segundos
    Timer(const Duration(seconds: 3), () {
      // pushReplacement destrói a splash screen e abre o Login.
      // Isso impede que o usuário volte para a splash screen se apertar o botão de "voltar" do celular.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF326437), // O verde padrão do seu app
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sua Logo
            Image.asset(
              'assets/images/AniCard Icon.png',
              width: 360,
              height: 320,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 40),
            
            // O "Carregando" (Bolinha girando)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Cor da linha girando
              strokeWidth: 4.0, // Grossura da linha
            ),
            
            const SizedBox(height: 20),
            
            // Texto opcional de carregamento (você pode remover se não quiser)
            const Text(
              'Carregando...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}