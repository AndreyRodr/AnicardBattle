import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../views/battle_view.dart';
import '../views/profile_view.dart';
import '../views/store_view.dart';
import '../views/deck_view.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/settings_dialog.dart';
import '../views/open_pack_view.dart';

class AniCardScreen extends StatefulWidget {
  const AniCardScreen({super.key});

  @override
  State<AniCardScreen> createState() => _AniCardScreenState();
}

class _AniCardScreenState extends State<AniCardScreen> {
  int _selectedIndex = 2; // Começa na aba da Batalha
  bool _soundEffectsOn = true;
  bool _musicOn = false;

  final List<Widget> _telas = [
    const ProfileView(), 
    const DeckView(),
    const BattleView(), 
    const OpenPackView(),
    const StoreView(),
  ];

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SettingsDialog(
          initialSoundEffectsOn: _soundEffectsOn,
          initialMusicOn: _musicOn,
          onSoundEffectsChanged: (value) {
            setState(() {
              _soundEffectsOn = value;
            });
          },
          onMusicChanged: (value) {
            setState(() {
              _musicOn = value;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Se por algum motivo o usuário não estiver logado, evita quebrar a tela
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.green)));
    }

    // 1. O StreamBuilder envolve a tela toda para escutar as moedas do usuário em tempo real
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        int moedasAtuais = 0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          moedasAtuais = data['moedas'] ?? 0;
        }

        return Scaffold(
          extendBody: true, 

          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),

          body: Stack(
            children: [
              // Fundo
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Efeito Blur
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              SafeArea(
                bottom: false, 
                child: Column(
                  children: [
                    // --- Top Bar Dinâmica ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _showSettingsDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.settings, color: Colors.grey, size: 28),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  '$moedasAtuais', // 👈 AGORA EXIBE O SALDO REAL DO FIREBASE!
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- MEIO DA TELA (Dinâmico) ---
                    Expanded(
                      child: _telas[_selectedIndex], 
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}