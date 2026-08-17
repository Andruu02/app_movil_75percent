import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Punto único para música de fondo y efectos de sonido de toda la app.
///
/// - `playSfx`: efecto corto (salto, punto, choque, game over...). Usa pools
///   de reproductores pre-creados (`AudioPool`) en vez de instanciar un
///   MediaPlayer nuevo en cada llamada — eso es lo que hacía que el juego se
///   fuera poniendo lento tras jugar un rato (sonidos como "punto" o "salto"
///   disparan muy seguido, y crear/destruir reproductores nativos así de
///   rápido acumula trabajo en cada frame).
/// - `playMusic`: música en loop. Si ya está sonando el mismo track no lo
///   reinicia (evita el "salto" audible al navegar entre pantallas de menú).
/// - El mute se guarda en SharedPreferences y afecta música + efectos.
class SoundManager {
  SoundManager._();

  static bool _muted = false;
  static bool _initialized = false;
  static String? _currentTrack;
  static double _currentVolume = 0.4;

  // Efectos ya disponibles en assets/audio/sfx/. "catch_good" todavía no
  // tiene archivo — en cuanto lo agreguen, súmenlo aquí y en CatcherGame.
  static const List<String> _sfxFiles = [
    'sfx/jump.ogg',
    'sfx/score.wav',
    'sfx/catch_bad.wav',
    'sfx/gameover.wav',
    'sfx/crash.ogg',
  ];

  static final Map<String, AudioPool> _pools = {};

  static bool get muted => _muted;

  /// Llamar una vez al arrancar la app (antes de runApp).
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool('sound_muted') ?? false;

    try {
      await FlameAudio.audioCache.loadAll(_sfxFiles);

      // Pool por cada efecto: reutiliza reproductores en vez de crear uno
      // nuevo por llamada. minPlayers=1 mantiene 1 siempre listo; maxPlayers
      // permite que un par de instancias del mismo sonido se solapen sin
      // crear reproductores extra sobre la marcha.
      for (final file in _sfxFiles) {
        _pools[file] = await FlameAudio.createPool(
          file,
          minPlayers: 1,
          maxPlayers: 3,
        );
      }
    } catch (_) {
      // Si falta algún archivo de sonido no debe tumbar la app.
    }
  }

  static void playSfx(String file, {double volume = 1.0}) {
    if (_muted) return;
    final pool = _pools[file];
    try {
      if (pool != null) {
        pool.start(volume: volume);
      } else {
        // Fallback para efectos sin pool (p.ej. uno agregado sin reiniciar
        // la app): funciona, pero sin la ventaja de reutilizar reproductor.
        FlameAudio.play(file, volume: volume);
      }
    } catch (_) {}
  }

  static void playMusic(String file, {double volume = 0.4}) {
    _currentVolume = volume;
    if (_currentTrack == file) return; // ya sonando, no reiniciar
    _currentTrack = file;
    if (_muted) return;
    try {
      FlameAudio.bgm.play(file, volume: volume);
    } catch (_) {}
  }

  static void stopMusic() {
    _currentTrack = null;
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  static Future<void> setMuted(bool value) async {
    _muted = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_muted', value);

    if (value) {
      try {
        FlameAudio.bgm.pause();
      } catch (_) {}
    } else if (_currentTrack != null) {
      try {
        FlameAudio.bgm.play(_currentTrack!, volume: _currentVolume);
      } catch (_) {}
    }
  }

  static Future<void> toggleMuted() => setMuted(!_muted);
}
