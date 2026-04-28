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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Input de Busca
          Expanded(
            flex: 5,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.brown[700],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.brown[900]!, width: 2),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Buscar por carta ou coleção:',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                ),
                onChanged: onSearchChanged,
              ),
            ),
          ),
          
          const SizedBox(width: 8),

          // Select de Ordenação
          Expanded(
            flex: 3,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.brown[700],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.brown[900]!, width: 2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: sortCriteria,
                  dropdownColor: Colors.brown[800],
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  items: ['Aquisição', 'Alfabética', 'Poder'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: onSortChanged,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),

          // Botão de Ordem (Crescente/Decrescente)
          GestureDetector(
            onTap: onOrderToggled,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.brown[700],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.brown[900]!, width: 2),
              ),
              child: Icon(
                isAscending ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: Colors.white54,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}