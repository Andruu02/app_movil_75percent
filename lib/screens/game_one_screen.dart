import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../games/runner/runner_game.dart';

class GameOneScreen extends StatefulWidget {
  const GameOneScreen({super.key});

  @override
  State<GameOneScreen> createState() => _GameOneScreenState();
}

class _GameOneScreenState extends State<GameOneScreen> {
  RunnerGame? _game;

  @override
  void initState() {
    super.initState();
    // Forzar horizontal al entrar al runner
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initGame();
  }

  @override
  void dispose() {
    // Restaurar portrait al salir
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _initGame() async {
    final prefs           = await SharedPreferences.getInstance();
    final idPersonaje     = prefs.getInt('personaje_id') ?? 1;
    final nombrePersonaje =
        (prefs.getString('personaje_nombre') ?? 'vianne').toLowerCase();

    setState(() {
      _game = RunnerGame(
        idPersonaje:         idPersonaje,
        spriteMonoName:      '${nombrePersonaje}_mono.png',
        spriteGritoMonoName: '${nombrePersonaje}_grito_mono.png',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_game == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF87CEEB),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return GameWidget(
      game: _game!,
      overlayBuilderMap: {

        // ── Puntuación ───────────────────────────────────────────────────
        'score': (context, game) {
          final runner = game as RunnerGame;
          return Positioned(
            top: 12, right: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: runner.scoreNotifier,
              builder: (_, score, __) => Text(
                '$score',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(2, 2), color: Colors.black54)],
                ),
              ),
            ),
          );
        },

        // ── Botón volver ─────────────────────────────────────────────────
        'backButton': (context, game) {
          return Positioned(
            top: 8, left: 8,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset('assets/images/house.png', height: 48),
            ),
          );
        },

        // ── Game Over ────────────────────────────────────────────────────
        'gameOver': (context, game) {
          final runner = game as RunnerGame;
          return Container(
            width: double.infinity, height: double.infinity,
            color: const Color(0xFFE53935),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 8, left: 8,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/images/house.png', height: 48),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/emoji_cry.png', height: 120),
                        const SizedBox(width: 48),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GAME OVER',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ValueListenableBuilder<int>(
                              valueListenable: runner.scoreNotifier,
                              builder: (_, score, __) => Text(
                                '¡Alcanzaste $score puntos!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            GestureDetector(
                              onTap: () => _game!.resetGame(),
                              child: Image.asset('assets/images/retry.png', height: 70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      },
      initialActiveOverlays: const ['score', 'backButton'],
    );
  }
}