import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/document_service.dart';

const _bg = Color(0xFF0A0E14);
const _gold = Color(0xFFD4AF37);
const _goldBright = Color(0xFFFFB800);
const _goldDark = Color(0xFFB8860B);
const _surface = Color(0xFF1A1A1A);
const _outlineVariant = Color(0xFF4D4635);

const _navItems = [
  _NavItem(Icons.local_shipping_outlined, 'Fleet'),
  _NavItem(Icons.receipt_long_outlined, 'Loads'),
  _NavItem(Icons.explore_outlined, 'Routes'),
  _NavItem(Icons.person, 'Account'),
];

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

enum _UploadState { idle, uploading, done }

class _DocFile {
  final Uint8List bytes;
  final String name;
  const _DocFile(this.bytes, this.name);
}

// ─────────────────────────────────────────────────────────────────────────────

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  int _navIndex = 3;
  final _picker = ImagePicker();

  _DocFile? _cdlFile;
  _DocFile? _insuranceFile;
  _DocFile? _cabCardFile;
  _DocFile? _selfieFile;

  _UploadState _submitState = _UploadState.idle;
  String? _submitError;

  bool get _allPicked =>
      _cdlFile != null &&
      _insuranceFile != null &&
      _cabCardFile != null &&
      _selfieFile != null;

  Future<_DocFile?> _pick({bool camera = false}) async {
    try {
      final xf = await _picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 88,
      );
      if (xf == null) return null;
      final bytes = await xf.readAsBytes();
      return _DocFile(bytes, xf.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar archivo: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _submitAll() async {
    final jwt = ModalRoute.of(context)?.settings.arguments as String?;
    if (jwt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Sesión no autenticada. Complete el registro primero.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _submitState = _UploadState.uploading;
      _submitError = null;
    });

    try {
      final svc = DocumentService(jwt);
      await svc.uploadDocuments(
        cdlBytes: _cdlFile!.bytes,
        cdlName: _cdlFile!.name,
        insuranceBytes: _insuranceFile!.bytes,
        insuranceName: _insuranceFile!.name,
        cabCardBytes: _cabCardFile!.bytes,
        cabCardName: _cabCardFile!.name,
        selfieBytes: _selfieFile!.bytes,
        selfieName: _selfieFile!.name,
      );
      if (mounted) setState(() => _submitState = _UploadState.done);
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitState = _UploadState.idle;
          _submitError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Column(
            children: [
              _TopBar(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 96, 20, 100),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeroTitle(),
                          const SizedBox(height: 20),
                          _CdlModule(
                            file: _cdlFile,
                            onCapture: () async {
                              final f = await _pick();
                              if (f != null) setState(() => _cdlFile = f);
                            },
                          ),
                          const SizedBox(height: 16),
                          _InsuranceModule(
                            insuranceFile: _insuranceFile,
                            cabCardFile: _cabCardFile,
                            onInsurance: () async {
                              final f = await _pick();
                              if (f != null) setState(() => _insuranceFile = f);
                            },
                            onCabCard: () async {
                              final f = await _pick();
                              if (f != null) setState(() => _cabCardFile = f);
                            },
                          ),
                          const SizedBox(height: 16),
                          _BiometricModule(
                            file: _selfieFile,
                            onScan: () async {
                              final f = await _pick(camera: true);
                              if (f != null) setState(() => _selfieFile = f);
                            },
                          ),
                          const SizedBox(height: 24),
                          if (_submitState == _UploadState.done)
                            _SuccessBanner()
                          else if (_allPicked)
                            _SubmitButton(
                              state: _submitState,
                              error: _submitError,
                              onSubmit: _submitAll,
                            ),
                          const SizedBox(height: 40),
                          _PageFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNav(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1017).withOpacity(0.92),
        border: Border(bottom: BorderSide(color: _gold.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            GestureDetector(
              onTap: onBack,
              child: const Icon(Icons.arrow_back, color: _goldBright, size: 22),
            ),
            const SizedBox(width: 14),
            const Text(
              'CERTIFICACIÓN DE OPERADOR',
              style: TextStyle(
                  color: _goldBright,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  fontSize: 10),
            ),
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

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(children: [
        const Text('NEXO ÉLITE GLOBAL',
            style: TextStyle(
                color: _gold,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 3),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Complete su verificación de seguridad de alto nivel',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 14),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

// ── Glass card ────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: iconColor.withOpacity(0.25)),
        ),
        child: Icon(icon, color: iconColor, size: 26),
      ),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle.toUpperCase(),
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5)),
      ]),
    ]);
  }
}

