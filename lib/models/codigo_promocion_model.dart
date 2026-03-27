class CodigoPromocionModel {
  final int? idCodigo;
  final int idPromocion;
  final int idUsuario;
  final String codigo;
  final String estado;
  final DateTime? fechaGeneracion;
  final DateTime? fechaUso;
  final String? nombrePromocion;
  final int? puntosNecesarios;

  CodigoPromocionModel({
    this.idCodigo,
    required this.idPromocion,
    required this.idUsuario,
    required this.codigo,
    required this.estado,
    this.fechaGeneracion,
    this.fechaUso,
    this.nombrePromocion,
    this.puntosNecesarios,
  });

  bool get disponible => estado == 'disponible';

  factory CodigoPromocionModel.fromJson(Map<String, dynamic> json) {
    return CodigoPromocionModel(
      idCodigo:         json['id_codigo'] != null
                            ? int.parse(json['id_codigo'].toString()) : null,
      idPromocion:      int.parse(json['id_promocion'].toString()),
      idUsuario:        int.parse(json['id_usuario'].toString()),
      codigo:           json['codigo'] as String,
      estado:           json['estado'] as String,
      fechaGeneracion:  json['fecha_generacion'] != null
                            ? DateTime.parse(json['fecha_generacion'] as String) : null,
      fechaUso:         json['fecha_uso'] != null
                            ? DateTime.parse(json['fecha_uso'] as String) : null,
      nombrePromocion:  json['nombre']            as String?,
      puntosNecesarios: json['puntos_necesarios'] != null
                            ? int.parse(json['puntos_necesarios'].toString()) : null,
    );
  }
}
