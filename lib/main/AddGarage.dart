import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import "package:proyectogaraje/AuthState.dart";
import 'package:provider/provider.dart';
import 'package:proyectogaraje/main/LocationPickerPage.dart';
import 'package:proyectogaraje/screen/NavigationBarApp.dart';


class AddGaragePage extends StatefulWidget {
  @override
  _AddGaragePageState createState() => _AddGaragePageState();
}

class _AddGaragePageState extends State<AddGaragePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
    final TextEditingController _pricePerHourController = TextEditingController();

  bool _isAvailable = true;
  File? _selectedImage;
  double? _latitude;
  double? _longitude;

  Future<void> _submitForm(String token) async {
    if (_addressController.text.isEmpty || _latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Debes agregar una ubicación.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://parking-back-pt6g.onrender.com/api/garage'),
      );
      request.headers['x-access-token'] = token; 

      request.fields['address'] = _addressController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['isAvailable'] = _isAvailable.toString();
      request.fields['pricePerHour'] = _pricePerHourController.text;
      request.fields['latitud'] = _latitude.toString();
      request.fields['longitud'] = _longitude.toString();

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('imagen', _selectedImage!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Garage creado exitosamente')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavigationBarApp()),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creando el garage')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String token = Provider.of<AuthState>(context).token;
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Garage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationPickerPage(
                      onLocationSelected: (lat, lon, address) {
                        setState(() {
                          _latitude = lat;
                          _longitude = lon;
                          _addressController.text = address;
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text("Agregar Ubicación"),
            ),
            TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la dirección';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ingrese una descripción detallada',
                ),
                maxLines: 5, // Permitir más espacio para la descripción
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pricePerHourController,
                decoration: InputDecoration(
                  labelText: 'Precio por hora',
                  hintText: 'Ingrese el precio por hora en números',
                ),
                keyboardType: TextInputType.number, // Para entrada numérica
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el precio por hora';
                  }
                  // Comprobar si es numérico
                  final parsed = double.tryParse(value);
                  if (parsed == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),

              Row(
                children: [
                  Text('Disponible'),
                  Switch(
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                  ),
                ],
              ),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 100,
                ),
              TextButton(
                onPressed: _pickImage,
                child: Text('Cargar Imagen'),
              ),
              ElevatedButton(
                onPressed:() => _submitForm(token),
                child: Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}