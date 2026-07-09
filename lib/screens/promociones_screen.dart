import 'package:flutter/material.dart';
import '../models/promocion_model.dart';
import '../services/promocion_service.dart';
import '../services/partida_service.dart';
import '../services/codigo_promocion_service.dart';

class PromocionesScreen extends StatefulWidget {
  const PromocionesScreen({super.key});

  @override
  State<PromocionesScreen> createState() => _PromocionesScreenState();
}

class _PromocionesScreenState extends State<PromocionesScreen> {
  late Future<List<PromocionModel>> _promocionesFuture;
  int  _puntosActuales = 0;
  bool _cargandoPuntos = true;

  @override
  void initState() {
    super.initState();
    _promocionesFuture = PromocionService.obtenerPromociones();
    _cargarPuntos();
  }

  Future<void> _cargarPuntos() async {
    final puntos = await PartidaService.obtenerPuntosTotales();
    if (mounted) {
      setState(() {
        _puntosActuales = puntos;
        _cargandoPuntos = false;
      });
    }
  }

  Future<void> _canjear(PromocionModel promo) async {
    if (_puntosActuales < promo.puntosNecesarios) {
      _mostrarSnack(
        '¡Te faltan ${promo.puntosNecesarios - _puntosActuales} puntos!',
        error: true,
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Canjear promoción?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(promo.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Costo: ${promo.puntosNecesarios} puntos'),
            Text('Tus puntos: $_puntosActuales'),
            const SizedBox(height: 8),
            Text(
              'Te quedarán: ${_puntosActuales - promo.puntosNecesarios} puntos',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    final codigo =
        await CodigoPromocionService.canjearPromocion(promo.idPromocion);
    if (mounted) Navigator.pop(context);

    if (codigo != null) {
      setState(() => _puntosActuales -= promo.puntosNecesarios);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('¡Código generado!',
                textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(promo.nombre,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple),
                  ),
                  child: Text(
                    codigo.codigo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Presenta este código en el local.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('¡Listo!'),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      _mostrarSnack('Error al canjear. Intenta de nuevo.', error: true);
    }
  }

  // ── Diálogo de confirmación para salir ────────────────────────────────────
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

    if (salir == true && mounted) Navigator.pop(context);
  }

  void _mostrarSnack(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      backgroundColor: error ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
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
                  // Moneda + puntos en columna
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/coin.png', height: 36),
                      const SizedBox(height: 4),
                      _cargandoPuntos
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                            )
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
                  // Casa para volver
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/images/house.png', height: 44),
                  ),
                ],
              ),
            ),

            // ── BANNER PUNTOS ────────────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐ Mis puntos: ',
                      style: TextStyle(
                          fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
                  _cargandoPuntos
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          '$_puntosActuales',
                          style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── LISTA DE PROMOCIONES ─────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<PromocionModel>>(
                future: _promocionesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay promociones disponibles',
                            style: TextStyle(fontSize: 16)));
                  }

                  final promociones = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: promociones.length,
                    itemBuilder: (context, index) {
                      final promo = promociones[index];
                      final puedesCanjear = _puntosActuales >= promo.puntosNecesarios;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: puedesCanjear
                                      ? Colors.deepPurple.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('🎁',
                                    style: TextStyle(fontSize: 28)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(promo.nombre,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    if (promo.descripcion != null &&
                                        promo.descripcion!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(promo.descripcion!,
                                          style: const TextStyle(
                                              fontSize: 22, color: Colors.grey)),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      '⭐ ${promo.puntosNecesarios} puntos',
                                      style: TextStyle(
                                          fontSize: 19,
                                          color: puedesCanjear
                                              ? Colors.deepPurple
                                              : Colors.grey,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: puedesCanjear
                                      ? Colors.deepPurple
                                      : Colors.grey.shade300,
                                  foregroundColor: puedesCanjear
                                      ? Colors.white
                                      : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  elevation: puedesCanjear ? 2 : 0,
                                ),
                                onPressed: puedesCanjear ? () => _canjear(promo) : null,
                                child: const Text('Canjear',
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ── BOTONES INFERIORES: HISTORIAL + SALIR ────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Historial
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/historial'),
                    child: Image.asset(
                      'assets/images/historial.png',
                      height: 90 * 0.55, // proporcional a 350×110
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