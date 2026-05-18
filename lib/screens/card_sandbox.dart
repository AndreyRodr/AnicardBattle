// import 'package:flutter/material.dart';
// import '../models/card_model.dart';
// import '../widgets/card_widget.dart';

// class CardSandbox extends StatelessWidget {
//   const CardSandbox({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Criamos uma carta "falsa" na hora, apenas para você ter dados visuais.
//     // Assim não dependemos de Firebase ou JSON para testar a UI.
//     final cartaTeste = CardModel(
//       id: 2,
//       name: "Onça-Pintada",
//       imagePath: "assets/images/cards/onca-pintada.png", // Troque para o nome de um PNG que você já tenha na pasta
//       pack: "floresta_amazonica",
//       isAlpha: true, // Mude para false para testar a carta comum
//       instintoAssassino: 95,
//       forca: 85,
//       peso: 65,
//       inteligencia: 75,
//       agilidade: 85,
//       media: 81,
//     );

//     return Scaffold(
//       backgroundColor: const Color(0xFF121212), // Fundo bem escuro para contrastar com a carta
//       body: Center(
//         child: SingleChildScrollView(
//           // Passamos a carta para o seu CardWidget
//           // Usei scale: 1.5 para deixar a carta 50% maior na tela e facilitar a edição!
//           child: CardWidget(
//             card: cartaTeste,
//             scale: 1.5, 
//           ),
//         ),
//       ),
//     );
//   }
// }