import 'dart:convert';
import '../models/promocion_model.dart';
import '../utils/api_config.dart';
import 'api_client.dart';

class PromocionService {

  static Future<List<PromocionModel>> obtenerPromociones() async {
    try {
      final response = await ApiClient.get(ApiConfig.promociones);
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
