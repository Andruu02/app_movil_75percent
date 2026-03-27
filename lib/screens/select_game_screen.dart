import 'package:flutter/material.dart';
import '../services/partida_service.dart';

class SelectGameScreen extends StatefulWidget {
  const SelectGameScreen({super.key});

  @override
  State<SelectGameScreen> createState() => _SelectGameScreenState();
}

class _SelectGameScreenState extends State<SelectGameScreen> {
  int  _puntosTotal    = 0;
  bool _cargandoPuntos = true;

  @override
  void initState() {
    super.initState();
    _cargarPuntos();
  }

  Future<void> _cargarPuntos() async {
    final puntos = await PartidaService.obtenerPuntosTotales();
    if (mounted) {
      setState(() {
        _puntosTotal    = puntos;
        _cargandoPuntos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 119, 0, 1),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Moneda + puntos en columna (igual que home)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/coin.png', height: 36),
                          const SizedBox(height: 4),
                          _cargandoPuntos
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  '$_puntosTotal',
                                  style: const TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── TÍTULO ──────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.only(left: 79, top: 45, bottom: 32),
                  child: Text(
                    'Elige un juego',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 100),

                // ── JUEGOS ──────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Fila 1: Runner (TNT) + Catcher (Sandía)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Runner → /game1
                            _GameCard(
                              imagePath: 'assets/images/tnt.png',
                              onTap: () async {
                                await Navigator.pushNamed(context, '/game1');
                                _cargarPuntos();
                              },
                            ),

                            // Catcher → /game2
                            _GameCard(
                              imagePath: 'assets/images/sandia.png',
                              onTap: () async {
                                await Navigator.pushNamed(context, '/game2');
                                _cargarPuntos();
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 100),

                        // Fila 2: Fall game (Cactus) → /game3
                        Row(
                          children: [
                            _GameCard(
                              imagePath: 'assets/images/cactus.png',
                              onTap: () async {
                                await Navigator.pushNamed(context, '/game3');
                                _cargarPuntos();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),

            // ── BOTÓN VOLVER (casa) ──────────────────────────────────────
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset('assets/images/house.png', height: 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _GameCard({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        imagePath,
        height: 130,
        width: 130,
        fit: BoxFit.contain,
      ),
    );
  }
}