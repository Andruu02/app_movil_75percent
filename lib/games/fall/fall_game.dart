import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/fall_ball_component.dart';
import 'components/fall_platform_component.dart';
import '../../services/partida_service.dart';

class FallGame extends FlameGame with HasCollisionDetection {

  final int    idPersonaje;
  final String spriteBola;

  FallGame({
    this.idPersonaje = 1,
    this.spriteBola  = 'vianne_bola.png',
  });

  late FallBallComponent ball;

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  bool _isGameOver = false;

  // ════════════════════════════════════════════════════════════════════
  //  VELOCIDAD DE LAS PLATAFORMAS
  //  scrollSpeed      = velocidad inicial (px/seg que suben)
  //  maxScrollSpeed   = velocidad máxima que puede alcanzar
  //  scrollSpeedIncrease = cuánto aumenta por segundo
  //
  //  Sube estos valores para que el juego sea más difícil desde el inicio
  //  o baja scrollSpeedIncrease para que tarde más en acelerarse.
  // ════════════════════════════════════════════════════════════════════
  double scrollSpeed = 80.0;              // ← velocidad inicial
  static const double maxScrollSpeed       = 260.0; // ← velocidad máxima
  static const double scrollSpeedIncrease  = 4.0;   // ← aceleración por seg

  // ── Generación de plataformas ─────────────────────────────────────
  static const double platH        = 22.0;
  static const double platSpacing  = 140.0;
  double _spawnTimer    = 0;
  double _spawnInterval = 1.6;

  double tiltValue = 0;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await images.loadAll([spriteBola]);
    _spawnInitialPlatforms();
    ball = FallBallComponent(spriteName: spriteBola);
    add(ball);
    overlays.add('hud');
    overlays.add('backButton');
    overlays.add('controls');
  }

  void _spawnInitialPlatforms() {
    // Primera plataforma a la mitad de pantalla para dar tiempo de reacción
    double y = size.y - platH;
    while (y > -platSpacing) {
      add(FallPlatformComponent(spawnY: y));
      y -= platSpacing;
    }
  }

  @override
  void update(double dt) {
    if (_isGameOver) return;
    super.update(dt);

    if (scrollSpeed < maxScrollSpeed) {
      scrollSpeed += scrollSpeedIncrease * dt;
    }
    _spawnInterval = (_spawnInterval - dt * 0.003).clamp(1.0, 1.6);

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      add(FallPlatformComponent(spawnY: size.y + platH));
    }

    // Eliminar plataformas que ya salieron por arriba
    final toRemove = children
        .whereType<FallPlatformComponent>()
        .where((p) => p.position.y < -platH - 10)
        .toList();
    for (final p in toRemove) {
      scoreNotifier.value++;
      p.removeFromParent();
    }

    ball.applyTilt(tiltValue, dt);

    // Game over: bola aplastada contra el techo por una plataforma
    if (ball.position.y - FallBallComponent.radius <= 0) {
      triggerGameOver();
    }
  }

  void updateTilt(double value) => tiltValue = value.clamp(-1.0, 1.0);

  void triggerGameOver() {
    if (_isGameOver) return;
    _isGameOver = true;

    PartidaService.guardarPartida(
      juego:       'fall',
      puntaje:     scoreNotifier.value,
      idPersonaje: idPersonaje,
    );

    pauseEngine();
    overlays.remove('hud');
    overlays.remove('backButton');
    overlays.remove('controls');
    overlays.add('gameOver');
  }

  void resetGame() {
    _isGameOver    = false;
    scoreNotifier.value = 0;
    scrollSpeed    = 80.0;
    _spawnTimer    = 0;
    _spawnInterval = 1.6;
    tiltValue      = 0;

    children.whereType<FallPlatformComponent>().toList().forEach(remove);
    _spawnInitialPlatforms();
    ball.reset();

    overlays.remove('gameOver');
    overlays.add('hud');
    overlays.add('backButton');
    overlays.add('controls');
    resumeEngine();
  }
}