import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  // Criamos uma única instância estática para economizar memória e evitar sobreposição de áudio
  static final AudioPlayer _player = AudioPlayer();


  /// Função para reproduzir o som de um animal específico.
  /// [audioPath] é o caminho relativo dentro da pasta assets/ (ex: 'audio/leao.mp3')
  static Future<void> reproduzirSomVitoria(String audioPath) async {
    // 🔍 Print de debug para conferir o caminho no console

      
  final caminhoLimpo = audioPath.trim();

    if (caminhoLimpo.isEmpty) {
      print('⚠️ SoundManager: O caminho do áudio veio VAZIO no JSON desta carta.');
      return;
    }

    print('🎵 Tentando reproduzir som de vitória em: assets/$audioPath');

    try {
      // É boa prática dar stop antes para o caso de um som anterior ainda estar tocando
      await _player.stop();
      // AssetSource avisa o plugin que o arquivo está local nos assets
      await _player.play(AssetSource(caminhoLimpo));
      
      print('✅ SoundManager: Comando enviado com sucesso para o player!');
    } catch (e) {
      print('⚠️ Erro ao reproduzir áudio: $e. Verifique o caminho no JSON e no pubspec.yaml');
    }
  }
}