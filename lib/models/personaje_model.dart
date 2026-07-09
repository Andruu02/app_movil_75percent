class PersonajeModel {
  final int idPersonaje;
  final String nombre;
  final String? descripcion;
  final String spriteHome;
  final String spriteCatcher;
  final String spriteCatcherComiendo;
  final String spriteRunner1;
  final String spriteRunner2;
  final String spriteBola;

  const PersonajeModel({
    required this.idPersonaje,
    required this.nombre,
    this.descripcion,
    required this.spriteHome,
    required this.spriteCatcher,
    required this.spriteCatcherComiendo,
    required this.spriteRunner1,
    required this.spriteRunner2,
    required this.spriteBola,
  });

  factory PersonajeModel.fromJson(Map<String, dynamic> json) {
    final nombre = json['nombre'].toString().toLowerCase();
    return PersonajeModel(
      idPersonaje:           int.parse(json['id_personaje'].toString()),
      nombre:                json['nombre'] as String,
      descripcion:           json['descripcion'] as String?,
      spriteHome:            '${nombre}_home.gif',
      spriteCatcher:         '${nombre}_hambre.png',
      spriteCatcherComiendo: '${nombre}_comiendo.png',
      spriteRunner1:         '${nombre}_mono.png',
      spriteRunner2:         '${nombre}_grito_mono.png',
      spriteBola:            '${nombre}_bola.png',
    );
  }
}

const List<PersonajeModel> personajesLocales = [
  PersonajeModel(
    idPersonaje:           1,
    nombre:                'Vianne',
    descripcion:           'Personaje principal',
    spriteHome:            'vianne_home.gif',
    spriteCatcher:         'vianne_hambre.png',
    spriteCatcherComiendo: 'vianne_comiendo.png',
    spriteRunner1:         'vianne_mono.png',
    spriteRunner2:         'vianne_grito_mono.png',
    spriteBola:            'vianne_bola.png',
  ),
  PersonajeModel(
    idPersonaje:           2,
    nombre:                'Andy',
    descripcion:           'Segundo personaje',
    spriteHome:            'andy_home.gif',
    spriteCatcher:         'andy_hambre.png',
    spriteCatcherComiendo: 'andy_comiendo.png',
    spriteRunner1:         'andy_mono.png',
    spriteRunner2:         'andy_grito_mono.png',
    spriteBola:            'andy_bola.png',
  ),
  PersonajeModel(
    idPersonaje:           3,
    nombre:                'Miki',
    descripcion:           'Tercer personaje',
    spriteHome:            'miki_home.gif',        // PNG spritesheet 1050×1590 — 3 cols × 3 filas (8 frames útiles)
    spriteCatcher:         'miki_hambre.png',      // PNG spritesheet 780×590 — 1 fila × 2 cols
    spriteCatcherComiendo: 'miki_comiendo.png',    // PNG spritesheet 780×590 — 1 fila × 2 cols
    spriteRunner1:         'andy_mono.png',        // 👈 temporal
    spriteRunner2:         'andy_grito_mono.png',  // 👈 temporal
    spriteBola:            'andy_bola.png', 
  ),
];