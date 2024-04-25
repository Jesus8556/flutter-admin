
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:proyectogaraje/AuthState.dart';
import 'package:proyectogaraje/main/AddGarage.dart';

class Garage {
  final String id;
  final String address;
  final String description;
  final String imageUrl;
  final String pricePerHour;
  final double latitude;
  final double longitude;// URL de la imagen del garaje
  bool isAvailable;

  Garage({
    required this.id,
    required this.address,
    required this.description,
    required this.imageUrl, // Agregar la imagen
    required this.isAvailable,
    required this.pricePerHour,
    required this.latitude,
    required this.longitude,

  });

  factory Garage.fromJson(Map<String, dynamic> json) {
    return Garage(
      id: json['_id'],
      address: json['address'],
      description: json['description'],
      imageUrl: json['imagen']["secure_url"],
      isAvailable: json['isAvailable'],
      pricePerHour: json["pricePerHour"].toString(),
      latitude: json["latitud"],
      longitude:json["longitud"]
    );
  }
}

class GaragePage extends StatefulWidget {
  @override
  _GaragePageState createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  List<Garage> garages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGarages(); // Cargar garajes al inicio
  }

  Future<void> _fetchGarages() async {
    String token = Provider.of<AuthState>(context, listen: false).token;

    final response = await http.get(
      Uri.parse('https://test-2-slyp.onrender.com/api/garage'),
      //Uri.parse('http://192.168.1.7:3000/api/garage'),
      headers: {'x-access-token': token},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        garages = data.map((item) => Garage.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar garajes')),
      );
    }
  }

  // Función para actualizar la disponibilidad del garaje usando PUT
  Future<void> _updateGarageAvailability(
      Garage garage, bool newAvailability) async {
    String token = Provider.of<AuthState>(context, listen: false).token;

    final updatedGarage = {
      'address': garage.address,
      'description': garage.description,
      'isAvailable': newAvailability.toString(),
    };

    final response = await http.put(
      Uri.parse('https://test-2-slyp.onrender.com/api/garage/${garage.id}'),
      //Uri.parse('http://192.168.1.7:3000/api/garage/${garage.id}'),
      headers: {
        'x-access-token': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedGarage), // Enviar todos los datos del recurso
    );

    if (response.statusCode == 200) {
      setState(() {
        garage.isAvailable = newAvailability; // Actualizar el estado local
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la disponibilidad')),
      );
    }
  }

  Future<void> _deleteGarage(String garageId) async {
    String token = Provider.of<AuthState>(context, listen: false).token;

    final response = await http.delete(
      Uri.parse('https://test-2-slyp.onrender.com/api/garage/$garageId'),
      //Uri.parse('http://192.168.1.7:3000/api/garage/$garageId'),
      headers: {'x-access-token': token},
    );
    print(garageId);

    if (response.statusCode == 200) {
      setState(() {
        garages.removeWhere((garage) => garage.id == garageId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Garaje eliminado con éxito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el garaje')),
      );
    }
  }

  Future<bool> _confirmDelete(String garageId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Garaje'),
          content: Text('¿Estás seguro de que quieres eliminar este garaje?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, false); // Cerrar el diálogo y devolver false
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteGarage(garageId);
                Navigator.pop(
                    context, true); // Cerrar el diálogo y devolver true
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false; // Si confirmed es null, devuelve false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GARAGE"),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Indicador de carga mientras se obtiene la lista
            )
          : garages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No se encontraron garajes.',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddGaragePage()),
                          );
                        },
                        child: Text('Crear Garage'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: garages.length,
                  itemBuilder: (context, index) {
                    final garage = garages[index];
                    return Dismissible(
                      key: Key(garage.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await _confirmDelete(
                            garage.id); // Mostrar diálogo de confirmación
                      },
                      background: Container(
                        color:
                            Colors.red, // Fondo rojo para indicar eliminación
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete,
                            color: Colors.white), // Icono de eliminación
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(garage.imageUrl),
                        ),
                        title: Text(garage.address),
                        subtitle: Text(garage.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: garage.isAvailable,
                              onChanged: (value) {
                                // Cambiar disponibilidad
                                _updateGarageAvailability(garage, value);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddGaragePage(
                                      garage:
                                          garage, // Pasar el garaje a actualizar
                                    ),
                                  ),
                                );

                                // Código para eliminar el garaje
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddGaragePage()),
                  );
                },
                child: Icon(Icons.add),
                tooltip: "Crear nuevo garage",
              ),
            ),
          )
        ],
      ),
    );
  }
}
