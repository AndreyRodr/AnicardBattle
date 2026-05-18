import 'package:flutter/material.dart';
import '../screens/battle_screen.dart';

class BattleView extends StatelessWidget {
  const BattleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
        
        // BOTÃO BATTLE!
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
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
              onTap: () {
                Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => const BattleScreen())
                ); 
              },
              splashColor: const Color.fromARGB(255, 26, 218, 68).withValues(alpha: 0.3),
              highlightColor: Colors.black.withValues(alpha: 0.3),
              child: Container(
                width: 220,
                height: 65,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withValues(alpha: 0.5), width: 2),
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