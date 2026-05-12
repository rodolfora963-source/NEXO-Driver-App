import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'register_page.dart';
import 'verification_page.dart';
import 'screens/verification_status_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/app_router.dart';

void main() {
  runApp(const NexoDriverApp());
}

class NexoDriverApp extends StatelessWidget {
  const NexoDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXO Elite Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF1A1A1A),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthGateway(),
        '/register': (_) => const RegisterPage(),
        '/verification': (_) => const VerificationPage(),
        '/status': (_) => const VerificationStatusScreen(),
        '/dashboard': (_) => const DashboardScreen(),
      },
    );
  }
}

// ── Auth Gateway — reads URL params, decides first screen ─────────────────────

class AuthGateway extends StatefulWidget {
  const AuthGateway({super.key});

  @override
  State<AuthGateway> createState() => _AuthGatewayState();
}

class _AuthGatewayState extends State<AuthGateway> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Read URL query params — works on Flutter Web via Uri.base
    final uri = Uri.base;
    final magic = uri.queryParameters['magic'];
    final directJwt = uri.queryParameters['jwt'];

    String? jwt = directJwt;

    // Exchange magic token for session JWT
    if (magic != null && magic.isNotEmpty) {
      final result = await AuthService.verifyMagicLink(magic);
      if (!mounted) return;

      if (!result.success) {
        setState(() => _error =
            'El enlace de activación es inválido o ha expirado.\n'
            'Solicita uno nuevo desde la pantalla de registro.');
        return;
      }
      jwt = result.jwt;
    }

    if (!mounted) return;

    if (jwt == null || jwt.isEmpty) {
      // No auth — go to registration
      Navigator.of(context).pushReplacementNamed('/register');
      return;
    }

    // Route based on document status
    await routeFromJwt(context, jwt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Center(
        child: _error != null
            ? _ErrorCard(
                message: _error!,
                onRetry: () => Navigator.of(context)
                    .pushReplacementNamed('/register'),
              )
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      color: Color(0xFFD4AF37), strokeWidth: 2),
                  SizedBox(height: 20),
                  Text(
                    'NEXO ÉLITE GLOBAL',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Verificando sesión...',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link_off, color: Color(0xFFD4AF37), size: 48),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0A0E14),
            ),
            child: const Text('IR AL REGISTRO',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}
