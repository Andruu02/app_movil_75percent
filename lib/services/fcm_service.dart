import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';
import 'api_client.dart';

/// Pide permiso de notificaciones, obtiene el token FCM del dispositivo
/// y lo registra en el backend para que aparezca como "suscrito" en el
/// panel de notificaciones.
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> inicializar() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('Permiso de notificaciones denegado');
      return;
    }

    final token = await _messaging.getToken();
    if (token != null) {
      await _registrarToken(token);
    }

    _messaging.onTokenRefresh.listen(_registrarToken);
  }

  static Future<void> _registrarToken(String token) async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('user_id');

      await ApiClient.post(
        ApiConfig.registrarDispositivoFcm,
        body: {
          'token': token,
          'plataforma': 'android',
          'id_usuario': ?idUsuario,
        },
      );
    } catch (e) {
      log('Error al registrar token FCM: $e');
    }
  }
}
