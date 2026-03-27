import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/catcher_player_component.dart';
import 'components/falling_object_component.dart';
import 'components/catcher_ground_component.dart';
import '../../services/partida_service.dart';

enum ObjectType { good, bad }

class CatcherGame extends FlameGame with HasCollisionDetection {

  final int    idPersonaje;
  final String spriteHambre;    // "vianne_hambre.png"
  final String spriteComiendo;  // "vianne_comiendo.png"

  CatcherGame({
    this.idPersonaje    = 1,
    this.spriteHambre   = 'vianne_hambre.png',
    this.spriteComiendo = 'vianne_comiendo.png',
  });

  late CatcherPlayerComponent player;

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  int get score => scoreNotifier.value;

  double _spawnTimer     = 0;
  double _spawnInterval  = 1.4;
  double objectFallSpeed = 250;
  static const double maxFallSpeed      = 550;
  static const double fallSpeedIncrease = 6;

  final Random _random = Random();
  bool _isGameOver     = false;

  static const double groundHeight = 90;
  double get groundY => size.y - groundHeight;

  @override
  Color backgroundColor() => const Color(0xFFBB00FF);

  @override
  Future<void> onLoad() async {
    // Pre-cargar todos los assets necesarios
    await images.loadAll([
      spriteHambre,
      spriteComiendo,
      ...goodObjects,
      ...badObjects,
    ]);

    add(CatcherGroundComponent());
    player = CatcherPlayerComponent(
      spriteHambreName:   spriteHambre,
      spriteComiendoName: spriteComiendo,
    );
    add(player);

    overlays.add('hud');
  }

  @override
  void update(double dt) {
    if (_isGameOver) return;
    super.update(dt);

    if (objectFallSpeed < maxFallSpeed) {
      objectFallSpeed += fallSpeedIncrease * dt;
    }

    _spawnInterval = (_spawnInterval - dt * 0.005).clamp(0.6, 1.4);

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnFallingObject();
    }
  }

  void movePlayer(double globalX) {
    if (!_isGameOver) player.moveTo(globalX);
  }

  void _spawnFallingObject() {
    final isBad = _random.nextDouble() < 0.30;
    final type  = isBad ? ObjectType.bad : ObjectType.good;
    final x     = _random.nextDouble() * (size.x - 60) + 30;
    add(FallingObjectComponent(type: type, startX: x));
  }

  void objectCaught(ObjectType type) {
    if (type == ObjectType.bad) {
      triggerGameOver();
    } else {
      scoreNotifier.value++;
      player.triggerEating(); // ← cambiar sprite a "comiendo"
    }
  }

  void objectMissed(ObjectType type) {}

  void triggerGameOver() {
    if (_isGameOver) return;
    _isGameOver = true;

    PartidaService.guardarPartida(
      juego:       'catcher',
      puntaje:     score,
      idPersonaje: idPersonaje,
    );

    pauseEngine();
    overlays.remove('hud');
    overlays.add('gameOver');
  }

  void resetGame() {
    _isGameOver         = false;
    scoreNotifier.value = 0;
    objectFallSpeed     = 250;
    _spawnTimer         = 0;
    _spawnInterval      = 1.4;
    children.whereType<FallingObjectComponent>().toList().forEach(remove);
    player.reset();
    overlays.remove('gameOver');
    overlays.add('hud');
    resumeEngine();
  }
}