import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:provider/provider.dart';
import 'package:proyectogaraje/AuthState.dart';
import 'package:proyectogaraje/socket_service.dart';

// Modelo para representar las ofertas cercanas
class Oferta {
  final String id;
  final bool filtroAlquiler;
  final double monto;
  final String user;
  final String? name;
  final double latitud;
  final double longitud;
  final DateTime createdAt;

  Oferta({
    required this.id,
    required this.filtroAlquiler,
    required this.monto,
    required this.user,
    required this.name,
    required this.latitud,
    required this.longitud,
    required this.createdAt,
  });

  factory Oferta.fromJson(Map<String, dynamic> json) {
    return Oferta(
      id: json['_id'],
      filtroAlquiler: json['filtroAlquiler'],
      monto: json['monto'].toDouble(),
      user: json['user'],
      name: json['name'],
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class RequestParkingPage extends StatefulWidget {
  const RequestParkingPage({Key? key}) : super(key: key);

  @override
  _RequestParkingPageState createState() => _RequestParkingPageState();
}

class _RequestParkingPageState extends State<RequestParkingPage> {
  late io.Socket socket;
  List<Oferta> ofertas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    socket = Provider.of<SocketService>(context, listen: false).socket;
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socket.on('nueva_oferta', (data) {
      if (mounted) {
        try {
          if (data != null && data is Map<String, dynamic>) {
            setState(() {
              ofertas.add(Oferta.fromJson(data));
            });
          } else {
            print('Datos de oferta recibidos no válidos');
          }
        } catch (e) {
          print('Error al procesar la oferta recibida: $e');
        }
      }
    });
  }

  Future<List<Oferta>> fetchOfertasCercanas() async {
    String token = Provider.of<AuthState>(context, listen: false).token;
    Map<String, dynamic> decodedToken = _decodeToken(token);
    String userId = decodedToken['id'];
    String url = 'https://test-2-slyp.onrender.com/api/oferta/oferta-cercana/$userId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-access-token': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Oferta.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener ofertas cercanas');
    }
  }

  // Decodificación del token para obtener información de usuario
  Map<String, dynamic> _decodeToken(String token) {
    List<String> parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token inválido');
    }

    String payload = _decodeBase64(parts[1]);
    return jsonDecode(payload);
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Token inválido');
    }
    return utf8.decode(base64Url.decode(output));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ofertas Cercanas')),
      body: FutureBuilder<List<Oferta>>(
        future: fetchOfertasCercanas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las ofertas'));
          } else {
            final ofertas = snapshot.data ?? [];
            return ListView.builder(
              itemCount: ofertas.length,
              itemBuilder: (context, index) {
                final oferta = ofertas[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monto: S/${oferta.monto.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Tipo de oferta: ${oferta.filtroAlquiler ? "Oferta por hora" : "Oferta por noche"}',
                            ),
                            Text('Usuario: ${oferta.name}'),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.autorenew),
                              tooltip: 'Contraoferta',
                              onPressed: () {
                                // Lógica para contraoferta
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              tooltip: 'Ignorar',
                              onPressed: () {
                                // Lógica para ignorar
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
