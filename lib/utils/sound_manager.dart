import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class SoundManager {
  // Criamos uma única instância estática para economizar memória e evitar sobreposição de áudio
  static final AudioPlayer _player = AudioPlayer();

  static Timer? _audioCutTimer;
  /// Função para reproduzir o som de um animal específico.
  /// [audioPath] é o caminho relativo dentro da pasta assets/ (ex: 'audio/leao.mp3')
  static Future<void> reproduzirSomVitoria(
    String audioPath, {
      Duration duracaoMax = const Duration(seconds: 2),
    }) async {
      
  final caminhoLimpo = audioPath.trim();

    if (caminhoLimpo.isEmpty) return;

    try {

      _audioCutTimer?.cancel();
      // É boa prática dar stop antes para o caso de um som anterior ainda estar tocando
      await _player.stop();
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