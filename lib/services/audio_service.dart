import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  
  bool _isMusicOn = true;
  double _volume = 0.5; 

  bool get isMusicOn => _isMusicOn;
  double get volume => _volume;

  Future<void> inicializarMusica() async {
    // WidgetsBinding garante que a árvore de widgets (e o DevicePreview) estejam montados antes do som começar
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Configura o loop infinito nativo de forma limpa
        await _musicPlayer.setLoopMode(LoopMode.one);
        
        // Define o asset de áudio do jogo
        await _musicPlayer.setAsset('assets/audio/background_music.mp3');
        await _musicPlayer.setVolume(_volume);
        
        // Inicia a reprodução em background
        await _musicPlayer.play();
      } catch (e) {
        debugPrint("Erro ao inicializar áudio: $e");
      }
    });
  }

  void alternarMusica(bool ligada) {
    _isMusicOn = ligada;
    try {
      if (ligada) {
        _musicPlayer.setVolume(_volume);
        _musicPlayer.play();
      } else {
        _musicPlayer.pause();
      }
    } catch (e) {
      debugPrint("Erro ao alternar música: $e");
    }
  }

  void definirVolume(double novoVolume) {
    _volume = novoVolume.clamp(0.0, 1.0);
    try {
      if (_isMusicOn) {
        _musicPlayer.setVolume(_volume);
      }
    } catch (e) {
      debugPrint("Erro ao ajustar volume: $e");
    }
  }
}