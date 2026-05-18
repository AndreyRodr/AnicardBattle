import 'package:flutter/material.dart';

class FilterBarWidget extends StatelessWidget {
  final String searchQuery;
  final String sortCriteria;
  final bool isAscending;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onOrderToggled;

  const FilterBarWidget({
    super.key,
    required this.searchQuery,
    required this.sortCriteria,
    required this.isAscending,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onOrderToggled,
  });

  @override
  Widget build(BuildContext context) {
    // Opções que batem exatamente com o 'switch' lá no DeckView
    final List<String> sortOptions = [
      'Nome',
      'Média'
    ];

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.brown[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown[900]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. BARRA DE PESQUISA ---
          TextField(
            // Preenche o campo caso o estado seja atualizado
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: searchQuery,
                selection: TextSelection.collapsed(offset: searchQuery.length),
              ),
            ),
            onChanged: onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Pesquisar carta...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.amberAccent),
              filled: true,
              fillColor: Colors.black26,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- 2. ORDENAÇÃO E DIREÇÃO ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Texto de label + Dropdown
              Row(
                children: [
                  const Text(
                    'Ordenar por:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: sortCriteria,
                        dropdownColor: Colors.brown[900], // Fundo do menu aberto
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.amberAccent),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        items: sortOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: onSortChanged,
                      ),
                    ),
                  ),
                ],
              ),

              // Botão de Crescente / Decrescente
              InkWell(
                onTap: onOrderToggled,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.amberAccent,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}