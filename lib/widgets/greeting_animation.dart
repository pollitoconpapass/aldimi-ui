import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/palette.dart';

class GreetingAnimation extends StatefulWidget {
  const GreetingAnimation({super.key});

  @override
  State<GreetingAnimation> createState() => _GreetingAnimationState();
}

class _GreetingAnimationState extends State<GreetingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  String _currentGreeting = '';
  int _charIndex = 0;
  Timer? _typewriterTimer;
  bool _done = false;

  static const List<String> _greetings = [
    'Hola! Soy tu asistente medico virtual. En que puedo ayudarte hoy?',
    'Bienvenido! Estoy aqui para cuidar de ti. Que necesitas?',
    'Hola! Listo para tu consulta? Preguntame lo que quieras.',
    'Hey! Tu salud es mi prioridad. En que te ayudo?',
    'Hola! Me alegra verte. Cuéntame, como te sientes hoy?',
    'Bienvenido de vuelta! Tu asistente de salud favorito esta aqui.',
    'Hola! Hoy es un gran dia para cuidar de ti. Que necesitas?',
    'Hey! Estoy aqui para escucharte. Que te trae por aqui?',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _start();
  }

  void _start() {
    final random = Random();
    _currentGreeting = _greetings[random.nextInt(_greetings.length)];
    _charIndex = 0;
    _done = false;
    _controller.forward(from: 0);

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 35), (
      timer,
    ) {
      if (_charIndex < _currentGreeting.length) {
        setState(() {
          _charIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          _done = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ALDIMI ASSIST',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: deepTeal,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxWidth: 340),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: _currentGreeting.substring(0, _charIndex),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: deepTeal,
                      ),
                      children: [
                        if (!_done)
                          TextSpan(
                            text: '|',
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryBlue.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Escribe tu pregunta abajo para comenzar',
                  style: TextStyle(
                    fontSize: 13,
                    color: deepTeal.withValues(alpha: 0.5),
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