// ── Gold button ───────────────────────────────────────────────────────────────

class _GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDone;
  final bool isLoading;

  const _GoldButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDone = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDone
            ? const LinearGradient(
                colors: [Color(0xFF1A8A3A), Color(0xFF0F6B2A)])
            : const LinearGradient(
                colors: [_goldBright, _gold, _goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: (isDone ? Colors.green : _gold).withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDone || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(double.infinity, 48),
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(isDone ? Icons.check_circle_outlined : icon,
                    color: isDone ? Colors.white : const Color(0xFF3C2F00),
                    size: 18),
                const SizedBox(width: 8),
                Text(
                  isDone ? 'DOCUMENTO CARGADO' : label,
                  style: TextStyle(
                      color: isDone ? Colors.white : const Color(0xFF3C2F00),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1.5),
                ),
              ]),
      ),
    );
  }
}

// ── CDL Module ────────────────────────────────────────────────────────────────

class _CdlModule extends StatelessWidget {
  final _DocFile? file;
  final VoidCallback onCapture;

  const _CdlModule({required this.file, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    final isDone = file != null;
    return _GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionHeader(
          icon: Icons.badge_outlined,
          iconColor: _gold,
          iconBg: _gold.withOpacity(0.1),
          title: 'Licencia Comercial (CDL)',
          subtitle: 'Documento Clase A Requerido',
        ),
        const SizedBox(height: 20),
        Container(
          height: 168,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E14).withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isDone
                    ? Colors.green.withOpacity(0.5)
                    : _outlineVariant,
                width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(alignment: Alignment.center, children: [
              if (isDone)
                Container(
                  color: Colors.green.withOpacity(0.1),
                  child: const Center(
                    child: Icon(Icons.check_circle,
                        color: Colors.green, size: 48),
                  ),
                )
              else
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: Colors.white.withOpacity(0.4), size: 36),
                      const SizedBox(height: 8),
                      Text('Vista previa del documento',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                    ]),
              if (isDone)
                Positioned(
                  bottom: 8,
                  child: Text(file!.name,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10)),
                ),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        _GoldButton(
          label: 'SELECCIONAR CDL',
          icon: Icons.upload_file_outlined,
          isDone: isDone,
          onPressed: onCapture,
        ),
      ]),
    );
  }
}

// ── Insurance/Cab Card Module ─────────────────────────────────────────────────

class _InsuranceModule extends StatelessWidget {
  final _DocFile? insuranceFile;
  final _DocFile? cabCardFile;
  final VoidCallback onInsurance;
  final VoidCallback onCabCard;

  const _InsuranceModule({
    required this.insuranceFile,
    required this.cabCardFile,
    required this.onInsurance,
    required this.onCabCard,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionHeader(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF4AE183),
          iconBg: const Color(0xFF4AE183).withOpacity(0.08),
          title: 'Seguro y Registro',
          subtitle: 'Validación de Unidad Pesada',
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _UploadTile(
                  label: 'Seguro',
                  file: insuranceFile,
                  onTap: onInsurance)),
          const SizedBox(width: 14),
          Expanded(
              child: _UploadTile(
                  label: 'Cab Card',
                  file: cabCardFile,
                  onTap: onCabCard)),
        ]),
      ]),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final _DocFile? file;
  final VoidCallback onTap;

  const _UploadTile({
    required this.label,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = file != null;
    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        decoration: BoxDecoration(
          color: isDone
              ? Colors.green.withOpacity(0.08)
              : const Color(0xFF1F1B13),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isDone
                  ? Colors.green.withOpacity(0.4)
                  : _outlineVariant.withOpacity(0.5)),
        ),
        child: Column(children: [
          Icon(
              isDone
                  ? Icons.check_circle_outlined
                  : Icons.upload_file_outlined,
              color: isDone ? Colors.green : _gold,
              size: 24),
          const SizedBox(height: 8),
          Text(
            isDone ? 'CARGADO' : 'SUBIR $label'.toUpperCase(),
            style: TextStyle(
                color: isDone
                    ? Colors.green.withOpacity(0.8)
                    : Colors.white.withOpacity(0.75),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          if (isDone) ...[
            const SizedBox(height: 4),
            Text(file!.name,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 9),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          ],
        ]),
      ),
    );
  }
}

