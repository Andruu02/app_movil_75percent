import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/personaje_model.dart';
import '../utils/api_config.dart';

class PersonajeService {

  static Future<List<PersonajeModel>> obtenerPersonajes() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.personajes));
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
