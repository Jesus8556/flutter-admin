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
  bool isAvailable;

  Garage({
    required this.id,
    required this.address,
    required this.description,
    required this.isAvailable,
  });

  factory Garage.fromJson(Map<String, dynamic> json) {
    return Garage(
      id: json['_id'],
      address: json['address'],
      description: json['description'],
      isAvailable: json['isAvailable'] == 'true',
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
      Uri.parse('https://parking-back-pt6g.onrender.com/api/garage'),
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
                    return ListTile(
                      title: Text(garage.address),
                      subtitle: Text(garage.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: garage.isAvailable,
                            onChanged: (value) {
                              // Cambiar disponibilidad
                              final newAvailability = !garage.isAvailable;
                              final updatedGarage = Garage(
                                id: garage.id,
                                address: garage.address,
                                description: garage.description,
                                isAvailable: newAvailability,
                              );

                              setState(() {
                                garages[index] = updatedGarage;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              // Código para eliminar el garaje
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(padding: EdgeInsets.only(bottom: 50),
            child: FloatingActionButton(
              onPressed:(){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddGaragePage()),
                  );
              } ,
              child: Icon(Icons.add),
              tooltip: "Crear nuevo garage",
              ),),)
        ],
      ),
    );
  }
}
