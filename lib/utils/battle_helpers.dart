import 'package:flutter/material.dart';
import '../models/card_model.dart';

class BattleHelpers {
  static int obterValorAtributo(CardModel carta, String atributo) {
    switch (atributo) {
      case 'instintoAssassino': return carta.instintoAssassino;
      case 'forca': return carta.forca;
      case 'peso': return carta.peso;
      case 'inteligencia': return carta.inteligencia;
      case 'agilidade': return carta.agilidade;
      case 'media': return carta.media;
      default: return 0;
    }
  }

  static IconData obterIconeAtributo(String atributo) {
    switch (atributo) {
      case 'instintoAssassino': return Icons.water_drop;
      case 'forca': return Icons.fitness_center;
      case 'peso': return Icons.scale;
      case 'inteligencia': return Icons.lightbulb;
      case 'agilidade': return Icons.flash_on;
      case 'media': return Icons.stars;
      default: return Icons.help_outline;
    }
  }

static Color obterCorAtributo(String atributo) {
    switch (atributo) {
      case 'instintoAssassino':
        return Colors.redAccent; // Vermelho para instinto
      case 'forca':
        return const Color.fromRGBO(216, 75, 121, 1); // O rosa que você já estava usando
      case 'peso':
        return Colors.yellow; // Marrom para peso
      case 'inteligencia':
        return Colors.blueAccent; // Azul para inteligência
      case 'agilidade':
        return Colors.lightGreenAccent; // Laranja/Amarelo para agilidade
      case 'media':
        return Colors.grey; // Roxo para a média geral
      default:
        return Colors.grey;
    }
  }
}