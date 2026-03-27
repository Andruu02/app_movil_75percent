import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../fall_game.dart';
import 'fall_platform_component.dart';

class FallBallComponent extends PositionComponent
    with HasGameRef<FallGame>, CollisionCallbacks {

  static const double radius      = 30.0;
  static const double diameter    = radius * 2;
  static const double maxLateral  = 260.0;
  static const double gravity     = 700.0;
  static const double maxFallSpd  = 900.0;
  static const double rotPerPixel = 1.0 / radius;

  // Spritesheet 870×1120, 3 cols × 4 filas, 10 frames
  static const int    cols   = 3;
  static const double frameW = 290.0;
  static const double frameH = 280.0;
  static const int    frames = 10;

  final String spriteName;

  double _vy        = 0;
  double _vx        = 0;
  bool   _onGround  = false;
  double _ballAngle = 0;

  // Nullable para evitar LateInitializationError
  SpriteAnimationComponent? _anim;

  FallBallComponent({required this.spriteName});

  @override
  Future<void> onLoad() async {
    size   = Vector2(diameter, diameter);
    anchor = Anchor.center;
    position = Vector2(gameRef.size.x / 2, radius + 10);

    final image      = await gameRef.images.load(spriteName);
    final spriteList = <Sprite>[];
    for (int i = 0; i < frames; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      spriteList.add(Sprite(
        image,
        srcPosition: Vector2(col * frameW, row * frameH),
        srcSize:     Vector2(frameW, frameH),
      ));
    }

    final anim = SpriteAnimationComponent(
      animation: SpriteAnimation.spriteList(spriteList, stepTime: 0.07),
      size:      size,
      anchor:    Anchor.center,
      position:  Vector2(radius, radius),
    );
    _anim = anim;
    add(anim);

    add(CircleHitbox(
      radius:        radius * 0.88,
      anchor:        Anchor.center,
      collisionType: CollisionType.active,
    ));
  }

  void applyTilt(double tilt, double dt) {
    _vx         = tilt * maxLateral;
    final dx    = _vx * dt;
    position.x += dx;

    _ballAngle     += dx * rotPerPixel;
    _anim?.angle    = _ballAngle; // ← ? evita el error si aún no cargó

    if (position.x < radius)                  position.x = radius;
    if (position.x > gameRef.size.x - radius) position.x = gameRef.size.x - radius;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_onGround) {
      _vy = (_vy + gravity * dt).clamp(-maxFallSpd, maxFallSpd);
    }
    position.y += _vy * dt;
    _onGround = false;

    for (final plat in gameRef.children.whereType<FallPlatformComponent>()) {
      final ballBottom = position.y + radius;
      final ballTop    = position.y - radius;
      final ballLeft   = position.x - radius;
      final ballRight  = position.x + radius;

      final platTop    = plat.topY;
      final platBottom = plat.bottomY;

      final vertOverlap = ballBottom >= platTop && ballTop <= platBottom;
      if (!vertOverlap) continue;

      final inGap = ballLeft > plat.gapLeft - 4 && ballRight < plat.gapRight + 4;
      if (inGap) continue;

      final overlapLeft  = ballRight > 0             && ballLeft  < plat.gapLeft;
      final overlapRight = ballRight > plat.gapRight  && ballLeft < gameRef.size.x;
      if (!overlapLeft && !overlapRight) continue;

      if (_vy >= 0 && ballBottom - platTop < radius + 8) {
        position.y = platTop - radius;
        _vy        = 0;
        _onGround  = true;
        break;
      }

      if (_vy < 0 && platBottom - ballTop < radius + 8) {
        position.y = platBottom + radius;
        _vy        = _vy.abs() * 0.3;
        break;
      }
    }

    if (_onGround && _vx.abs() < 5) {
      _ballAngle  *= 0.88;
      _anim?.angle = _ballAngle;
    }
  }

  void reset() {
    _vy        = 0;
    _vx        = 0;
    _onGround  = false;
    _ballAngle = 0;
    _anim?.angle = 0; // ← ? evita el error si aún no cargó
    position   = Vector2(gameRef.size.x / 2, radius + 10);
  }
}