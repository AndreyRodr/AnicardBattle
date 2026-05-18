class CardModel {
  final int id;
  final String image;
  
  // Atributos
  final int instintoAssassino;
  final int forca;
  final int peso;
  final int inteligencia;
  final int agilidade;
  final int media;

  CardModel({
    required this.id,
    required this.image,
    required this.instintoAssassino,
    required this.forca,
    required this.peso,
    required this.inteligencia,
    required this.agilidade,
    required this.media,
    // required this.nome,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    // Isola o bloco "attributes" do JSON para facilitar a extração dos valores
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};

    return CardModel(
      // Converte o id com segurança, independentemente de vir como String ou Int no JSON
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      
      // Mapeamento do caminho da imagem
      image: json['image'] ?? '',
      
      // Mapeamento dos atributos aninhados
      instintoAssassino: attributes['instintoAssassino'] ?? 0,
      forca: attributes['forca'] ?? 0,
      peso: attributes['peso'] ?? 0,
      inteligencia: attributes['inteligencia'] ?? 0,
      agilidade: attributes['agilidade'] ?? 0,
      media: attributes['media'] ?? 0,
      
    );
  }
}