import 'package:flutter/material.dart';

class RequestParkingPage extends StatelessWidget {
  const RequestParkingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Parkeo'),
      ),
      body: Center(
        child: Text(
          'Solicitudes de Parkeo',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
