class CardModel {
  final int id;
  final String name;
  final String imagePath;
  final String pack;
  final bool isAlpha;
  
  // Atributos
  final int instintoAssassino;
  final int forca;
  final int peso;
  final int inteligencia;
  final int agilidade;
  final int media;

  CardModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.pack,
    required this.isAlpha,
    required this.instintoAssassino,
    required this.forca,
    required this.peso,
    required this.inteligencia,
    required this.agilidade,
    required this.media,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};

    return CardModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Desconhecido',
      pack: json['pack'] ?? 'desconhecido',
      isAlpha: json['isAlpha'] ?? false,
      imagePath: json['image'] ?? 'assets/images/cards/default.png',
      instintoAssassino: attributes['instintoAssassino'] ?? 0,
      forca: attributes['forca'] ?? 0,
      peso: attributes['peso'] ?? 0,
      inteligencia: attributes['inteligencia'] ?? 0,
      agilidade: attributes['agilidade'] ?? 0,
      media: attributes['media'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': imagePath,
      'pack': pack,
      'isAlpha': isAlpha,
      'attributes': {
        'instintoAssassino': instintoAssassino,
        'forca': forca,
        'peso': peso,
        'inteligencia': inteligencia,
        'agilidade': agilidade,
        'media': media,
      }
    };
  }

  // 🌟 NOVO MÉTODO: Retorna o valor numérico com base no nome do atributo em String
  // Útil para a Engine mapear os cálculos matemáticos da IA sem ifs gigantescos
  int getValorAtributo(String nomeAtributo) {
    switch (nomeAtributo) {
      case 'instintoAssassino':
        return instintoAssassino;
      case 'forca':
        return forca;
      case 'peso':
        return peso;
      case 'inteligencia':
        return inteligencia;
      case 'agilidade':
        return agilidade;
      case 'media':
        return media;
      default:
        return 0;
    }
  }

  // 🌟 NOVO MÉTODO: Descobre sozinho qual é o maior atributo desta carta específica
  // Ideal para quando o Bot Difícil vencer a rodada e precisar escolher a melhor opção dele
  String getMelhorAtributo() {
    final Map<String, int> mapaAtributos = {
      'instintoAssassino': instintoAssassino,
      'forca': forca,
      'peso': peso,
      'inteligencia': inteligencia,
      'agilidade': agilidade,
      'media': media,
    };

    String melhorAtributo = 'forca';
    int maiorValor = -1;

    mapaAtributos.forEach((chave, valor) {
      if (valor > maiorValor) {
        maiorValor = valor;
        melhorAtributo = chave;
      }
    });

    return melhorAtributo;
  }
}