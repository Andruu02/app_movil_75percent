import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personaje_model.dart';
import '../services/personaje_service.dart';
import '../services/partida_service.dart';

class SelectCharacterScreen extends StatefulWidget {
  const SelectCharacterScreen({super.key});

  @override
  State<SelectCharacterScreen> createState() => _SelectCharacterScreenState();
}

class _SelectCharacterScreenState extends State<SelectCharacterScreen> {
  List<PersonajeModel> _personajes = personajesLocales;
  int  _personajeIndex = 0;
  int  _puntosTotal    = 0;
  bool _cargando       = true;
  bool _cargandoPuntos = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
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

  Future<void> _cargarDatos() async {
    final prefs      = await SharedPreferences.getInstance();
    final idGuardado = prefs.getInt('personaje_id') ?? 1;

    try {
      final lista = await PersonajeService.obtenerPersonajes();
      if (mounted) {
        setState(() {
          _personajes     = lista;
          _personajeIndex = lista
              .indexWhere((p) => p.idPersonaje == idGuardado)
              .clamp(0, lista.length - 1);
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _personajeIndex = personajesLocales
              .indexWhere((p) => p.idPersonaje == idGuardado)
              .clamp(0, personajesLocales.length - 1);
          _cargando = false;
        });
      }
    }
  }

  Future<void> _seleccionarPersonaje(int index) async {
    setState(() => _personajeIndex = index);

    final p     = _personajes[index];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt   ('personaje_id',                      p.idPersonaje);
    await prefs.setString('personaje_nombre',                  p.nombre);
    await prefs.setString('personaje_sprite_home',             p.spriteHome);
    await prefs.setString('personaje_sprite_catcher',          p.spriteCatcher);
    await prefs.setString('personaje_sprite_catcher_comiendo', p.spriteCatcherComiendo);
    await prefs.setString('personaje_sprite_runner1',          p.spriteRunner1);
    await prefs.setString('personaje_sprite_runner2',          p.spriteRunner2);
    await prefs.setString('personaje_sprite_bola',             p.spriteBola);
  }

  Widget _buildPreviewPersonaje(PersonajeModel personaje) {
    return SizedBox(
      height: 120,
      child: Image.asset(
        'assets/images/${personaje.spriteHome}',
        height: 120,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 119, 0, 1),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── HEADER ────────────────────────────────────────────────
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

                // ── TÍTULO ────────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 24),
                  child: Text(
                    'Elige un personaje',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),

                // ── GRID DE PERSONAJES ────────────────────────────────────
                if (_cargando)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:   2,
                        mainAxisSpacing:  16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.80,
                      ),
                      itemCount: _personajes.length,
                      itemBuilder: (context, index) {
                        final personaje  = _personajes[index];
                        final isSelected = index == _personajeIndex;

                        return GestureDetector(
                          onTap: () => _seleccionarPersonaje(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : Border.all(color: Colors.transparent, width: 3),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildPreviewPersonaje(personaje),
                                const SizedBox(height: 6),
                                Text(
                                  personaje.nombre,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),

            // ── BOTÓN VOLVER ──────────────────────────────────────────────
            Positioned(
              top: 10, right: 10,
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