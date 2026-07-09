import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personaje_model.dart';
import '../services/personaje_service.dart';
import '../services/partida_service.dart';
import '../widgets/image_button.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nombreUsuario = 'Usuario';
  int _puntosTotal = 0;
  bool _cargandoPuntos = true;
  bool _iniciado = false; // 👈 bloquea notificaciones al arrancar

  List<PersonajeModel> _personajes = personajesLocales;
  int _personajeIndex = 0;
  PersonajeModel get _personajeActual => _personajes[_personajeIndex];

  @override
  void initState() {
    super.initState();
    _escucharNotificaciones();
    _cargarUsuario();
    _cargarPersonajes();
    _cargarPuntos();

    // Espera 3 segundos antes de permitir que lleguen notificaciones
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _iniciado = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarPersonajeGuardado();
  }

  void _escucharNotificaciones() {
    final ref = FirebaseDatabase.instance.ref('notificaciones');
    ref.orderByChild('timestamp').limitToLast(1).onChildAdded.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null && mounted && _iniciado) { // 👈 solo si ya pasaron los 3s
        final mensaje = data['mensaje']?.toString() ?? '';
        if (mensaje.isNotEmpty) {
          _mostrarAlerta(mensaje);
        }
      }
    });
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString('user_nombre') ?? 'Usuario';
    });
  }

  Future<void> _cargarPersonajes() async {
    final lista = await PersonajeService.obtenerPersonajes();
    if (mounted) setState(() => _personajes = lista);
  }

  Future<void> _cargarPersonajeGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final idGuardado = prefs.getInt('personaje_id');
    if (idGuardado != null && mounted) {
      final idx = _personajes.indexWhere((p) => p.idPersonaje == idGuardado);
      if (idx != -1) setState(() => _personajeIndex = idx);
    }
  }

  Future<void> _cargarPuntos() async {
    final puntos = await PartidaService.obtenerPuntosTotales();
    if (mounted) {
      setState(() {
        _puntosTotal = puntos;
        _cargandoPuntos = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _mostrarAlerta(String contenido) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      contenido,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF6B6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final uri = Uri.parse(
                          'https://happyjumpingperu.com/paquetes/entradas',
                        );
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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 119, 0, 1),
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
                                strokeWidth: 2, color: Colors.white,
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
                  const Spacer(),
                  Text(
                    '¡Hola, $nombreUsuario!',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      shadows: [Shadow(offset: Offset(1, 1), color: Colors.black26)],
                    ),
                  ),
                ],
              ),
            ),

            // ── PERSONAJE ───────────────────────────────────────────────
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/${_personajeActual.spriteHome}',
                  height: 450,
                  gaplessPlayback: true,
                ),
              ),
            ),

            // ── BOTONES INFERIORES ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ImageButton(
                    imagePath: 'assets/images/character.png',
                    size: 90,
                    onTap: () async {
                      await Navigator.pushNamed(context, '/select_character');
                      await _cargarPersonajeGuardado();
                    },
                  ),
                  ImageButton(
                    imagePath: 'assets/images/games.png',
                    size: 90,
                    onTap: () async {
                      await Navigator.pushNamed(context, '/select_game');
                      _cargarPuntos();
                    },
                  ),
                  ImageButton(
                    imagePath: 'assets/images/gift.png',
                    size: 90,
                    onTap: () => Navigator.pushNamed(context, '/promociones'),
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