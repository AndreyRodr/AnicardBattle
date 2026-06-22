import 'dart:math';
import '../models/card_model.dart'; // 🌟 Ajuste o import conforme o seu modelo de carta

enum BotDifficulty { iniciante, intermediario, dificil }

class BotEngine {
  final Random _random = Random();

  /// Função principal que decide qual carta o Bot vai jogar
  CardModel decidirJogada({
    required List<CardModel> maoDoBot,
    required String atributoDaRodada,
    required BotDifficulty dificuldade,
  }) {
    if (maoDoBot.isEmpty) {
      throw Exception("O bot não tem cartas na mão para jogar!");
    }

    switch (dificuldade) {
      case BotDifficulty.iniciante:
        return _jogarIniciante(maoDoBot);
      
      case BotDifficulty.intermediario:
        return _jogarIntermediario(maoDoBot, atributoDaRodada);
      
      case BotDifficulty.dificil:
        return _jogarDificil(maoDoBot, atributoDaRodada);
    }
  }

  /// 🟢 INICIANTE: Escolha 100% aleatória
  CardModel _jogarIniciante(List<CardModel> mao) {
    int indexAleatorio = _random.nextInt(mao.length);
    return mao[indexAleatorio];
  }

  /// 🟡 INTERMEDIÁRIO: Sempre joga o maior valor do atributo atual
  CardModel _jogarIntermediario(List<CardModel> mao, String atributo) {
    // Ordena as cartas da maior para a menor com base no atributo ativo
    mao.sort((a, b) => b.getValorAtributo(atributo).compareTo(a.getValorAtributo(atributo)));
    return mao.first; // Retorna a carta com o maior valor bruto
  }

  /// 🔴 DIFÍCIL: Analisa se vale a pena gastar carta boa ou economizar
  CardModel _jogarDificil(List<CardModel> mao, String atributo) {
    // Ordena para saber qual a sua carta mais forte e mais fraca no atributo atual
    mao.sort((a, b) => b.getValorAtributo(atributo).compareTo(a.getValorAtributo(atributo)));
    
    CardModel cartaMaisForte = mao.first;
    CardModel cartaMaisFraca = mao.last;

    double maiorValor = cartaMaisForte.getValorAtributo(atributo).toDouble();

    // 🌟 LÓGICA ESTRATEGISTA:
    // Se o maior valor do Bot para este atributo for menor que 45, ele assume que a rodada
    // está provavelmente perdida. Em vez de queimar a sua carta "média", ele joga a pior carta 
    // de todas (cartaMaisFraca) para limpar a mão e guardar as melhores para depois.
    if (maiorValor < 45 && mao.length > 1) {
      return cartaMaisFraca; // Descarta a pior carta
    }

    // Caso contrário, ele vai com tudo para ganhar a rodada
    return cartaMaisForte;
  }

}