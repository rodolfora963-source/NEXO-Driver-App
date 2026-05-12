import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/document_status.dart';
import '../services/document_service.dart';

const _bg = Color(0xFF0A0E14);
const _gold = Color(0xFFD4AF37);
const _goldDark = Color(0xFFB8860B);
const _surface = Color(0xFF1A1A1A);

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState
    extends State<VerificationStatusScreen> {
  DocumentStatus? _status;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_status == null) _load();
  }

  Future<void> _load() async {
    final jwt =
        ModalRoute.of(context)?.settings.arguments as String?;
    if (jwt == null) {
      setState(() {
        _loading = false;
        _error = 'Sesión no disponible. Inicia sesión nuevamente.';
      });
      return;
    }

    try {
      final status = await DocumentService(jwt).getStatus();
      if (mounted) setState(() { _status = status; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Error cargando estado: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jwt = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _TopBar(),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: _gold, strokeWidth: 2))
              : _error != null
                  ? _ErrorBody(message: _error!)
                  : _StatusBody(
                      status: _status!,
                      jwt: jwt,
                      onRetry: () => Navigator.of(context)
                          .pushReplacementNamed('/verification',
                              arguments: jwt),
                    ),
        ),
      ]),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1017).withOpacity(0.96),
        border: Border(bottom: BorderSide(color: _gold.withOpacity(0.15))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: const Icon(Icons.arrow_back,
                  color: _gold, size: 22),
            ),
            const SizedBox(width: 14),
            const Text('ESTADO DE VERIFICACIÓN',
                style: TextStyle(
                    color: Color(0xFFFFB800),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    fontSize: 10)),
          ]),
          const Text('NEXO ÉLITE',
              style: TextStyle(
                  color: _gold,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  fontSize: 16)),
          Icon(Icons.notifications_outlined,
              color: Colors.white.withOpacity(0.35), size: 22),
        ],
      ),
    );
  }
}

// ── Status body ───────────────────────────────────────────────────────────────

class _StatusBody extends StatelessWidget {
  final DocumentStatus status;
  final String? jwt;
  final VoidCallback onRetry;

  const _StatusBody({
    required this.status,
    required this.jwt,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = status.status == 'rejected';
    final isApproved = status.status == 'approved';

    final Color accentColor = isApproved
        ? Colors.green
        : isRejected
            ? Colors.redAccent
            : _gold;

    final IconData statusIcon = isApproved
        ? Icons.verified
        : isRejected
            ? Icons.cancel_outlined
            : Icons.hourglass_top_outlined;

    final String statusTitle = isApproved
        ? '¡Documentos Aprobados!'
        : isRejected
            ? 'Documentos Rechazados'
            : 'Documentos en Revisión';

    final String statusMsg = isApproved
        ? 'Tu cuenta ha sido certificada. Eres un operador élite activo.'
        : isRejected
            ? 'Algunos documentos no pasaron la revisión. '
              'Por favor vuelve a enviarlos.'
            : 'Nuestro equipo está revisando tus documentos. '
              'Te notificaremos por email cuando concluya.';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status card
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: _surface.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: accentColor.withOpacity(0.25)),
                      boxShadow: [
                        BoxShadow(
                            color: accentColor.withOpacity(0.08),
                            blurRadius: 28),
                      ],
                    ),
                    child: Column(children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withOpacity(0.1),
                          border: Border.all(
                              color: accentColor, width: 2),
                        ),
                        child: Icon(statusIcon,
                            color: accentColor, size: 36),
                      ),
                      const SizedBox(height: 20),
                      Text(statusTitle,
                          style: TextStyle(
                              color: accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text(statusMsg,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14),
                          textAlign: TextAlign.center),

                      if (status.reviewNotes != null &&
                          status.reviewNotes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: accentColor.withOpacity(0.2)),
                          ),
                          child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('NOTAS DEL REVISOR',
                                    style: TextStyle(
                                        color:
                                            accentColor.withOpacity(0.8),
                                        fontSize: 10,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(status.reviewNotes!,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13)),
                              ]),
                        ),
                      ],
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Per-document status
              _DocChecklist(status: status),

              const SizedBox(height: 24),

              // Actions
              if (isRejected)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFFB800), _gold, _goldDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: _gold.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.upload_file_outlined,
                        color: Color(0xFF3C2F00), size: 20),
                    label: const Text('VOLVER A ENVIAR DOCUMENTOS',
                        style: TextStyle(
                            color: Color(0xFF3C2F00),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            fontSize: 12)),
                  ),
                ),

              if (isApproved)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.green.shade600,
                      Colors.green.shade800,
                    ]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed('/loads',
                            arguments: jwt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.dashboard_outlined,
                        color: Colors.white, size: 20),
                    label: const Text('IR AL CENTRO DE MANDO',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Per-doc checklist ─────────────────────────────────────────────────────────

class _DocChecklist extends StatelessWidget {
  final DocumentStatus status;
  const _DocChecklist({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withOpacity(0.08)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DOCUMENTOS ENVIADOS',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _DocRow(Icons.badge_outlined, 'CDL — Licencia Comercial',
                status.hasCdl),
            const Divider(color: Colors.white10, height: 16),
            _DocRow(Icons.shield_outlined, 'Seguro de Unidad',
                status.hasInsurance),
            const Divider(color: Colors.white10, height: 16),
            _DocRow(Icons.credit_card_outlined, 'Cab Card / Registro',
                status.hasCabCard),
            const Divider(color: Colors.white10, height: 16),
            _DocRow(Icons.face_retouching_natural_outlined,
                'Selfie Biométrica', status.hasSelfie),
          ]),
    );
  }
}

class _DocRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool has;
  const _DocRow(this.icon, this.label, this.has);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon,
          color: has ? Colors.green : Colors.white38, size: 20),
      const SizedBox(width: 12),
      Expanded(
          child: Text(label,
              style: TextStyle(
                  color: has
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white38,
                  fontSize: 13))),
      Icon(
          has ? Icons.check_circle_outlined : Icons.radio_button_unchecked,
          color: has ? Colors.green : Colors.white24,
          size: 18),
    ]);
  }
}

// ── Error body ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/register'),
            style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: const Color(0xFF0A0E14)),
            child: const Text('IR AL REGISTRO',
                style: TextStyle(
                    fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
        ]),
      ),
    );
  }
}
