import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/api_config.dart';
import 'api_client.dart';

/// Notificaciones push nativas (FCM), del lado servidor ya armadas por el
/// backend — esto solo conecta la app: pide permiso, registra el token del
/// dispositivo, y muestra/gestiona el mensaje en los 3 estados de la app.
///
/// El backend asocia el dispositivo al usuario a través del JWT que ya manda
/// `ApiClient` en el header Authorization (si hay sesión iniciada). Si no hay
/// sesión, el token igual se registra como dispositivo anónimo.
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'happy_jumping_notifications';
  static const String _channelName = 'Notificaciones';
  static const String _channelDescription =
      'Avisos y promociones de Happy Jumping';

  static bool _initialized = false;

  /// Llamar una vez al arrancar la app (antes de runApp).
  static Future<void> inicializar() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) return; // Push nativo no aplica al build web.

    await _initLocalNotifications();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('Permiso de notificaciones denegado');
      return;
    }

    await registrarTokenActual();
    _messaging.onTokenRefresh.listen(_registrarToken);

    // Foreground: FCM no muestra nada solo, hay que mostrarlo a mano.
    FirebaseMessaging.onMessage.listen(_mostrarNotificacionForeground);

    // App en background y el usuario toca la notificación del sistema.
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _abrirDesdeData(message.data));

    // App cerrada y se abrió tocando la notificación.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _abrirDesdeData(initialMessage.data);
    }
  }

  /// Reenvía el token actual al backend. Llamar también justo después de
  /// iniciar sesión, para que el backend lo asocie al usuario recién logueado.
  static Future<void> registrarTokenActual() async {
    if (kIsWeb) return;
    final token = await _messaging.getToken();
    if (token != null) await _registrarToken(token);
  }

  static Future<void> _registrarToken(String token) async {
    try {
      final plataforma =
          defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

      await ApiClient.post(
        ApiConfig.registrarDispositivoFcm,
        body: {
          'token': token,
          'plataforma': plataforma,
        },
      );
    } catch (e) {
      log('Error al registrar token FCM: $e');
    }
  }

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifs.initialize(
      initSettings,
      // Toca la notificación local mientras la app estaba en foreground.
      onDidReceiveNotificationResponse: (response) {
        final url = response.payload;
        if (url != null && url.isNotEmpty) _abrirUrl(url);
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _localNotifs
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _mostrarNotificacionForeground(
      RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifs.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['url'] as String?,
    );
  }

  static void _abrirDesdeData(Map<String, dynamic> data) {
    final url = data['url'] as String?;
    if (url != null && url.isNotEmpty) _abrirUrl(url);
  }

  static Future<void> _abrirUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
