import 'dart:math' as math;
import 'package:flutter/material.dart';

class PackExplosionWidget extends StatefulWidget {
  final String imagePath;
  final bool skipTriggered; // 🌟 Escuta o comando de skip vindo do pai
  final VoidCallback onExplosionComplete;

  const PackExplosionWidget({
    super.key,
    required this.imagePath,
    required this.skipTriggered,
    required this.onExplosionComplete,
  });

  @override
  State<PackExplosionWidget> createState() => _PackExplosionWidgetState();
}

class _PackExplosionWidgetState extends State<PackExplosionWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.4).chain(CurveTween(curve: Curves.elasticIn)), weight: 30),
    ]).animate(_animationController);

    _shakeAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.85, curve: Curves.linear),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 180.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.85, 0.95, curve: Curves.easeIn),
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onExplosionComplete();
      }
    });

    _animationController.forward();
  }

 // 🌟 FUNÇÃO DE INTERCEPTAÇÃO DE TOQUE ATUALIZADA
  @override
  void didUpdateWidget(covariant PackExplosionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.skipTriggered && !oldWidget.skipTriggered) {
      // Executa o avanço forçado de forma assíncrona após o frame terminar de montar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_animationController.isAnimating) {
          _animationController.forward(from: 1.0); // Vai direto para o fim (completo)
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        double shakeOffset = 0.0;
        if (_animationController.value > 0.2 && _animationController.value < 0.85) {
          shakeOffset = math.sin(_animationController.value * 50) * _shakeAnimation.value;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            if (_animationController.value > 0.4)
              Container(
                width: _glowAnimation.value,
                height: _glowAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(
                        (1.0 - (_animationController.value - 0.4) / 0.6).clamp(0.0, 1.0),
                      ),
                      blurRadius: 50,
                      spreadRadius: _glowAnimation.value / 2,
                    ),
                  ],
                ),
              ),

            Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: SizedBox(
                    width: 250, // Ligeiramente reduzido para garantir margem de segurança contra novos overflows
                    height: 360,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}