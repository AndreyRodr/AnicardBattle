import 'package:flutter/material.dart';
import 'interactive_toggle_button.dart';

class SettingsDialog extends StatefulWidget {
  final bool initialSoundEffectsOn;
  final bool initialMusicOn;
  final ValueChanged<bool> onSoundEffectsChanged;
  final ValueChanged<bool> onMusicChanged;

  const SettingsDialog({
    super.key,
    required this.initialSoundEffectsOn,
    required this.initialMusicOn,
    required this.onSoundEffectsChanged,
    required this.onMusicChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _soundEffectsOn;
  late bool _musicOn;

  @override
  void initState() {
    super.initState();
    _soundEffectsOn = widget.initialSoundEffectsOn;
    _musicOn = widget.initialMusicOn;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF162A17),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Efeitos sonoros:', 
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      InteractiveToggleButton(
                        isOn: _soundEffectsOn,
                        onTap: () {
                          setState(() {
                            _soundEffectsOn = !_soundEffectsOn;
                          });
                          widget.onSoundEffectsChanged(_soundEffectsOn);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Música:', 
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      InteractiveToggleButton(
                        isOn: _musicOn,
                        onTap: () {
                          setState(() {
                            _musicOn = !_musicOn;
                          });
                          widget.onMusicChanged(_musicOn);
                        },
                      ),
                    ],
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