import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../games/catcher/catcher_game.dart';

class GameTwoScreen extends StatefulWidget {
  const GameTwoScreen({super.key});

  @override
  State<GameTwoScreen> createState() => _GameTwoScreenState();
}

class _GameTwoScreenState extends State<GameTwoScreen> {
  CatcherGame? _game;

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

    setState(() {
      _game = CatcherGame(
        idPersonaje:    idPersonaje,
        spriteHambre:   '${nombrePersonaje}_hambre.png',
        spriteComiendo: '${nombrePersonaje}_comiendo.png',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_game == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFBB00FF),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) {
        _game!.movePlayer(details.globalPosition.dx);
      },
      child: GameWidget(
        game: _game!,
        overlayBuilderMap: {

          // ── HUD ───────────────────────────────────────────────────────
          'hud': (context, game) {
            final catcher = game as CatcherGame;
            return Stack(
              children: [
                Positioned(
                  top: 12, left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/images/house.png', height: 52),
                  ),
                ),
                Positioned(
                  top: 20, right: 16,
                  child: ValueListenableBuilder<int>(
                    valueListenable: catcher.scoreNotifier,
                    builder: (_, score, __) => Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(offset: Offset(2, 2), color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },

          // ── Game Over ─────────────────────────────────────────────────
          'gameOver': (context, game) {
            final catcher = game as CatcherGame;
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
                            valueListenable: catcher.scoreNotifier,
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
      ),
    );
  }
}