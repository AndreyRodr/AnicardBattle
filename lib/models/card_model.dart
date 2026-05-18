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
    // Isola o bloco "attributes" do JSON para facilitar a extração dos valores
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};

    return CardModel(
      // Converte o id com segurança
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      
      name: json['name'] ?? 'Desconhecido',
      pack: json['pack'] ?? 'desconhecido',
      isAlpha: json['isAlpha'] ?? false,
      
      // Mapeamento do caminho da imagem (lê de "image" no JSON)
      imagePath: json['image'] ?? 'assets/images/cards/default.png',
      
      // Mapeamento dos atributos aninhados
      instintoAssassino: attributes['instintoAssassino'] ?? 0,
      forca: attributes['forca'] ?? 0,
      peso: attributes['peso'] ?? 0,
      inteligencia: attributes['inteligencia'] ?? 0,
      agilidade: attributes['agilidade'] ?? 0,
      media: attributes['media'] ?? 0,
    );
  }

  // É sempre uma boa prática ter o toJson para quando formos salvar dados no banco
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
}