import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_one_screen.dart';
import 'screens/game_two_screen.dart';
import 'screens/game_three_screen.dart';
import 'screens/promociones_screen.dart';
import 'screens/historial_screen.dart';          // ← NUEVO
import 'screens/select_character_screen.dart';
import 'screens/select_game_screen.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // El web no lee google-services.json: hay que pasar las options a mano.
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey:            "AIzaSyA2cRPBbxeUn5kbgcQRV7uZCSXex8zVJCs",
        authDomain:        "happyjumping.firebaseapp.com",
        databaseURL:       "https://happyjumping-default-rtdb.firebaseio.com",
        projectId:         "happyjumping",
        storageBucket:     "happyjumping.firebasestorage.app",
        messagingSenderId: "810488811579",
        appId:             "1:810488811579:web:36396e17e060a8e06acc1e",
        measurementId:     "G-XDPGM33HRB",
      ),
    );
  } else {
    // Android/iOS leen su configuración nativa (google-services.json / GoogleService-Info.plist).
    await Firebase.initializeApp();
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const HappyJumpingApp());
}

class HappyJumpingApp extends StatelessWidget {
  const HappyJumpingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ApiClient.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Happy & Jumping',
      theme: ThemeData(
        fontFamily: 'Jaro',
      ),
      initialRoute: '/',
      routes: {
        '/':                 (context) => const LoginScreen(),
        '/home':             (context) => const HomeScreen(),
        '/select_character': (context) => const SelectCharacterScreen(),
        '/select_game':      (context) => const SelectGameScreen(),
        '/game1':            (context) => const GameOneScreen(),
        '/game2':            (context) => const GameTwoScreen(),
        '/game3':            (context) => const GameThreeScreen(),
        '/promociones':      (context) => const PromocionesScreen(),
        '/historial':        (context) => const HistorialScreen(),  // ← NUEVO
      },
    );
  }
}