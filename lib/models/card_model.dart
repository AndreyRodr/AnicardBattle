class CardModel {
  final int id;
  final String name;
  final String image;
  final Map<String, int> attributes;

  CardModel({
    required this.id,
    required this.name,
    required this.image,
    required this.attributes,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'], 
      name: json['name'], 
      image: json['image'], 
      attributes: Map<String, int>.from(json['attributes']),
      );
  }

  Map<String, dynamic> toJson() {
    return{
      'id': id,
      'name': name,
      'imagePath': image,
      'attributes': attributes,
    };
  }
}
