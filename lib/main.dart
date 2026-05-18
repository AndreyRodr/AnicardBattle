import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_preview/device_preview.dart';

import 'firebase_options.dart';
import 'simulator/card_catalog.dart';
import 'screens/home_screen.dart';  
import 'screens/login_screen.dart'; 
// import 'screens/card_sandbox.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Carrega o banco de dados simulado ANTES de desenhar a tela
  try {
    await CardCatalog.load();
    print("Catálogo de cartas carregado com sucesso!");
  } catch (e) {
    print("Erro ao carregar o catálogo de cartas: $e");
  }

  // Roda o app embrulhado no DevicePreview novamente
  runApp(
    DevicePreview(
      enabled: true, // Mantenha true para ver o celular na tela
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: DevicePreview.appBuilder,
      title: 'AniCard Battle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF183B1E)),
        useMaterial3: true,
      ),
      // O segredo está aqui:
      // home: const CardSandbox()
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Se o Firebase ainda estiver a verificar a sessão...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Se existir um utilizador logado, vai direto para o jogo
          if (snapshot.hasData) {
            return const AniCardScreen();
          }
          // Se não estiver logado, vai para a tela de Login
          return const LoginScreen();
        },
      ),
    );
  }
}