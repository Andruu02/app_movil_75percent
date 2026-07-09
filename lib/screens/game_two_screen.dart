import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../games/catcher/catcher_game.dart';

class GameTwoScreen extends StatefulWidget {
  const GameTwoScreen({super.key});

  @override
  State<GameTwoScreen> createState() => _GameTwoScreenState();
}

class _GameTwoScreenState extends State<GameTwoScreen> {
  CatcherGame? _game;
  bool _pausado = false;
  int _inicioTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _inicioTimestamp = DateTime.now().millisecondsSinceEpoch;
    _initGame();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _escucharNotificaciones();
    });
  }

  Future<void> _initGame() async {
    final prefs           = await SharedPreferences.getInstance();
    final idPersonaje     = prefs.getInt('personaje_id') ?? 1;
    final nombrePersonaje =
        (prefs.getString('personaje_nombre') ?? 'vianne').toLowerCase();
    setState(() {
      _game = CatcherGame(
        idPersonaje:    idPersonaje,
        spriteHambre:   '${nombrePersonaje}_hambre.png',
        spriteComiendo: '${nombrePersonaje}_comiendo.png',
      );
    });
  }

  void _escucharNotificaciones() {
    final ref = FirebaseDatabase.instance.ref('notificaciones');
    ref.orderByChild('timestamp').startAt(_inicioTimestamp).onChildAdded.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null && mounted && _game != null) {
        final ts = data['timestamp'];
        if (ts != null && (ts as int) < _inicioTimestamp) return;
        final mensaje = data['mensaje']?.toString() ?? '';
        if (mensaje.isNotEmpty) _pausarYMostrar(mensaje);
      }
    });
  }

  void _pausarYMostrar(String mensaje) {
    _game!.pauseEngine();
    setState(() => _pausado = true);
    _mostrarAlerta(mensaje);
  }

  void _reanudar() {
    _game!.resumeEngine();
    setState(() => _pausado = false);
  }

  void _togglePausa() {
    if (_pausado) {
      _reanudar();
    } else {
      _game!.pauseEngine();
      setState(() => _pausado = true);
    }
  }

  void _mostrarAlerta(String contenido) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                Positioned(
                  top: 0, right: 0,
                  child: GestureDetector(
                    onTap: () { Navigator.of(context).pop(); _reanudar(); },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const Text('🎉', style: TextStyle(fontSize: 52)),
                    const SizedBox(height: 12),
                    const Text(
                      '¡Oferta Especial!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      contenido,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF6B6B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        _reanudar();
                        final uri = Uri.parse('https://happyjumpingperu.com/paquetes/entradas');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text(
                        'Más información',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_game == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFBB00FF),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) {
        if (!_pausado) _game!.movePlayer(details.globalPosition.dx);
      },
      child: GameWidget(
        game: _game!,
        overlayBuilderMap: {

          'hud': (context, game) {
            final catcher = game as CatcherGame;
            return Stack(
              children: [
                Positioned(
                  top: 12, left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/images/house.png', height: 52),
                  ),
                ),
                Positioned(
                  top: 12, left: 80,
                  child: GestureDetector(
                    onTap: _togglePausa,
                    child: Image.asset('assets/images/pausa.png', height: 52),
                  ),
                ),
                Positioned(
                  top: 20, right: 16,
                  child: ValueListenableBuilder<int>(
                    valueListenable: catcher.scoreNotifier,
                    builder: (_, score, __) => Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Jaro', decoration: TextDecoration.none,
                        shadows: [Shadow(offset: Offset(2, 2), color: Colors.black54)],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },

          'pauseScreen': (context, game) {
            return DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'Jaro',
                decoration: TextDecoration.none,
                color: Colors.white,
              ),
              child: Container(
                width: double.infinity, height: double.infinity,
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PAUSA',
                        style: TextStyle(
                          fontSize: 48, fontWeight: FontWeight.w900,
                          color: Colors.white, letterSpacing: 4,
                          fontFamily: 'Jaro', decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: _reanudar,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 119, 0, 1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'Reanudar',
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white,
                              fontFamily: 'Jaro', decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'Salir',
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white,
                              fontFamily: 'Jaro', decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },

          'gameOver': (context, game) {
            final catcher = game as CatcherGame;
            return DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'Jaro',
                decoration: TextDecoration.none,
                color: Colors.white,
              ),
              child: Container(
                width: double.infinity, height: double.infinity,
                color: const Color(0xFFE53935),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8, right: 8,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset('assets/images/house.png', height: 50),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/emoji_cry.png', height: 130),
                            const SizedBox(height: 32),
                            const Text(
                              'GAME OVER',
                              style: TextStyle(
                                fontSize: 44, fontWeight: FontWeight.w900,
                                color: Colors.white, letterSpacing: 2,
                                fontFamily: 'Jaro', decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 18),
                            ValueListenableBuilder<int>(
                              valueListenable: catcher.scoreNotifier,
                              builder: (_, score, __) => Text(
                                '¡Alcanzaste $score\npuntos!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Jaro', decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 44),
                            GestureDetector(
                              onTap: () => _game!.resetGame(),
                              child: Image.asset('assets/images/retry.png', height: 80),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }
}