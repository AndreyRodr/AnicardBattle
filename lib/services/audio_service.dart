import 'package:flutter/foundation.dart'; // 🌟 Importante para usar kIsWeb
import 'package:flutter/material.dart';
import 'dart:io'; // 🌟 Importante para checar se é Windows/Android
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
    // 🌟 RESOLUÇÃO DEFINITIVA DO CRASH DE WINDOWS:
    // Se o app estiver rodando nativamente no Windows desktop, o just_audio não possui 
    // suporte nativo out-of-the-box e derruba o processo. Isolamos essa checagem!
    if (!kIsWeb && Platform.isWindows) {
      debugPrint("Música desativada no Windows Desktop para evitar incompatibilidade nativa.");
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _musicPlayer.setLoopMode(LoopMode.one);
        await _musicPlayer.setAsset('assets/audio/background_music.mp3');
        await _musicPlayer.setVolume(_volume);
        await _musicPlayer.play();
      } catch (e) {
        debugPrint("Erro ao inicializar áudio com just_audio: $e");
      }
    });
  }

  void alternarMusica(bool ligada) {
    _isMusicOn = ligada;
    if (!kIsWeb && Platform.isWindows) return; // Ignora se for Windows

    try {
      if (ligada) {
        _musicPlayer.setVolume(_volume);
        _musicPlayer.play();
      } else {
        _musicPlayer.pause();
      }
    } catch (e) {
      debugPrint("Erro ao pausar música: $e");
    }
  }

  void definirVolume(double novoVolume) {
    _volume = novoVolume.clamp(0.0, 1.0);
    if (!kIsWeb && Platform.isWindows) return; // Ignora se for Windows

    try {
      if (_isMusicOn) {
        _musicPlayer.setVolume(_volume);
      }
    } catch (e) {
      debugPrint("Erro ao ajustar volume: $e");
    }
  }
}