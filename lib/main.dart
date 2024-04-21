import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectogaraje/screen/WelcomeScreen.dart';
import 'package:provider/provider.dart';
import 'AuthState.dart';
import 'screen/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AuthState(),
        child: MaterialApp(
          title: 'PARKING HUB',
          // Cambia la pantalla principal a SplashScreen()
          home:
              WelcomeScreen(), // Aquí se carga la SplashScreen como pantalla principal
        ));
  }
}

