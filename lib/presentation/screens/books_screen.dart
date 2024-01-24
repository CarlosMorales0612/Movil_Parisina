import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BooksScreen extends StatefulWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Map<String, dynamic>> usuarios = [];
  String? userEmail = '';

  @override
  void initState() {
    super.initState();
    // Obtén el correo electrónico del usuario desde SharedPreferences
    getLoggedInUserEmail();
  }

  // Función para obtener el correo electrónico del usuario
  Future<void> getLoggedInUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('user_email');

    if (userEmail != null) {
      // Llama a fetchDomiciliario con el correo electrónico obtenido
      fetchDomiciliario(userEmail);
    } else {
      print('Error in getLoggedInUserEmail: User email not available');
    }
  }

  Future<void> fetchDomiciliario(String? correo) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        print('Error in fetchDomiciliario: Token not available');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://proyectolaparisina.onrender.com/api/empleado/$correo'),
        headers: {'x-token': token},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Verificar si la lista tiene elementos
        if (responseData.isNotEmpty) {
          // Puedes procesar cada elemento de la lista según tus necesidades
          List<Map<String, dynamic>> domiciliarios = [];
          for (final Map<String, dynamic> domiciliarioData in responseData) {
            print('Domiciliario: $domiciliarioData');

            // Puedes realizar operaciones adicionales aquí según tus necesidades

            domiciliarios
                .add(domiciliarioData); // Agregar a la lista si es necesario
          }

          // Actualiza la lista de usuarios con la información obtenida.
          setState(() {
            usuarios = domiciliarios;
          });
        } else {
          print('Error in fetchDomiciliario: Empty response');
          // Puedes manejar el caso de una respuesta vacía según tus necesidades.
        }
      } else {
        print('Error in fetchDomiciliario: ${response.statusCode}');
        // Puedes manejar el error aquí según tus necesidades.
      }
    } catch (error) {
      print('Error in fetchDomiciliario: $error');
      // Puedes manejar el error aquí según tus necesidades.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Domiciliarios'),
      ),
      body: usuarios.isNotEmpty
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: usuarios.map((user) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nombre: ${user['nombre_contacto']}'),
                          SizedBox(
                            height: 8,
                          ),
                          Text('Teléfono: ${user['telefono_cliente']}'),
                          SizedBox(
                            height: 8,
                          ),
                          Text('Barrio: ${user['barrio_cliente']}'),
                          SizedBox(
                            height: 8,
                          ),
                          Text('Dirección: ${user['direccion_entrega']}'),
                          SizedBox(
                            height: 8,
                          ),
                          Text('Estado Pedido: ${user['estado_pedido']}'),
                          SizedBox(
                            height: 8,
                          ),
                          Text('Estado Pago: ${user['estado_pago']}'),
                          SizedBox(
                            height: 8,
                          ),
                          Text('Precio: ${user['precio_total_venta']}'),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  print(
                                      'Primer botón presionado para ${user['nombre_contacto']}');
                                  _mostrarModal(context, user);
                                },
                                icon: Icon(Icons.visibility),
                                label: Text('Ver'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  print(
                                      'Segundo botón presionado para ${user['nombre_contacto']}');
                                  _mostrarDialogoConfirmacion(context, user);
                                },
                                icon: Icon(Icons.check),
                                label: Text('Aceptar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          : Center(
              child: usuarios.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3),
                        Text(
                          'No hay pedidos asociados al correo.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    )
                  : CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Llama a fetchDomiciliario nuevamente al hacer clic en el botón flotante
          fetchDomiciliario(userEmail);
        },
        child: Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Posiciona el botón flotante en la esquina inferior derecha
    );
  }

  void _mostrarDialogoConfirmacion(
      BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text(
              '¿Estás seguro de que deseas marcar el pedido como entregado?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enviarPeticionAPI(user);
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModal(BuildContext context, Map<String, dynamic> user) {
    final List<Widget> widgets = [];

    widgets.add(
      Text('Detalles del usuario: ${user['nombre_contacto']}'),
    );

    widgets.add(
      SizedBox(height: 16),
    );

  for (var entry in user.entries) {
  if (entry.key == '_id') {
    // Excluir el campo '_id'
    continue;
  }

  if (user['tipo_cliente'] == 'Persona natural') {
    if (entry.key == 'correo_domiciliario' ||
        entry.key == 'nombre_juridico' ||
        entry.key == 'nit_empresa_cliente' ||
        entry.key == 'aumento_empresa'||
        entry.key == 'empleado_id' ||
        entry.key == '__V:0') {
      continue;
    }
  }

  else if(user['tipo_cliente'] == 'Persona jurídica'){
    if (entry.key == 'quien_recibe' ||
        entry.key == 'correo_domiciliario' ||
        entry.key == 'aumento_empresa'||
        entry.key == 'empleado_id' ||
        entry.key == '__v:0') {
      continue;
    }
  }

  if (entry.key == 'detalle_pedido' && entry.value is List<dynamic>) {
    final List<dynamic> detalle = entry.value;
    widgets.add(SizedBox(height: 16));

    widgets.add(
      Table(
        defaultColumnWidth: FlexColumnWidth(),
        children: [
          TableRow(
            children: [
              Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Cantidad',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          TableRow(
            children: [
              Text('${detalle[0]['nombre_producto']}'),
              Text('${detalle[0]['cantidad_producto']}'),
              Text('${detalle[0]['precio_total_producto']}'),
            ],
          ),
        ],
      ),
    );
  } else {
    widgets.add(
      Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '${entry.key}: ${entry.value}',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

    widgets.add(
      SizedBox(height: 16),
    );

    widgets.add(
      ElevatedButton(
        onPressed: () {
          print('Botón dentro del modal presionado');
          Navigator.pop(context);
        },
        child: Text('Cerrar'),
      ),
    );

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  void _enviarPeticionAPI(Map<String, dynamic> pedido) async {
    try {
      pedido['estado_pedido'] = 'Entregado';
      final response = await http.put(
        Uri.parse(
            'https://proyectolaparisina.onrender.com/api/pedidos/${pedido['_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pedido),
      );

      if (response.statusCode == 200) {
        // Update the state inside the setState callback
        setState(() {
          fetchDomiciliario(userEmail);
        });

        print('Petición API exitosa');
        print(response.body);
      } else {
        print('Error en la petición API: ${response.statusCode}');
        print(response.body);
      }
    } catch (error) {
      print('Error en la petición API: $error');
    }
  }
}
