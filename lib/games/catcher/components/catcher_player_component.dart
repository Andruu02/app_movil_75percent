import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../catcher_game.dart';
import 'falling_object_component.dart';

class CatcherPlayerComponent extends PositionComponent
    with HasGameRef<CatcherGame>, CollisionCallbacks {

  static const double playerWidth   = 120.0;
  static const double playerHeight  = 160.0;
  static const double lerpSpeed     = 18.0;
  static const int    frameCount    = 2;    // 780px / 2 frames = 390px por frame
  static const double frameW        = 390;  // 780 / 2
  static const double frameH        = 590;
  static const double eatDuration   = 0.6;  // segundos mostrando "comiendo"

  final String spriteHambreName;    // "vianne_hambre.png"
  final String spriteComiendoName;  // "vianne_comiendo.png"

  double _targetX    = 0;
  double _eatTimer   = 0;
  bool   _isEating   = false;

  late SpriteAnimationComponent _hambreAnim;
  late SpriteAnimationComponent _comiendoAnim;

  CatcherPlayerComponent({
    required this.spriteHambreName,
    required this.spriteComiendoName,
  });

  @override
  Future<void> onLoad() async {
    size = Vector2(playerWidth, playerHeight);

    _targetX = gameRef.size.x / 2 - playerWidth / 2;
    position = Vector2(_targetX, gameRef.groundY - playerHeight);

    // ── Animación hambre (idle) ───────────────────────────────────────────────
    final hambreAnim = await gameRef.loadSpriteAnimation(
      spriteHambreName,
      SpriteAnimationData.sequenced(
        amount:      frameCount,
        stepTime:    0.18,
        textureSize: Vector2(frameW, frameH),
        loop:        true,
      ),
    );
    _hambreAnim = SpriteAnimationComponent(
      animation: hambreAnim,
      size:      size,
    );

    // ── Animación comiendo (al atrapar comida) ────────────────────────────────
    final comiendoAnim = await gameRef.loadSpriteAnimation(
      spriteComiendoName,
      SpriteAnimationData.sequenced(
        amount:      frameCount,
        stepTime:    0.12,
        textureSize: Vector2(frameW, frameH),
        loop:        true,
      ),
    );
    _comiendoAnim = SpriteAnimationComponent(
      animation: comiendoAnim,
      size:      size,
    );

    // Empieza con hambre
    add(_hambreAnim);

    // Hitbox en la parte superior del personaje (donde "atrapa")
    add(RectangleHitbox(
      size:     Vector2(playerWidth * 0.85, playerHeight * 0.30),
      position: Vector2(playerWidth * 0.075, 0),
    ));
  }

  // ── Mover con deslizamiento ───────────────────────────────────────────────
  void moveTo(double touchX) {
    _targetX = (touchX - playerWidth / 2)
        .clamp(0.0, gameRef.size.x - playerWidth);
  }

  // ── Llamar cuando atrapa comida buena ─────────────────────────────────────
  void triggerEating() {
    _isEating = true;
    _eatTimer = eatDuration;
    _showComiendo();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Movimiento suave
    position.x += (_targetX - position.x) * lerpSpeed * dt;

    // Temporizador de "comiendo"
    if (_isEating) {
      _eatTimer -= dt;
      if (_eatTimer <= 0) {
        _isEating = false;
        _showHambre();
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is FallingObjectComponent && !other.caught) {
      other.caught = true;
      gameRef.objectCaught(other.type);
      other.removeFromParent();
    }
  }

  void reset() {
    _targetX  = gameRef.size.x / 2 - playerWidth / 2;
    position  = Vector2(_targetX, gameRef.groundY - playerHeight);
    _isEating = false;
    _eatTimer = 0;
    _showHambre();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _showHambre() {
    if (_comiendoAnim.isMounted)  _comiendoAnim.removeFromParent();
    if (!_hambreAnim.isMounted)   add(_hambreAnim);
  }

  void _showComiendo() {
    if (_hambreAnim.isMounted)    _hambreAnim.removeFromParent();
    if (!_comiendoAnim.isMounted) add(_comiendoAnim);
  }
}