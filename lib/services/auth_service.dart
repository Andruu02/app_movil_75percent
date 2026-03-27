import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/api_config.dart';

class AuthService {

  static Future<UserModel?> login(String correo, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        UserModel user = UserModel.fromJson(data['usuario']);
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('user_id',        user.idUsuario);
        prefs.setString('user_nombre', user.nombre);
        prefs.setString('user_correo', user.correo);
        return user;
      }

      return null;
    } catch (e) {
      print('Error login: $e');
      return null;
    }
  }
}