// ── Biometric Module ──────────────────────────────────────────────────────────

class _BiometricModule extends StatelessWidget {
  final _DocFile? file;
  final VoidCallback onScan;

  const _BiometricModule({required this.file, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final isDone = file != null;
    return _GlassCard(
      child: Column(children: [
        const SizedBox(height: 8),
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A0E14),
              border: Border.all(
                  color: isDone ? Colors.green : _gold, width: 2),
              boxShadow: [
                BoxShadow(
                    color: (isDone ? Colors.green : _gold).withOpacity(0.2),
                    blurRadius: 28,
                    spreadRadius: 2),
              ],
            ),
            child: ClipOval(
              child: isDone
                  ? Container(
                      color: Colors.green.withOpacity(0.15),
                      child: const Icon(Icons.check_circle,
                          color: Colors.green, size: 56),
                    )
                  : Container(
                      color: const Color(0xFF1A1A2E),
                      child: const Icon(Icons.person,
                          color: Colors.white30, size: 56),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : _gold,
                shape: BoxShape.circle,
                border: Border.all(color: _bg, width: 3),
                boxShadow: [
                  BoxShadow(
                      color:
                          (isDone ? Colors.green : _gold).withOpacity(0.4),
                      blurRadius: 8),
                ],
              ),
              child: Icon(isDone ? Icons.verified : Icons.fingerprint,
                  size: 16,
                  color: isDone ? Colors.white : const Color(0xFF3C2F00)),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        const Text('Validación de Identidad',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Reconocimiento facial de grado industrial',
            style: TextStyle(
                color: Colors.white.withOpacity(0.45), fontSize: 13)),
        const SizedBox(height: 20),
        _GoldButton(
          label: 'SELECCIONAR SELFIE',
          icon: Icons.face_retouching_natural_outlined,
          isDone: isDone,
          onPressed: onScan,
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ── Submit button (shown when all 4 files picked) ─────────────────────────────

class _SubmitButton extends StatelessWidget {
  final _UploadState state;
  final String? error;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.state,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_goldBright, _gold, _goldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: _gold.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: state == _UploadState.uploading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: state == _UploadState.uploading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('ENVIANDO DOCUMENTOS...',
                        style: TextStyle(
                            color: Color(0xFF3C2F00),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            fontSize: 12)),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        color: Color(0xFF3C2F00), size: 22),
                    SizedBox(width: 10),
                    Text('ENVIAR DOCUMENTOS AL SISTEMA',
                        style: TextStyle(
                            color: Color(0xFF3C2F00),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            fontSize: 12)),
                  ],
                ),
        ),
      ),
      if (error != null) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Text(error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center),
        ),
      ],
    ]);
  }
}

// ── Success banner ────────────────────────────────────────────────────────────

class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2),
        ],
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 36),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Documentos Enviados',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            SizedBox(height: 4),
            Text('Tu solicitud está en revisión. Te notificaremos pronto.',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _PageFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Divider(color: Colors.white10),
      const SizedBox(height: 16),
      const Text('NEXO ÉLITE GLOBAL © 2026',
          style: TextStyle(
              color: _gold,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              fontSize: 11),
          textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 28,
        children: ['Compliance', 'Privacy', 'Terms']
            .map((t) => Text(t,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600)))
            .toList(),
      ),
    ]);
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1017).withOpacity(0.96),
        border: Border(top: BorderSide(color: _gold.withOpacity(0.1))),
        boxShadow: const [
          BoxShadow(
              color: Colors.black54, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final isActive = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? _gold.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(item.icon,
                        color: isActive
                            ? _gold
                            : Colors.white.withOpacity(0.3),
                        size: 22),
                    const SizedBox(height: 3),
                    Text(item.label.toUpperCase(),
                        style: TextStyle(
                            color: isActive
                                ? _gold
                                : Colors.white.withOpacity(0.3),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
