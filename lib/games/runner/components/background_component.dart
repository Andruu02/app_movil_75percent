import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../runner_game.dart';

class BackgroundComponent extends PositionComponent
    with HasGameRef<RunnerGame> {
  final List<_Cloud> _clouds = [];

  @override
  Future<void> onLoad() async {
    _recalcular();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    _recalcular();
  }

  void _recalcular() {
    size = gameRef.size;
    _clouds.clear();
    for (int i = 0; i < 5; i++) {
      _clouds.add(_Cloud(
        x:     gameRef.size.x * (i / 5.0) + 50,
        y:     gameRef.size.y * 0.15 + (i % 2) * 40,
        speed: 40.0 + i * 10,
        width: 80.0 + i * 15,
      ));
    }
  }

  @override
  void update(double dt) {
    for (final cloud in _clouds) {
      cloud.x -= cloud.speed * dt;
      if (cloud.x < -cloud.width) cloud.x = gameRef.size.x + 20;
    }
  }

  @override
  void render(Canvas canvas) {
    for (final cloud in _clouds) {
      _drawCloud(canvas, cloud.x, cloud.y, cloud.width);
    }
  }

  void _drawCloud(Canvas canvas, double x, double y, double w) {
    final paint = Paint()..color = Colors.white.withOpacity(0.85);
    final h = w * 0.45;
    canvas.drawOval(Rect.fromLTWH(x, y, w, h), paint);
    canvas.drawOval(
        Rect.fromLTWH(x + w * 0.15, y - h * 0.3, w * 0.55, h * 0.7), paint);
    canvas.drawOval(
        Rect.fromLTWH(x + w * 0.5, y - h * 0.1, w * 0.4, h * 0.6), paint);
  }
}

class _Cloud {
  double x, y, speed, width;
  _Cloud({required this.x, required this.y, required this.speed, required this.width});
}