import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../runner_game.dart';

class ObstacleComponent extends SpriteComponent
    with HasGameRef<RunnerGame>, CollisionCallbacks {

  final double offsetX;
  bool _scored = false;

  ObstacleComponent({this.offsetX = 0});

  @override
  Future<void> onLoad() async {
    // Único obstáculo: tnt.png
    sprite = await gameRef.loadSprite('tnt.png');

    size     = Vector2(55, 65);
    position = Vector2(
      gameRef.size.x + 60 + offsetX,
      gameRef.groundY - size.y + 8,   // apoyado en el suelo
    );

    add(RectangleHitbox(
      size:     Vector2(size.x * 0.68, size.y * 0.78),
      position: Vector2(size.x * 0.16, size.y * 0.11),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= gameRef.gameSpeed * dt;

    // Punto de puntaje: cuando el TNT pasa al jugador
    if (!_scored && position.x < gameRef.size.x * 0.15 - size.x) {
      _scored = true;
      gameRef.addScore();
    }

    if (position.x < -size.x - 20) removeFromParent();
  }
}