import 'package:flutter/material.dart';
import '../models/pack_model.dart';

class PackDisplayWidget extends StatelessWidget {
  final PackModel pack;
  final int quantity;

  const PackDisplayWidget({
    super.key,
    required this.pack,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // 🌟 Aumentado para o pacote ocupar muito mais espaço horizontal
      height: 420, // 🌟 Proporção vertical esticada de forma elegante para o Booster
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          // 1. Imagem do Pacote (Ocupa o espaço máximo do SizedBox)
          SizedBox.expand(
            child: Image.asset(
              pack.imagePath,
              fit: BoxFit.cover, // Mantém o PNG sem distorções, mas no tamanho máximo
            ),
          ),
          
          // 2. Círculo Contador reajustado para a nova proporção do pacote
          Positioned(
            bottom: 15, // 🌟 Ajustado para encaixar milimetricamente no canto do PNG maior
            right: 15,  // 🌟 Recuado um pouco para dentro para não flutuar fora do booster
            child: Container(
              width: 56, // 🌟 Mantém a esfera perfeita
              height: 56,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5), 
                    blurRadius: 6, 
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    color: Colors.black, 
                    fontSize: 24, // Texto ligeiramente maior para acompanhar o novo tamanho
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}