import 'package:flutter/material.dart';
import '../models/codigo_promocion_model.dart';
import '../services/codigo_promocion_service.dart';
import '../services/partida_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<CodigoPromocionModel> _codigos = [];
  bool _cargando       = true;
  int  _puntosActuales = 0;
  bool _cargandoPuntos = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final resultados = await Future.wait([
      CodigoPromocionService.obtenerMisCodigos(),
      PartidaService.obtenerPuntosTotales(),
    ]);

    if (mounted) {
      setState(() {
        _codigos        = resultados[0] as List<CodigoPromocionModel>;
        _puntosActuales = resultados[1] as int;
        _cargando       = false;
        _cargandoPuntos = false;
      });
    }
  }

  Future<void> _confirmarSalir() async {
    final salir = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Está seguro de que\ndesea salir?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // SI
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      width: 70, height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCC00CC),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('SI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            )),
                      ),
                    ),
                  ),
                  // NO
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      width: 70, height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3366),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('no',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (salir == true && mounted) {
      Navigator.popUntil(context, ModalRoute.withName('/home'));
    }
  }

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} · '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF8C00),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/coin.png', height: 36),
                      const SizedBox(height: 4),
                      _cargandoPuntos
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              '$_puntosActuales',
                              style: const TextStyle(
                                fontSize: 27,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                
                              ),
                            ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/images/house.png', height: 44),
                  ),
                ],
              ),
            ),

            // ── TÍTULO ───────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Mis Códigos',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 0, 0, 0),
                  shadows: [Shadow(offset: Offset(1, 1), color: Colors.black38)],
                ),
              ),
            ),

            // ── LISTA DE HISTORIAL ───────────────────────────────────────
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _codigos.isEmpty
                      ? const Center(
                          child: Text(
                            'No has canjeado\nninguna promoción aún',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _codigos.length,
                            separatorBuilder: (_, __) => const Divider(
                              color: Color(0xFF3A3A3A),
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final cod = _codigos[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Ícono estado
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: cod.disponible
                                            ? Colors.deepPurple.withOpacity(0.25)
                                            : Colors.grey.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          cod.disponible ? '🎁' : '✅',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Nombre + código
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cod.nombrePromocion ?? 'Promoción',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            cod.codigo,
                                            style: TextStyle(
                                              color: cod.disponible
                                                  ? Colors.greenAccent
                                                  : Colors.grey,
                                              fontSize: 13,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatFecha(cod.fechaGeneracion),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Badge estado
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cod.disponible
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: cod.disponible
                                              ? Colors.greenAccent
                                              : Colors.grey,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        cod.disponible ? 'Activo' : 'Usado',
                                        style: TextStyle(
                                          color: cod.disponible
                                              ? Colors.greenAccent
                                              : Colors.grey,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),

            // ── BOTONES INFERIORES ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Promos → volver a pantalla de promociones
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/images/promos.png',
                      height: 90 * 0.55,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Salir
                  GestureDetector(
                    onTap: _confirmarSalir,
                    child: Image.asset(
                      'assets/images/salir.png',
                      height: 90 * 0.55,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}