import 'package:flutter/material.dart';
import '../services/sound_manager.dart';

/// Pantalla de pausa compartida por los 3 minijuegos: fondo oscuro
/// semitransparente con los botones de reanudar, reintentar, silenciar y salir.
class PauseOverlay extends StatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRetry,
    required this.onExit,
  });

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  Future<void> _toggleSonido() async {
    await SoundManager.toggleMuted();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'Jaro',
        decoration: TextDecoration.none,
        color: Colors.white,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.65),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSA',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                  fontFamily: 'Jaro',
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _PauseButton(imagePath: 'assets/images/games.png', onTap: widget.onExit),
                  const SizedBox(width: 32),
                  _PauseButton(
                    imagePath: 'assets/images/play.png',
                    onTap: widget.onResume,
                    size: 72,
                  ),
                  const SizedBox(width: 32),
                  _PauseButton(imagePath: 'assets/images/retry.png', onTap: widget.onRetry),
                ],
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: _toggleSonido,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        SoundManager.muted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        SoundManager.muted ? 'Sonido apagado' : 'Sonido activado',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontFamily: 'Jaro',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final double size;

  const _PauseButton({
    required this.imagePath,
    required this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(imagePath, height: size, fit: BoxFit.contain),
    );
  }
}
