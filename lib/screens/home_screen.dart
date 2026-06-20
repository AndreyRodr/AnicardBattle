import 'dart:ui';
import 'package:anicard/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../views/battle_view.dart'; 
import '../views/profile_view.dart';
import '../views/store_view.dart';
import '../views/deck_view.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/ranking_dialog.dart';
import '../views/open_pack_view.dart';
import '../widgets/quests_dialog.dart'; 

class AniCardScreen extends StatefulWidget {
  const AniCardScreen({super.key});

  @override
  State<AniCardScreen> createState() => _AniCardScreenState();
}

class _AniCardScreenState extends State<AniCardScreen> {
  int _selectedIndex = 2; // Começa na aba da Batalha
  bool _soundEffectsOn = true;
  bool _isSettingsOpen = false;

  final List<Widget> _telas = [
    const ProfileView(), 
    const DeckView(),
    const BattleView(), 
    const OpenPackView(),
    const StoreView(),
  ];

  void _showSettingsDialog(BuildContext context) {
    if (_isSettingsOpen) return; 

    setState(() {
      _isSettingsOpen = true; 
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      bool musicaLigada = true;
      try {
        musicaLigada = AudioService().isMusicOn;
      } catch (_) {}

      showDialog(
        context: context,
        barrierDismissible: true,
        useRootNavigator: true, 
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return SettingsDialog(
                initialSoundEffectsOn: _soundEffectsOn, 
                initialMusicOn: musicaLigada,
                onSoundEffectsChanged: (value) {
                  setState(() {
                    _soundEffectsOn = value;
                  });
                },
                onMusicChanged: (value) {
                  try {
                    AudioService().alternarMusica(value);
                  } catch (e) {
                    debugPrint("Erro ao alternar música: $e");
                  }
                },
                onMusicVolumeChanged: (volume) {
                  try {
                    AudioService().definirVolume(volume);
                  } catch (e) {
                    debugPrint("Erro ao alterar volume: $e");
                  }
                  setDialogState(() {}); 
                },
              );
            },
          );
        },
      ).then((_) {
        if (mounted) {
          setState(() {
            _isSettingsOpen = false;
          });
        }
      });
    });
  }

  void _abrirMenuMissoes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const QuestsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.green)));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        int moedasAtuais = 0;
        int trofeusAtuais = 0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          moedasAtuais = data['moedas'] ?? 0;
          trofeusAtuais = data['trofeus'] ?? 0;
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
                          // 🟢 LADO ESQUERDO: Configurações e Ranking/Troféus
                          Row(
                            children: [
                              // Botão de Configurações
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
                              const SizedBox(width: 10),
                              
                              // Contador de Ranking
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const RankingDialog(),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.amber.withOpacity(0.2), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$trofeusAtuais', 
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // 🟡 LADO DIREITO: Missões colado com o Saldo de Moedas
                          Row(
                            children: [
                              // Ícone de Missões/Recompensas Diárias
                              GestureDetector(
                                onTap: () => _abrirMenuMissoes(context),
                                child: Container(
                                  padding: const EdgeInsets.all(9), // Ajustado levemente o padding para equilibrar o tamanho
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF522121),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: const Icon(Icons.assignment_turned_in, color: Colors.amber, size: 24),
                                ),
                              ),
                              const SizedBox(width: 10), // Espaço perfeito entre os dois blocos monetários
                              
                              // Indicador de moedas existente
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
                                      '$moedasAtuais', 
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