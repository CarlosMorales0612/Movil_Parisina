import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = "https://api-parisina-2tpy.onrender.com/api";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final body = jsonEncode({'correo_electronico': email, 'contrasena_usuario': password});

    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: body,
    );

    if (response.statusCode == 200 && response.body.contains('token')) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];

      // Guarda el token y el correo en SharedPreferences
      saveTokenLocally(token);
      saveUserEmailLocally(email);

      return responseData;
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception(errorResponse);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('user_email');
    prefs.remove('authStatus');
  }

  // Método para almacenar el token localmente
  void saveTokenLocally(String token) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('token', token);
    });
  }

  // Método para almacenar el correo del usuario localmente
  void saveUserEmailLocally(String userEmail) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user_email', userEmail);
    });
  }
}
