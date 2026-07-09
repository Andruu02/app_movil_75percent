import 'dart:convert';
import '../models/personaje_model.dart';
import '../utils/api_config.dart';
import 'api_client.dart';

class PersonajeService {

  static Future<List<PersonajeModel>> obtenerPersonajes() async {
    try {
      final response = await ApiClient.get(ApiConfig.personajes);
      final data     = jsonDecode(response.body);

      if (data['success'] == true) {
        List lista = data['data'];
        return lista.map((e) => PersonajeModel.fromJson(e)).toList();
      }
      return personajesLocales;
    } catch (e) {
      print('Error al obtener personajes: $e');
      return personajesLocales;
    }
  }
}
