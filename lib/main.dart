import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'simulator/card_catalog.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CardCatalog.load();
  
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
      home: const SplashScreen(), 
    );
  }
}