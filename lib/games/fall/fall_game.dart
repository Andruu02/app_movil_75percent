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
  bool _isGameOver     = false;
  bool _platformsReady = false;

  double scrollSpeed = 80.0;
  static const double maxScrollSpeed      = 260.0;
  static const double scrollSpeedIncrease = 4.0;

  static const double platH       = 22.0;
  static const double platSpacing = 140.0;
  double _spawnTimer    = 0;
  double _spawnInterval = 1.6;

  double tiltValue = 0;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await images.loadAll([spriteBola]);
    ball = FallBallComponent(spriteName: spriteBola);
    add(ball);
    overlays.add('hud');
    overlays.add('backButton');
    overlays.add('pauseButton');
    overlays.add('controls');
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (!_platformsReady && gameSize.x > 0 && gameSize.y > 0) {
      _platformsReady = true;
      _spawnInitialPlatforms(gameSize);
    }
  }

  void _spawnInitialPlatforms(Vector2 gameSize) {
    final List<double> positions = [];

    double y = gameSize.y / 2;
    while (y <= gameSize.y + platH) {
      positions.add(y);
      y += platSpacing;
    }

    for (final posY in positions) {
      add(FallPlatformComponent(spawnY: posY));
    }

    // 👇 El timer arranca negativo para que espere
    // el tiempo equivalente al espaciado entre plataformas
    // antes de generar la siguiente, evitando la duplicación
    final lastY    = positions.last;
    final distToBottom = gameSize.y + platH - lastY;
    final timeToBottom = distToBottom / scrollSpeed;
    _spawnTimer = -timeToBottom;
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

    // Eliminar plataformas que salieron por arriba
    final toRemove = children
        .whereType<FallPlatformComponent>()
        .where((p) => p.position.y < -platH - 10)
        .toList();
    for (final p in toRemove) {
      scoreNotifier.value++;
      p.removeFromParent();
    }

    ball.applyTilt(tiltValue, dt);

    // Game over: bola aplastada contra el techo
    if (ball.position.y - FallBallComponent.radius <= 0) {
      triggerGameOver();
    }

    // Game over: bola cae fuera de pantalla por abajo
    if (ball.position.y - FallBallComponent.radius >= size.y) {
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
    overlays.remove('pauseButton');
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
    _spawnInitialPlatforms(size);
    ball.reset();

    overlays.remove('gameOver');
    overlays.add('hud');
    overlays.add('backButton');
    overlays.add('pauseButton');
    overlays.add('controls');
    resumeEngine();
  }
}