import 'package:flutter/material.dart';
import '../screens/battle_screen.dart';

class BattleView extends StatelessWidget {
  const BattleView({super.key});

  // 🌟 O MENU DE MODOS DE JOGO: Abre ao clicar no seu botão original
  void _abrirMenuModosDeJogo(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF351F14), // Marrom clássico para os menus
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho do Pop-up
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    const Text(
                      'MODOS DE JOGO',
                      style: TextStyle(
                        color: Colors.amber, 
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E5E35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 🟢 Bot Iniciante
                _buildMenuButton(
                  context: context,
                  title: 'Bot Iniciante',
                  subtitle: 'Ganhe: +10 🏆 | +15 🪙',
                  color: const Color(0xFF1B5E20),
                  icon: Icons.pets,
                  dificuldade: BotDifficulty.iniciante,
                ),
                const SizedBox(height: 12),

                // 🟡 Bot Intermediário
                _buildMenuButton(
                  context: context,
                  title: 'Bot Intermediário',
                  subtitle: 'Ganhe: +25 🏆 | +35 🪙',
                  color: const Color(0xFFF57F17),
                  icon: Icons.shield,
                  dificuldade: BotDifficulty.intermediario,
                ),
                const SizedBox(height: 12),

                // 🔴 Bot Difícil
                _buildMenuButton(
                  context: context,
                  title: 'Bot Estrategista',
                  subtitle: 'Ganhe: +50 🏆 | +70 🪙',
                  color: const Color(0xFFB71C1C),
                  icon: Icons.local_fire_department,
                  dificuldade: BotDifficulty.dificil,
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),

                // 🔒 MODO PVP ONLINE (APAGADO / EM BREVE)
                Opacity(
                  opacity: 0.5,
                  child: _buildMenuButton(
                    context: context,
                    title: 'Batalha PvP (Online)',
                    subtitle: 'Modo Multijogador - Em Breve!',
                    color: const Color.fromARGB(255, 192, 197, 255),
                    icon: Icons.thunderstorm,
                    dificuldade: null, // Desabilita clique
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget auxiliar para gerar as opções de modo dentro do pop-up
  Widget _buildMenuButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required BotDifficulty? dificuldade,
  }) {
    return ElevatedButton(
      onPressed: dificuldade == null 
          ? null 
          : () {
              Navigator.pop(context); // Fecha o pop-up primeiro
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BattleScreen(dificuldade: dificuldade),
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        elevation: 2,
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          if (dificuldade != null) const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mantido exatamente o seu logo original com a escala expandida
        ClipRect(
          child: SizedBox(
            width: 270,
            height: 270,
            child: Transform.scale(
              scale: 2.1,
              child: Image.asset(
                'assets/images/AniCard Icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 60),
        
        // BOTÃO BATTLE ORIGINAL (Preservado o visual e os efeitos de toque!)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Material(
            color: const Color(0xFF1B3620),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () => _abrirMenuModosDeJogo(context), // 🌟 Chama o pop-up de seleção de modo
              splashColor: const Color.fromARGB(255, 26, 218, 68).withOpacity(0.3),
              highlightColor: Colors.black.withOpacity(0.3),
              child: Container(
                width: 220,
                height: 65,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.5), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'BATTLE!',
                    style: TextStyle(
                      color: Color(0xFFB5C2B7),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}