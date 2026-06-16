import 'package:flutter/material.dart';

class CosmeticHelpers {
  
  /// Traduz o ID da arena salva no banco para uma imagem de arena
  static String obterCaminhoArena(String arenaId) {
    switch (arenaId) {
      case 'arena_2':
        return 'assets/images/arenas/arena_2.png';
      case 'arena_3':
        return 'assets/images/arenas/arena_3.png';
      case 'arena_4':
        return 'assets/images/arenas/arena_4.png';
      case 'arena_1':
      default:
        return 'assets/images/arenas/arena_1.png';
    }
  }

  /// Traduz o ID da borda salvo no banco para uma cor real do Flutter
  static Color obterCorBorda(String bordaId) {
    switch (bordaId) {
      case 'borda_2':
        return Colors.cyanAccent; // Borda de Plasma / Futurista
      case 'borda_3':
        return Colors.purpleAccent; // Borda Mística
      case 'borda_4':
        return Colors.redAccent; // Borda de Fogo
      case 'borda_5':
        return Colors.lightGreenAccent; // Borda Ácido / Radioativo
      case 'borda_6':
        return Colors.amber; // Borda de Ouro / Lendária
      
      case 'borda_1':
      default:
        return Colors.brown[900]!; // A cor padrão atual das suas cartas
    }
  }

  static Map<String, dynamic> obterEstiloVida(String iconeId) {
    switch (iconeId) {
      case 'vida_2':
        return {
          'icone': Icons.bolt, // Ícone de Raio / Energia
          'corAtiva': Colors.yellowAccent,
        };
      case 'vida_3':
        return {
          'icone': Icons.shield, // Ícone de Escudo / Armadura
          'corAtiva': Colors.blueAccent,
        };
      case 'vida_4':
        return {
          'icone': Icons.star, // Ícone de Estrela
          'corAtiva': Colors.purpleAccent,
        };
      case 'vida_5':
        return {
          'icone': Icons.local_fire_department, // Ícone de Fogo
          'corAtiva': Colors.orangeAccent,
        };
      
      case 'vida_1':
      default:
        return {
          'icone': Icons.favorite, // O coração clássico atual
          'corAtiva': Colors.green,
        };
    }
  }
}