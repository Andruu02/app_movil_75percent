import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../catcher_game.dart';

// ════════════════════════════════════════════════════════════════════════════
//  CONFIGURA AQUÍ LOS OBJETOS QUE CAEN
//  - goodObjects: comidas que suman punto al atraparlas
//  - badObjects:  objetos que terminan el juego al atraparlos
//
//  Solo agrega o quita el nombre del archivo PNG en la lista correspondiente.
//  Todos los PNG deben estar en assets/images/
// ════════════════════════════════════════════════════════════════════════════

const List<String> goodObjects = [
  'burger.png',
  'pollo.png',
  'chuleta.png',
  'sandia.png',
  // 👇 agrega más comidas aquí:
  // 'pizza.png',
  // 'hotdog.png',
];

const List<String> badObjects = [
  'bomb.png',
  // 👇 agrega más objetos malos aquí (solo si quieres):
];

// ════════════════════════════════════════════════════════════════════════════
//  TAMAÑOS INDIVIDUALES POR OBJETO (ancho × alto en píxeles de pantalla)
//  Si agregas una comida nueva arriba, ponle su tamaño aquí también.
//  Si no está en el mapa, usará el tamaño por defecto: 52×52
// ════════════════════════════════════════════════════════════════════════════

final Map<String, Vector2> _objectSizes = {
  // burger: 150×90 → ratio 1.667 (ancho/alto) → 60×36
  'burger.png':  Vector2(60, 36),

  // pollo: 200×109 → ratio 1.835 → 60×33
  'pollo.png':   Vector2(60, 33),

  // chuleta: 130×160 → ratio 0.8125 → 49×60
  'chuleta.png': Vector2(49, 60),

  // sandia: 140×151 → ratio 0.927 → 56×60
  'sandia.png':  Vector2(56, 60),

  'bomb.png':    Vector2(48, 62),
};

// ════════════════════════════════════════════════════════════════════════════

class FallingObjectComponent extends SpriteComponent
    with HasGameRef<CatcherGame>, CollisionCallbacks {

  final ObjectType type;
  final double startX;
  bool caught = false;

  double _wobbleTime = 0;
  final double _wobbleAmplitude;
  final double _wobbleFrequency;

  static final Random _random = Random();

  FallingObjectComponent({required this.type, required this.startX})
      : _wobbleAmplitude = _random.nextDouble() * 14,
        _wobbleFrequency = 1.5 + _random.nextDouble() * 1.5;

  @override
  Future<void> onLoad() async {
    final spriteName = type == ObjectType.good
        ? goodObjects[_random.nextInt(goodObjects.length)]
        : badObjects[_random.nextInt(badObjects.length)];

    sprite   = await gameRef.loadSprite(spriteName);
    size     = _objectSizes[spriteName] ?? Vector2(52, 52); // tamaño individual
    position = Vector2(startX - size.x / 2, -size.y);

    add(RectangleHitbox(
      size:     Vector2(size.x * 0.75, size.y * 0.75),
      position: Vector2(size.x * 0.125, size.y * 0.125),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (caught) return;

    position.y += gameRef.objectFallSpeed * dt;
    _wobbleTime += dt;
    position.x = startX - size.x / 2
        + sin(_wobbleTime * _wobbleFrequency * pi) * _wobbleAmplitude;

    if (position.y > gameRef.size.y + size.y) {
      gameRef.objectMissed(type);
      removeFromParent();
    }
  }
}