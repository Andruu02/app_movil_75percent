import 'package:firebase_database/firebase_database.dart';

class FirebaseConfig {
  static DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('notificaciones');

  static void escucharNotificaciones({
    required Function(String mensaje) onMensaje,
  }) {
    _ref.orderByChild('timestamp').limitToLast(1).onChildAdded.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final mensaje = data['mensaje']?.toString() ?? '';
        if (mensaje.isNotEmpty) {
          onMensaje(mensaje);
        }
      }
    });
  }
}