import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_preview/device_preview.dart'; // 1. O Device Preview voltou!
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'simulator/card_catalog.dart'; // 2. Seu simulador de dados

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

  // 3. Roda o app embrulhado no DevicePreview novamente
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
      // 4. Conecta o DevicePreview ao app (sem aquela linha depreciada)
      builder: DevicePreview.appBuilder, 
      
      title: 'AniCard Battle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF183B1E)),
      ),
      home: const SplashScreen(),
    );
  }
}