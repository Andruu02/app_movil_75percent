class CodigoPromocionModel {
  // ⚠️ Vigencia del código: 30 días desde su generación. Idealmente el
  // backend calcula y envía `fecha_vencimiento` (y marca estado = 'vencido'
  // al validar un código fuera de plazo); mientras ese contrato no esté
  // listo, se calcula aquí mismo como respaldo a partir de fechaGeneracion.
  static const int diasVigencia = 30;

  final int? idCodigo;
  final int idPromocion;
  final int idUsuario;
  final String codigo;
  final String estado;
  final DateTime? fechaGeneracion;
  final DateTime? fechaUso;
  final DateTime? _fechaVencimiento;
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
    DateTime? fechaVencimiento,
    this.nombrePromocion,
    this.puntosNecesarios,
  }) : _fechaVencimiento = fechaVencimiento;

  /// Fecha de vencimiento: la del backend si viene en el JSON, o
  /// fechaGeneracion + 30 días como respaldo.
  DateTime? get fechaVencimiento =>
      _fechaVencimiento ?? fechaGeneracion?.add(const Duration(days: diasVigencia));

  /// Vencido si el backend ya lo marcó como tal, o si sigue "disponible"
  /// pero la fecha de vencimiento calculada ya pasó.
  bool get estaVencido {
    if (estado == 'vencido') return true;
    if (estado != 'disponible') return false;
    final venc = fechaVencimiento;
    return venc != null && DateTime.now().isAfter(venc);
  }

  bool get disponible => estado == 'disponible' && !estaVencido;

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
      fechaVencimiento: json['fecha_vencimiento'] != null
                            ? DateTime.parse(json['fecha_vencimiento'] as String) : null,
      nombrePromocion:  json['nombre']            as String?,
      puntosNecesarios: json['puntos_necesarios'] != null
                            ? int.parse(json['puntos_necesarios'].toString()) : null,
    );
  }
}
