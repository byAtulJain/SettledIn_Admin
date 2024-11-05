import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:settledin_admin/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SettledIn Admin',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: LoginPage(), // Start with the SplashScreen
    );
  }
}
