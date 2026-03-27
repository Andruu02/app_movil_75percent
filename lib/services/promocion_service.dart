import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promocion_model.dart';
import '../utils/api_config.dart';

class PromocionService {

  static Future<List<PromocionModel>> obtenerPromociones() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.promociones));
      final data     = jsonDecode(response.body);

      if (data['success'] == true) {
        List lista = data['data'];
        return lista.map((e) => PromocionModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener promociones: $e');
      return [];
    }
  }
}
