import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../catcher_game.dart';

class CatcherGroundComponent extends PositionComponent
    with HasGameRef<CatcherGame> {

  @override
  Future<void> onLoad() async {
    position = Vector2(0, gameRef.groundY);
    size     = Vector2(gameRef.size.x, CatcherGame.groundHeight);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFFEB3B),
    );
  }
}
