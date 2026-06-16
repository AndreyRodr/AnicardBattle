import 'package:anicard/screens/splash_screen.dart';
import 'package:anicard/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_preview/device_preview.dart';

import 'firebase_options.dart';
import 'simulator/card_catalog.dart';
import 'screens/home_screen.dart';  

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  // 1. Inicializa o Firebase primeiro para liberar as pontes nativas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await CardCatalog.load();
    print("Catálogo de cartas carregado com sucesso!");
  } catch (e) {
    print("Erro ao carregar o catálogo de cartas: $e");
  }

  // 🌟 CORREÇÃO DO BLOQUEIO: Removemos o "await"!
  // Ao disparar a função sem o await, o Flutter inicia o player de som em segundo plano 
  // (paralelamente) e libera a thread principal instantaneamente para abrir o aplicativo.
  AudioService().inicializarMusica();

  runApp(
    DevicePreview(
      enabled: true, 
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const AniCardScreen();
          }
          return const SplashScreen();
        },
      ),
    );
  }
}