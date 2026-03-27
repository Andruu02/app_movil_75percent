import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../runner_game.dart';
import 'obstacle_component.dart';

class PlayerComponent extends PositionComponent
    with HasGameRef<RunnerGame>, CollisionCallbacks {

  // ── Física ─────────────────────────────────────────────────────────────────
  double _velocityY   = 0;
  bool   _onGround    = true;
  bool   _fastFalling = false;

  static const double gravity      = 900;
  static const double jumpForce    = -480;
  static const double fastFallMult = 3.5;
  static const double playerXRatio = 0.15;
  static const int    frameCount   = 2;

  // ── Nombres de assets ──────────────────────────────────────────────────────
  final String spriteMonoName;
  final String spriteGritoMonoName;

  // ── Sub-componentes de sprite ──────────────────────────────────────────────
  late SpriteComponent          _groundSprite;
  late SpriteAnimationComponent _airAnim;

  PlayerComponent({
    required this.spriteMonoName,
    required this.spriteGritoMonoName,
  });

  @override
  Future<void> onLoad() async {
    size = Vector2(80, 100);
    position = Vector2(
      gameRef.size.x * playerXRatio,
      gameRef.groundY - size.y,
    );

    // ── Sprite de piso ───────────────────────────────────────────────────────
    final monoSprite = await gameRef.loadSprite(spriteMonoName);
    _groundSprite = SpriteComponent(sprite: monoSprite, size: size);

    // ── Sprite de aire: spritesheet 600×590, 2 frames → cada frame 300×590 ──
    final airAnimation = await gameRef.loadSpriteAnimation(
      spriteGritoMonoName,
      SpriteAnimationData.sequenced(
        amount:      frameCount,
        stepTime:    0.12,
        textureSize: Vector2(300, 590),
        loop:        true,
      ),
    );
    _airAnim = SpriteAnimationComponent(animation: airAnimation, size: size);

    add(_groundSprite);

    add(RectangleHitbox(
      size:     Vector2(size.x * 0.60, size.y * 0.80),
      position: Vector2(size.x * 0.20, size.y * 0.10),
    ));
  }

  // Al rotar la pantalla, reposicionar el jugador al suelo nuevo
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (!isLoaded) return;
    // Solo reposicionar X (siempre al 15% del ancho) y Y al nuevo suelo
    position = Vector2(
      gameSize.x * playerXRatio,
      gameRef.groundY - size.y,
    );
    // Si estaba en el aire, forzar aterrizaje para evitar quedar flotando
    if (!_onGround) {
      _velocityY   = 0;
      _onGround    = true;
      _fastFalling = false;
      _showGround();
    }
  }

  // ── API pública ────────────────────────────────────────────────────────────
  void onTap() {
    if (_onGround) {
      _velocityY   = jumpForce;
      _onGround    = false;
      _fastFalling = false;
      _showAir();
    } else if (!_fastFalling) {
      _fastFalling = true;
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);

    final g = _fastFalling ? gravity * fastFallMult : gravity;
    _velocityY += g * dt;
    position.y += _velocityY * dt;

    final groundLimit = gameRef.groundY - size.y;
    if (position.y >= groundLimit) {
      position.y   = groundLimit;
      _velocityY   = 0;
      _fastFalling = false;
      if (!_onGround) {
        _onGround = true;
        _showGround();
      }
    }
  }

  // ── Colisión ───────────────────────────────────────────────────────────────
  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is ObstacleComponent) gameRef.triggerGameOver();
  }

  // ── Reset ──────────────────────────────────────────────────────────────────
  void reset() {
    _velocityY   = 0;
    _onGround    = true;
    _fastFalling = false;
    position = Vector2(
      gameRef.size.x * playerXRatio,
      gameRef.groundY - size.y,
    );
    _showGround();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _showGround() {
    if (_airAnim.isMounted)       _airAnim.removeFromParent();
    if (!_groundSprite.isMounted) add(_groundSprite);
  }

  void _showAir() {
    if (_groundSprite.isMounted) _groundSprite.removeFromParent();
    if (!_airAnim.isMounted)     add(_airAnim);
  }
}