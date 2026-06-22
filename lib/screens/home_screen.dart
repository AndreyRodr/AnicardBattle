import 'dart:ui';
import 'package:anicard/services/audio_service.dart';
import 'package:anicard/utils/sound_manager.dart';
import 'package:anicard/widgets/tutorial_dialog.dart';
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
import '../utils/dialog_helpers.dart';

class AniCardScreen extends StatefulWidget {
  const AniCardScreen({super.key});

  @override
  State<AniCardScreen> createState() => _AniCardScreenState();
}

class _AniCardScreenState extends State<AniCardScreen> {
  int _selectedIndex = 2; // Começa na aba da Batalha
  bool _soundEffectsOn = SoundManager.efeitosSonorosAtivos;
  bool _isSettingsOpen = false;
  bool _tutorialVerificado = false;

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
      // Garante que a variável local está idêntica ao estado do SoundManager antes de abrir
      _soundEffectsOn = SoundManager.efeitosSonorosAtivos;
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
                initialSoundVolume: SoundManager.volumeEfeitos, 
                onSoundVolumeChanged: (volume) {
                  SoundManager.definirVolumeEfeitos(volume);
                  setDialogState(() {}); // Atualiza o Slider dentro do pop-up
                },
                onSoundEffectsChanged: (value) {
                  setState(() {
                    _soundEffectsOn = value;
                  });
                  
                  // 👇 ATUALIZA O GERENCIADOR DE ÁUDIO EM TEMPO REAL
                  SoundManager.setEfeitosAtivos(value);
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
        bool mostrarBadgeNotificacao = false; // 🌟 Controle do ponto vermelho

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          moedasAtuais = data['moedas'] ?? 0;
          trofeusAtuais = data['trofeus'] ?? 0;

          // 🌟 INJEÇÃO DA CHECAGEM AUTOMÁTICA DO TUTORIAL OBRIGATÓRIO
          final bool tutorialVisto = data['tutorialVisto'] ?? false;
          if (!tutorialVisto && !_tutorialVerificado) {
            _tutorialVerificado = true; // Muda a trava para não abrir em loops infinitos
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false, // Força ele a concluir clicando em Avançar/Jogar
                  builder: (context) => const TutorialDialog(),
                );
              }
            });
          }

          // 🌟 LÓGICA DE CHECAGEM DOS PRÊMIOS DISPONÍVEIS
          // 1. Varre missões diárias prontas para resgate
          final listasDiarias = data['missoesDiarias'] as List<dynamic>? ?? [];
          bool temDiariaPronta = listasDiarias.any((m) => 
            (m['progresso'] ?? 0) >= (m['meta'] ?? 1) && !(m['coletado'] ?? false));

          // 2. Varre missões semanais prontas para resgate
          final listasSemanais = data['missoesSemanais'] as List<dynamic>? ?? [];
          bool temSemanalPronta = listasSemanais.any((m) => 
            (m['progresso'] ?? 0) >= (m['meta'] ?? 1) && !(m['coletado'] ?? false));

          // 3. Checa se o calendário diário pode ser coletado hoje
          final dadosDiarios = data['recompensaDiaria'] as Map<String, dynamic>? ?? {};
          final String ultimoColetado = dadosDiarios['ultimoLoginColetado'] ?? "";
          final hoje = DateTime.now();
          final hojeStr = "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";
          bool loginDiarioDisponivel = ultimoColetado != hojeStr;

          // Ativa o badge se pelo menos um critério for verdadeiro
          if (temDiariaPronta || temSemanalPronta || loginDiarioDisponivel) {
            mostrarBadgeNotificacao = true;
          }
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
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.settings, color: Colors.white70, size: 28),
                                  onPressed: () => DialogHelpers.mostrarSettings(context, onDialogClosed: () {
                                    setState(() {}); 
                                  }),
                                  tooltip: 'Configurações',
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
                              // 🌟 Ícone de Missões envolvido com o componente Badge nativo
                              Badge(
                                isLabelVisible: mostrarBadgeNotificacao,
                                backgroundColor: const Color(0xFFC72424), // Vermelho de alerta limpo
                                smallSize: 11, // Pontinho vermelho sutil e visível
                                offset: const Offset(-1, 1),
                                child: GestureDetector(
                                  onTap: () => _abrirMenuMissoes(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(9), 
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
                              ),
                              const SizedBox(width: 10), 
                              
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