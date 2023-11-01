import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/app_state.dart';
import 'package:secure_messenger/firebase_options.dart';
import 'package:secure_messenger/screens/auth_gate.dart';
// import 'package:secure_messenger/screens/bio_authentication.dart';
import 'package:secure_messenger/screens/login.dart';
// import 'package:secure_messenger/screens/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'Secure Messenger',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SecureMessengerApp());
}

class SecureMessengerApp extends StatelessWidget {
  const SecureMessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        List.from([DeviceOrientation.portraitUp]));
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const GoogleAuthGate(),
          'login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
