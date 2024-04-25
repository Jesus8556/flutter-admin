import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectogaraje/screen/WelcomeScreen.dart';
import 'socket_service.dart';
import 'AuthState.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
        ChangeNotifierProvider(create: (context) => SocketService(serverUrl: 'https://test-2-slyp.onrender.com')),
      ],
      child: MaterialApp(
        title: 'PARKING HUB',
        home: WelcomeScreen(),  // Aquí se carga la pantalla principal
      ),
    );
  }
}
