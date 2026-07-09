import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/player_component.dart';
import 'components/obstacle_component.dart';
import 'components/ground_component.dart';
import 'components/background_component.dart';
import '../../services/partida_service.dart';

class RunnerGame extends FlameGame with TapCallbacks, HasCollisionDetection {

  final int    idPersonaje;
  final String spriteMonoName;       // "vianne_mono.png"
  final String spriteGritoMonoName;  // "vianne_grito_mono.png"

  RunnerGame({
    this.idPersonaje          = 1,
    this.spriteMonoName       = 'vianne_mono.png',
    this.spriteGritoMonoName  = 'vianne_grito_mono.png',
  });

  late PlayerComponent player;

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  int get score => scoreNotifier.value;

  double gameSpeed = 220;
  static const double maxGameSpeed      = 600;
  static const double speedIncreaseRate = 10;

  double _spawnTimer    = 0;
  double _spawnInterval = 1.8;
  final  Random _random = Random();
  bool _isGameOver      = false;

  static const double groundHeight = 80;
  double get groundY => size.y - groundHeight;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await images.loadAll([spriteMonoName, spriteGritoMonoName, 'tnt.png']);

    add(BackgroundComponent());
    add(GroundComponent());

    player = PlayerComponent(
      spriteMonoName:       spriteMonoName,
      spriteGritoMonoName:  spriteGritoMonoName,
    );
    add(player);

    overlays.add('score');
    overlays.add('backButton');
  }

  @override
  void update(double dt) {
    if (_isGameOver) return;
    super.update(dt);

    if (gameSpeed < maxGameSpeed) gameSpeed += speedIncreaseRate * dt;
    _spawnInterval = (_spawnInterval - dt * 0.008).clamp(0.6, 1.8);

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnObstacle();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_isGameOver) player.onTap();
  }

  void _spawnObstacle() {
    final count = (gameSpeed > 380 && _random.nextBool()) ? 2 : 1;
    for (int i = 0; i < count; i++) {
      add(ObstacleComponent(offsetX: i * 62.0));
    }
  }

  void addScore() {
    scoreNotifier.value++;
    if (scoreNotifier.value % 2 == 0) {
      gameSpeed = (gameSpeed + 10).clamp(0, maxGameSpeed);
      _spawnInterval = (_spawnInterval - 0.08).clamp(0.4, 1.8);
    }
  }

  void triggerGameOver() {
    if (_isGameOver) return;
    _isGameOver = true;

    PartidaService.guardarPartida(
      juego:       'runner',
      puntaje:     score,
      idPersonaje: idPersonaje,
    );

    pauseEngine();
    overlays.remove('score');
    overlays.remove('backButton');
    overlays.add('gameOver');
  }

  void resetGame() {
    _isGameOver         = false;
    scoreNotifier.value = 0;
    gameSpeed           = 220;
    _spawnTimer         = 0;
    _spawnInterval      = 1.8;

    children.whereType<ObstacleComponent>().toList().forEach(remove);
    player.reset();

    overlays.remove('gameOver');
    overlays.add('score');
    overlays.add('backButton');
    resumeEngine();
  }
}