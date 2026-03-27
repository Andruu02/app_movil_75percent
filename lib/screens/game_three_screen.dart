import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../games/fall/fall_game.dart';

class GameThreeScreen extends StatefulWidget {
  const GameThreeScreen({super.key});

  @override
  State<GameThreeScreen> createState() => _GameThreeScreenState();
}

class _GameThreeScreenState extends State<GameThreeScreen> {
  FallGame? _game;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _arrowTilt = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    final prefs           = await SharedPreferences.getInstance();
    final idPersonaje     = prefs.getInt('personaje_id') ?? 1;
    final nombrePersonaje =
        (prefs.getString('personaje_nombre') ?? 'vianne').toLowerCase();

    final game = FallGame(
      idPersonaje: idPersonaje,
      spriteBola:  '${nombrePersonaje}_bola.png',
    );

    // Giroscopio — prioridad sobre flechas cuando hay celular físico
    try {
      _accelSub = accelerometerEventStream().listen((event) {
        final tilt = (-event.x / 9.8).clamp(-1.0, 1.0);
        game.updateTilt(tilt);
      });
    } catch (_) {}

    if (mounted) setState(() => _game = game);
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  void _startLeft()  { _arrowTilt = -1.0; _game?.updateTilt(_arrowTilt); }
  void _startRight() { _arrowTilt =  1.0; _game?.updateTilt(_arrowTilt); }
  void _stopArrow()  { _arrowTilt =  0.0; _game?.updateTilt(0); }

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

        // ── HUD ───────────────────────────────────────────────────────────
        'hud': (context, game) {
          final fall = game as FallGame;
          return Positioned(
            top: 20, right: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: fall.scoreNotifier,
              builder: (_, score, __) => Text(
                '$score',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(2, 2), color: Colors.black38)],
                ),
              ),
            ),
          );
        },

        // ── Botón volver ──────────────────────────────────────────────────
        'backButton': (context, game) {
          return Positioned(
            top: 12, left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset('assets/images/house.png', height: 52),
            ),
          );
        },

        // ── Flechas (temporales hasta tener giroscopio) ───────────────────
        'controls': (context, game) {
          return Positioned(
            bottom: 40, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTapDown:   (_) => _startLeft(),
                  onTapUp:     (_) => _stopArrow(),
                  onTapCancel: ()  => _stopArrow(),
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 38),
                  ),
                ),
                GestureDetector(
                  onTapDown:   (_) => _startRight(),
                  onTapUp:     (_) => _stopArrow(),
                  onTapCancel: ()  => _stopArrow(),
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 38),
                  ),
                ),
              ],
            ),
          );
        },

        // ── Game Over ─────────────────────────────────────────────────────
        'gameOver': (context, game) {
          final fall = game as FallGame;
          return Container(
            width: double.infinity, height: double.infinity,
            color: const Color(0xFFE53935),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/images/house.png', height: 50),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/emoji_cry.png', height: 130),
                        const SizedBox(height: 32),
                        const Text(
                          'GAME OVER',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ValueListenableBuilder<int>(
                          valueListenable: fall.scoreNotifier,
                          builder: (_, score, __) => Text(
                            '¡Alcanzaste $score\npuntos!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),
                        GestureDetector(
                          onTap: () => _game!.resetGame(),
                          child: Image.asset('assets/images/retry.png', height: 80),
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
      initialActiveOverlays: const [],
    );
  }
}