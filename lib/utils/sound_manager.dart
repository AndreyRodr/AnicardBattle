import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class SoundManager {
  // Criamos uma única instância estática para economizar memória e evitar sobreposição de áudio
  static final AudioPlayer _player = AudioPlayer();
  static Timer? _audioCutTimer;
  static bool efeitosSonorosAtivos = true;
  static double volumeEfeitos = 0.5;

  static void setEfeitosAtivos(bool ativo) {
    efeitosSonorosAtivos = ativo;
    if (!ativo) {
      _player.stop(); 
      _audioCutTimer?.cancel();
    }
  }

  static void definirVolumeEfeitos(double volume) {
    volumeEfeitos = volume;
    _player.setVolume(volume); // Aplica o volume na instância do player
    print('🔊 SoundManager: Volume dos efeitos definido para: ${(volume * 100).toStringAsFixed(0)}%');
  }

  /// Função para reproduzir o som de um animal específico.
  /// [audioPath] é o caminho relativo dentro da pasta assets/ (ex: 'audio/leao.mp3')
  static Future<void> reproduzirSomVitoria(
    String audioPath, {
    Duration duracaoMax = const Duration(seconds: 2),
    }) async {
  
    if (!efeitosSonorosAtivos) {
      return; // Mata a execução aqui
    }

    final caminhoLimpo = audioPath.trim();

    if (caminhoLimpo.isEmpty) return;

    try {

      _audioCutTimer?.cancel();

      // É boa prática dar stop antes para o caso de um som anterior ainda estar tocando
      await _player.stop();

      await _player.setVolume(volumeEfeitos);
      
      // AssetSource avisa o plugin que o arquivo está local nos assets
      await _player.play(AssetSource(caminhoLimpo));
      
      _audioCutTimer = Timer(duracaoMax, () async {
        print('⏱️ SoundManager: Limite de ${duracaoMax.inSeconds}s atingido. Cortando áudio!');
        await _player.stop();
      });
    } catch (e) {
      print('❌ SoundManager: Erro ao gerenciar limite de tempo do áudio: $e');
    }
  }
}