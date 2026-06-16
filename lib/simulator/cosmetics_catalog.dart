class CosmeticsCatalog {
  static const Map<String, dynamic> data = {
    "arena": [
      {
        "id": "arena_1",
        "nome": "Campo Clássico",
        "raridade": "Comum",
        "isBloqueadoPadrao": false
      },
      {
        "id": "arena_2",
        "nome": "Santuário Cibernético",
        "raridade": "Épica",
        "isBloqueadoPadrao": false
      },
      {
        "id": "arena_3",
        "nome": "Vale Místico",
        "raridade": "Lendária",
        "isBloqueadoPadrao": false
      },
      {
        "id": "arena_4",
        "nome": "Arena de Fogo",
        "raridade": "Rara",
        "isBloqueadoPadrao": true
      },
    ],
    "borda": [
      {
        "id": "borda_1",
        "nome": "Madeira Antiga",
        "raridade": "Comum",
        "isBloqueadoPadrao": false
      },
      {
        "id": "borda_2",
        "nome": "Fenda de Neon",
        "raridade": "Rara",
        "isBloqueadoPadrao": false
      },
      {
        "id": "borda_3",
        "nome": "Aura Púrpura",
        "raridade": "Épica",
        "isBloqueadoPadrao": false
      },
      {
        "id": "borda_4",
        "nome": "Ouro Real",
        "raridade": "Lendária",
        "isBloqueadoPadrao": true
      },
    ],
    "vida": [
      {
        "id": "vida_1",
        "nome": "Coração Vital",
        "raridade": "Comum",
        "isBloqueadoPadrao": false
      },
      {
        "id": "vida_2",
        "nome": "Núcleo de Energia",
        "raridade": "Épica",
        "isBloqueadoPadrao": false
      },
      {
        "id": "vida_3",
        "nome": "Baluarte",
        "raridade": "Lendária",
        "isBloqueadoPadrao": false
      },
      {
        "id": "vida_4",
        "nome": "Chama Ardente",
        "raridade": "Rara",
        "isBloqueadoPadrao": true
      },
    ]
  };

  /// Retorna a lista de cosméticos de uma determinada categoria
  static List<Map<String, dynamic>> getPorCategoria(String categoria) {
    return List<Map<String, dynamic>>.from(data[categoria] ?? []);
  }
}