import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Importa o núcleo do Firebase
import 'firebase_options.dart'; // 2. Importa o arquivo que o CLI gerou
import 'screens/splash_screen.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importe no topo

// 3. O "main" agora é um Future assíncrono
Future<void> main() async {
  // 4. Garante que os blocos internos do Flutter estejam prontos
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env"); // Carrega as variáveis do .env
  
  // 5. Conecta o seu app ao Firebase usando as chaves geradas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicia o app normalmente
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniCard Battle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF183B1E)),
      ),
      home: const SplashScreen(), // O app começa pela sua tela de carregamento
    );
  }
}