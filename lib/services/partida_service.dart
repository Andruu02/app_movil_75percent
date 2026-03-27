import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/partida_model.dart';
import '../utils/api_config.dart';

class PartidaService {

  static Future<bool> guardarPartida({
    required String juego,
    required int puntaje,
    required int idPersonaje,
  }) async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('user_id');
      if (idUsuario == null) return false;

      // Guardar localmente siempre como respaldo
      final puntosLocales = prefs.getInt('puntos_locales') ?? 0;
      await prefs.setInt('puntos_locales', puntosLocales + puntaje);

      final partida = PartidaModel(
        idUsuario:   idUsuario,
        idPersonaje: idPersonaje,
        juego:       juego,
        puntaje:     puntaje,
      );

      final response = await http.post(
        Uri.parse(ApiConfig.partidas),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(partida.toJson()),
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error al guardar partida: $e');
      return false;
    }
  }

  static Future<int> obtenerPuntosTotales() async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('user_id');
      if (idUsuario == null) return 0;

      final response = await http.get(
        Uri.parse('${ApiConfig.partidas}/puntos/$idUsuario'),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final puntos = int.parse(data['puntos_totales'].toString());
        await prefs.setInt('puntos_locales', puntos);
        return puntos;
      }

      return prefs.getInt('puntos_locales') ?? 0;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('puntos_locales') ?? 0;
    }
  }

  static Future<List<PartidaModel>> obtenerHistorial() async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('user_id');
      if (idUsuario == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.partidas}/$idUsuario'),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        List lista = data['data'];
        return lista.map((e) => PartidaModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener historial: $e');
      return [];
    }
  }
}
