import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../fall_game.dart';

class FallCactusComponent extends SpriteComponent
    with HasGameRef<FallGame>, CollisionCallbacks {

  static const double cactusW = 42.0;
  static const double cactusH = 47.0; // proporcional a 159×178

  final double offsetX;

  FallCactusComponent({required this.offsetX});

  @override
  Future<void> onLoad() async {
    sprite   = await gameRef.loadSprite('cactus.png');
    size     = Vector2(cactusW, cactusH);
    // Justo encima de la plataforma (padre), sin ningún hueco
    position = Vector2(offsetX, -cactusH);

    add(RectangleHitbox(
      size:     Vector2(cactusW * 0.55, cactusH * 0.85),
      position: Vector2(cactusW * 0.225, cactusH * 0.08),
    ));
  }
}