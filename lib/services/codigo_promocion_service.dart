import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/codigo_promocion_model.dart';
import '../utils/api_config.dart';

class CodigoPromocionService {

  static Future<CodigoPromocionModel?> canjearPromocion(int idPromocion) async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('user_id');
      if (idUsuario == null) return null;

      final response = await http.post(
        Uri.parse(ApiConfig.canjearPromocion),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario':   idUsuario,
          'id_promocion': idPromocion,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return CodigoPromocionModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error al canjear promoción: $e');
      return null;
    }
  }

  static Future<List<CodigoPromocionModel>> obtenerMisCodigos() async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('user_id');
      if (idUsuario == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.codigosPromocion}/$idUsuario'),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        List lista = data['data'];
        return lista.map((e) => CodigoPromocionModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener códigos: $e');
      return [];
    }
  }
}
