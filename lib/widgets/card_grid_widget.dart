import 'package:flutter/material.dart';
import 'card_widget.dart';
import '../models/card_model.dart';

class CardGridWidget extends StatelessWidget {
  final List<CardModel> cards; 

  const CardGridWidget({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, index) {
        return CardWidget(card: cards[index]);
      },
    );
  }
}