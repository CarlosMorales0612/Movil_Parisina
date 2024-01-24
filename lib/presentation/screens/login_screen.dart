import 'dart:convert';
import 'package:consumo_api_libros/main.dart';
import 'package:consumo_api_libros/presentation/screens/admin_user_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:consumo_api_libros/presentation/screens/admin_screen.dart';
import 'package:consumo_api_libros/presentation/screens/books_screen.dart';
import 'package:consumo_api_libros/presentation/screens/user_register_screen.dart';
import 'package:consumo_api_libros/presentation/screens/auth-service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isVisible = true;

  void apiLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, llene todos los campos"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dentro de tu función apiLogin después de obtener la respuesta
    try {
      final response = await _authService.login(email, password);
      print('API Response: $response');

      if (response is Map<String, dynamic>) {
        final message =
            response['message'] as String? ?? 'Mensaje predeterminado';
        final user = response['usuario'] as Map<String, dynamic>? ?? {};

        final snackBar = SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Verifica si la respuesta contiene un token y un usuario
        if (response.containsKey('token') && user != null) {
          final rolId =
              user['rol_usuario'] as String? ?? 'ValorPredeterminado';

          print(
              'Redirigiendo a la pantalla correspondiente para el rol con ID: $rolId');

          // Ajusta el ID del rol según tu lógica
          Future.delayed(const Duration(milliseconds: 500), () {
            // Verifica el ID del rol y redirige a la pantalla correspondiente
            if (rolId == '6547f25b67ec1e25d0c5d17a') {
              // Redirige a la pantalla de AdminUserScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminScreen(),
                ),
              );
            } else {
              // Redirige a la pantalla de BooksScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const BooksScreen(),
                ),
              );
            }
          });
        } else {
          print('La respuesta no contiene un token o el usuario es nulo.');
        }
      } else {
        final snackBar = SnackBar(
          content: Text('Error en la respuesta de la API'),
          backgroundColor: Colors.red,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (error) {
      // Manejar el error
      print('Error during login: $error');

      if (error is Exception) {
        String errorMessage = 'Error en el inicio de sesión';

        if (error.toString().contains('El usuario está inactivo.')) {
          errorMessage = 'El usuario está inactivo.';
        } else if (error.toString().contains('Credenciales incorrectas.')) {
          errorMessage = 'Credenciales incorrectas.';
        }

        final snackBar = SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  TextStyle _getErrorMessageStyle(BuildContext context) {
    // Obtiene el tema actual
    final currentTheme = Theme.of(context);

    // Ajusta el estilo del texto según el tema
    return TextStyle(
      color: currentTheme.brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).viewInsets;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          automaticallyImplyLeading: true,
          actions: [
            IconButton(
              onPressed: () {
                // Accede al tema directamente desde el contexto
                final currentTheme = Theme.of(context);
                // Realiza la lógica para cambiar el tema
                // ...

                // Actualiza la interfaz de usuario según sea necesario
                setState(() {
                  // Actualiza la interfaz de usuario si es necesario
                });
              },
              icon: Theme.of(context).brightness == Brightness.light
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        reverse: true, // Añade esta línea
        child: Padding(
          padding: EdgeInsets.only(
            bottom: padding.bottom > 0 ? padding.bottom + 20.0 : 1.0,
            top: padding.bottom > 0 ? 20.0 : 70.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Correo electrónico",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: _isVisible,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: const Icon(Icons.password_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisible = !_isVisible;
                            });
                          },
                          icon: _isVisible
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  apiLogin();
                },
                child: const Text(
                  "Iniciar Sesión",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 15, 176, 50),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
