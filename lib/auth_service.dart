import 'dart:convert';
import 'package:http/http.dart' as http;

const _base = 'https://nexoeliteadvisor.com/api/v1/auth';

class RegisterRequest {
  final String nombreCompleto;
  final String email;
  final String? telefono;
  final String? zipCode;
  final String? equipmentType;
  final bool termsAccepted;

  const RegisterRequest({
    required this.nombreCompleto,
    required this.email,
    this.telefono,
    this.zipCode,
    this.equipmentType,
    required this.termsAccepted,
  });

  Map<String, dynamic> toJson() => {
        'nombre_completo': nombreCompleto,
        'email': email,
        if (telefono != null && telefono!.isNotEmpty) 'telefono': telefono,
        if (zipCode != null && zipCode!.isNotEmpty) 'zip_code': zipCode,
        if (equipmentType != null) 'equipment_type': equipmentType,
        'terms_accepted': termsAccepted,
      };
}

class AuthResult {
  final bool success;
  final String message;
  final String? debugLink;
  final String? error;

  const AuthResult({
    required this.success,
    required this.message,
    this.debugLink,
    this.error,
  });
}

class AuthService {
  static Future<AuthResult> register(RegisterRequest req) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(req.toJson()),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 || res.statusCode == 201) {
        return AuthResult(
          success: true,
          message: body['message'] as String? ?? 'Registro exitoso',
          debugLink: body['debug_link'] as String?,
        );
      }

      final detail = body['detail'];
      final msg = detail is String
          ? detail
          : (detail is List ? detail.map((e) => e['msg']).join(', ') : 'Error desconocido');

      return AuthResult(success: false, message: msg, error: msg);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Sin conexión con el servidor. Intenta de nuevo.',
        error: e.toString(),
      );
    }
  }

  static Future<AuthResult> googleLogin(String idToken) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return AuthResult(success: true, message: 'Bienvenido, ${body['nombre']}');
      }
      return AuthResult(success: false, message: body['detail'] ?? 'Error', error: body['detail']);
    } catch (e) {
      return AuthResult(success: false, message: 'Error de conexión', error: e.toString());
    }
  }
}
