import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'interactive_toggle_button.dart';

class SettingsDialog extends StatefulWidget {
  final bool initialSoundEffectsOn;
  final bool initialMusicOn;
  final ValueChanged<bool> onSoundEffectsChanged;
  final ValueChanged<bool> onMusicChanged;
  final ValueChanged<double> onMusicVolumeChanged;

  const SettingsDialog({
    super.key,
    required this.initialSoundEffectsOn,
    required this.initialMusicOn,
    required this.onSoundEffectsChanged,
    required this.onMusicChanged,
    required this.onMusicVolumeChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _soundEffectsOn = true;
  bool _musicOn = true;
  double _musicVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _soundEffectsOn = widget.initialSoundEffectsOn;
    _musicOn = widget.initialMusicOn;
    
    try {
      _musicVolume = AudioService().volume.clamp(0.0, 1.0);
    } catch (_) {
      _musicVolume = 0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF162A17),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                const Text(
                  'Configurações',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 24, 
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E5E35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 1. Linha de Efeitos Sonoros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Efeitos sonoros:', 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // 🌟 CORREÇÃO: Força uma largura máxima para o botão não sumir da Row
                SizedBox(
                  width: 130, 
                  child: InteractiveToggleButton(
                    isOn: _soundEffectsOn,
                    onTap: () {
                      setState(() {
                        _soundEffectsOn = !_soundEffectsOn;
                      });
                      widget.onSoundEffectsChanged(_soundEffectsOn);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 16),

            // 2. Linha de Ligar/Desligar a Música (Adicionado para ficar simétrico)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Música de fundo:', 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // 🌟 CORREÇÃO: Mesma estrutura segura de tamanho
                SizedBox(
                  width: 130,
                  child: InteractiveToggleButton(
                    isOn: _musicOn,
                    onTap: () {
                      setState(() {
                        _musicOn = !_musicOn;
                      });
                      widget.onMusicChanged(_musicOn);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 16),

            // 3. Controle do Volume do Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _musicOn && _musicVolume > 0 ? Icons.volume_up : Icons.volume_off, 
                          color: Colors.white70, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Volume da Música:', 
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${(_musicVolume * 100).toInt()}%',
                      style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.amber,
                    inactiveTrackColor: const Color(0xFF2E5E35),
                    trackHeight: 6.0,
                    thumbColor: Colors.amber,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                    overlayColor: Colors.amber.withOpacity(0.2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                  ),
                  child: Slider(
                    value: _musicVolume.clamp(0.0, 1.0),
                    min: 0.0,
                    max: 1.0,
                    onChanged: _musicOn // 🌟 Opcional: Só deixa arrastar se a música estiver ligada
                        ? (newValue) {
                            setState(() {
                              _musicVolume = newValue;
                            });
                            widget.onMusicVolumeChanged(newValue);
                          }
                        : null, 
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}