class PartidaModel {
  final int? idPartida;
  final int idUsuario;
  final int idPersonaje;
  final String juego;
  final int puntaje;
  final DateTime? fechaJugada;

  PartidaModel({
    this.idPartida,
    required this.idUsuario,
    required this.idPersonaje,
    required this.juego,
    required this.puntaje,
    this.fechaJugada,
  });

  factory PartidaModel.fromJson(Map<String, dynamic> json) {
    return PartidaModel(
      idPartida:   json['id_partida'] != null
                       ? int.parse(json['id_partida'].toString()) : null,
      idUsuario:   int.parse(json['id_usuario'].toString()),
      idPersonaje: int.parse(json['id_personaje'].toString()),
      juego:       json['juego'] as String,
      puntaje:     int.parse(json['puntaje'].toString()),
      fechaJugada: json['fecha_jugada'] != null
                       ? DateTime.parse(json['fecha_jugada'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario':   idUsuario,
      'id_personaje': idPersonaje,
      'juego':        juego,
      'puntaje':      puntaje,
    };
  }
}
