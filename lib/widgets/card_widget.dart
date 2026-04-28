import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;

  const CardWidget({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Image.asset(
            card.image,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}