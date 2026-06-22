import 'package:flutter/material.dart';
import '../widgets/settings_dialog.dart';
import '../services/audio_service.dart';
import '../utils/sound_manager.dart'; // Cada um no seu quadrado

class DialogHelpers {
  static bool _isSettingsOpen = false;

  /// Abre o menu global de configurações do jogo de qualquer tela
  static void mostrarSettings(BuildContext context, {VoidCallback? onDialogClosed}) {
    if (_isSettingsOpen) return;
    _isSettingsOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        _isSettingsOpen = false;
        return;
      }

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
                // Busca os estados reais de cada serviço individual
                initialSoundEffectsOn: SoundManager.efeitosSonorosAtivos, 
                initialMusicOn: musicaLigada,
                initialSoundVolume: SoundManager.volumeEfeitos,
                
                onSoundEffectsChanged: (value) {
                  // Cada serviço cuida do seu estado de forma independente
                  SoundManager.setEfeitosAtivos(value);
                  setDialogState(() {});
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
                onSoundVolumeChanged: (volume) {
                  SoundManager.definirVolumeEfeitos(volume);
                  setDialogState(() {}); // Força o Slider a andar visualmente no pop-up
                },
              );
            },
          );
        },
      ).then((_) {
        _isSettingsOpen = false;
        if (onDialogClosed != null) {
          onDialogClosed();
        }
      });
    });
  }
}