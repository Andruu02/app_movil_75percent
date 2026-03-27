class PromocionModel {
  final int idPromocion;
  final String nombre;
  final String? descripcion;
  final int puntosNecesarios;

  PromocionModel({
    required this.idPromocion,
    required this.nombre,
    this.descripcion,
    required this.puntosNecesarios,
  });

  factory PromocionModel.fromJson(Map<String, dynamic> json) {
    return PromocionModel(
      idPromocion:      int.parse(json['id_promocion'].toString()),
      nombre:           json['nombre']      as String,
      descripcion:      json['descripcion'] as String?,
      puntosNecesarios: int.parse(json['puntos_necesarios'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_promocion':      idPromocion,
      'nombre':            nombre,
      'descripcion':       descripcion,
      'puntos_necesarios': puntosNecesarios,
    };
  }
}
