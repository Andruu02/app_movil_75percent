import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../fall_game.dart';

class FallPlatformComponent extends PositionComponent
    with HasGameRef<FallGame> {

  static final Random _rng = Random();

  // Tamaño del hueco por donde cae la bola
  static const double gapWidth    = 90.0;
  // Mínimo margen del hueco respecto al borde
  static const double gapMargin   = 20.0;

  final double spawnY;

  // Dos segmentos: izquierdo y derecho del hueco
  late double _gapStart; // X donde empieza el hueco

  FallPlatformComponent({required this.spawnY});

  @override
  Future<void> onLoad() async {
    // Posición Y de la plataforma
    position = Vector2(0, spawnY);
    size     = Vector2(gameRef.size.x, FallGame.platH);

    // Hueco aleatorio (no en los extremos)
    final maxStart = gameRef.size.x - gapWidth - gapMargin;
    _gapStart = gapMargin + _rng.nextDouble() * (maxStart - gapMargin);

    // Segmento izquierdo
    if (_gapStart > 0) {
      add(RectangleHitbox(
        size:     Vector2(_gapStart, FallGame.platH),
        position: Vector2(0, 0),
        isSolid:  true,
      ));
    }

    // Segmento derecho
    final rightStart = _gapStart + gapWidth;
    final rightWidth = gameRef.size.x - rightStart;
    if (rightWidth > 0) {
      add(RectangleHitbox(
        size:     Vector2(rightWidth, FallGame.platH),
        position: Vector2(rightStart, 0),
        isSolid:  true,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Subir continuamente
    position.y -= gameRef.scrollSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    final paint      = Paint()..color = const Color(0xFF4CAF50);
    final paintEdge  = Paint()..color = const Color(0xFF388E3C);

    // Segmento izquierdo
    if (_gapStart > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, _gapStart, FallGame.platH),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, 0, _gapStart, 4),
        paintEdge,
      );
    }

    // Segmento derecho
    final rightStart = _gapStart + gapWidth;
    final rightWidth = gameRef.size.x - rightStart;
    if (rightWidth > 0) {
      canvas.drawRect(
        Rect.fromLTWH(rightStart, 0, rightWidth, FallGame.platH),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(rightStart, 0, rightWidth, 4),
        paintEdge,
      );
    }
  }

  // Getters para la colisión manual
  double get gapLeft  => _gapStart;
  double get gapRight => _gapStart + gapWidth;
  double get topY     => position.y;
  double get bottomY  => position.y + FallGame.platH;
}