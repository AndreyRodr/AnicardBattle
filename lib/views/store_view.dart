import 'package:flutter/material.dart';

// Painel para a oferta principal
class MainOfferWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String oldPrice;
  final String newPrice;
  final VoidCallback onTap;

  const MainOfferWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.oldPrice,
    required this.newPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B3620),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap, 
        borderRadius: BorderRadius.circular(8), 
        child: SizedBox(
          width: 358,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.asset(
                  imagePath, 
                  width: double.infinity,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title, 
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              // Convertendo o número para texto. Opcionalmente, você pode usar .toStringAsFixed(2) para forçar 2 casas decimais.
                              oldPrice.toString(), 
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.white70,
                                decorationThickness: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                            const SizedBox(width: 4),
                            Text(
                              newPrice.toString(), // Convertendo o número para texto
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoinOfferWidget extends StatelessWidget {
  final String coinValue;
  final String price;
  final VoidCallback onTap;

  const CoinOfferWidget({
    super.key,
    required this.coinValue,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B3620),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 110,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Agora funciona perfeitamente
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber, // Adicionada cor ao ícone
                  size: 32, // Um pouco maior para destaque
                ),
                const SizedBox(height: 8), // Espaço entre o ícone e o texto
                Text(
                  "$coinValue moedas", // Formatação corrigida
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14, // Levemente reduzido para caber bem em 116px
                  ),
                ),
                const SizedBox(height: 12),
                // Falso botão: Apenas visual, já que o InkWell do pai lida com o clique
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D9E4E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    // toStringAsFixed(2) garante que o preço fique no formato 0.00
                    "R\$ $price", 
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoreView extends StatelessWidget {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ofertas:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 16),
          
          Center(
            child: MainOfferWidget(
              imagePath: "assets/images/oferta.jpeg",
              title: "3 pacotes Tanzânia",
              oldPrice: '3000',
              newPrice: '1500', 
              onTap: () {
                print('Oferta principal clicada');
              },
            ),
          ),
          
          const SizedBox(height: 32), 
          
          const Text(
            "Moedas:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center, 
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                CoinOfferWidget(
                  coinValue: '100', // Passando como int
                  price: '6.50',    // Passando como double (usar ponto em vez de vírgula no código)
                  onTap: () { print('Moedas compradas'); },
                ),
                CoinOfferWidget(
                  coinValue: '300',
                  price: '15.00',
                  onTap: () { print('Moedas compradas'); },
                ),
                CoinOfferWidget(
                  coinValue: '500',
                  price: '25.00',
                  onTap: () { print('Moedas compradas'); },
                ),
                CoinOfferWidget(
                  coinValue: '1000',
                  price: '45.00',
                  onTap: () { print('Moedas compradas'); },
                ),
                CoinOfferWidget(
                  coinValue: '2500',
                  price: '100.00',
                  onTap: () { print('Moedas compradas'); },
                ),
                CoinOfferWidget(
                  coinValue: '5000',
                  price: '180.00',
                  onTap: () { print('Moedas compradas'); },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}