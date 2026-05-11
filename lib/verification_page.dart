import 'dart:ui';
import 'package:flutter/material.dart';

const _bg = Color(0xFF0A0E14);
const _gold = Color(0xFFD4AF37);
const _goldBright = Color(0xFFFFB800);
const _goldDark = Color(0xFFB8860B);
const _surface = Color(0xFF1A1A1A);
const _outline = Color(0xFF4D4635);
const _outlineVariant = Color(0xFF4D4635);

// ── Shared bottom-nav items ──────────────────────────────────────────────────
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

// ── Upload state ─────────────────────────────────────────────────────────────
enum _UploadState { idle, uploading, done }

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  int _navIndex = 3; // Account tab active

  _UploadState _cdlState = _UploadState.idle;
  _UploadState _insuranceState = _UploadState.idle;
  _UploadState _cabCardState = _UploadState.idle;
  _UploadState _biometricState = _UploadState.idle;

  Future<void> _simulateUpload(
      void Function(_UploadState) setter) async {
    setter(_UploadState.uploading);
    setState(() {});
    await Future.delayed(const Duration(seconds: 2));
    setter(_UploadState.done);
    setState(() {});
  }

  bool get _allDone =>
      _cdlState == _UploadState.done &&
      _insuranceState == _UploadState.done &&
      _cabCardState == _UploadState.done &&
      _biometricState == _UploadState.done;

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
                            state: _cdlState,
                            onCapture: () => _simulateUpload(
                                (s) => _cdlState = s),
                          ),
                          const SizedBox(height: 16),
                          _InsuranceModule(
                            insuranceState: _insuranceState,
                            cabCardState: _cabCardState,
                            onInsurance: () => _simulateUpload(
                                (s) => _insuranceState = s),
                            onCabCard: () => _simulateUpload(
                                (s) => _cabCardState = s),
                          ),
                          const SizedBox(height: 16),
                          _BiometricModule(
                            state: _biometricState,
                            onScan: () => _simulateUpload(
                                (s) => _biometricState = s),
                          ),
                          const SizedBox(height: 24),
                          if (_allDone) _ContinueButton(),
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
          // Bottom nav pinned over scroll
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

// ── Top bar ──────────────────────────────────────────────────────────────────

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
        border: Border(
          bottom: BorderSide(color: _gold.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
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
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const Text(
            'NEXO ÉLITE',
            style: TextStyle(
              color: _gold,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontSize: 16,
            ),
          ),
          Icon(Icons.notifications_outlined,
              color: Colors.white.withOpacity(0.35), size: 22),
        ],
      ),
    );
  }
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _HeroTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Text(
            'NEXO ÉLITE GLOBAL',
            style: TextStyle(
              color: _gold,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete su verificación de seguridad de alto nivel',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Glass card base ───────────────────────────────────────────────────────────

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

// ── Section icon header ──────────────────────────────────────────────────────

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
    return Row(
      children: [
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle.toUpperCase(),
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
          ],
        ),
      ],
    );
  }
}

// ── Gold button ──────────────────────────────────────────────────────────────

class _GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final _UploadState state;

  const _GoldButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.state = _UploadState.idle,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = state == _UploadState.done;
    final isLoading = state == _UploadState.uploading;

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(double.infinity, 48),
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isDone ? Icons.check_circle_outlined : icon,
                      color: isDone ? Colors.white : const Color(0xFF3C2F00),
                      size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isDone ? 'DOCUMENTO CARGADO' : label,
                    style: TextStyle(
                      color:
                          isDone ? Colors.white : const Color(0xFF3C2F00),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── CDL Module ────────────────────────────────────────────────────────────────

class _CdlModule extends StatelessWidget {
  final _UploadState state;
  final VoidCallback onCapture;

  const _CdlModule({required this.state, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.badge_outlined,
            iconColor: _gold,
            iconBg: _gold.withOpacity(0.1),
            title: 'Licencia Comercial (CDL)',
            subtitle: 'Documento Clase A Requerido',
          ),
          const SizedBox(height: 20),
          // Preview area
          Container(
            height: 168,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E14).withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: state == _UploadState.done
                      ? Colors.green.withOpacity(0.5)
                      : _outlineVariant,
                  style: BorderStyle.solid,
                  width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Placeholder image
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBHjH2pPpxtzV0bbNp-_ftj_z2XV_OwTnSFlMgp2kqGOPx8lsEmXJVxqobn4Ri4S2Mb9v9jQJpvFilCCJDJmvcp_iaRxBuU9bZzF-80gIIFTsEkIqDCX9vmz-owVjIDt3JUKycwne3ZVDj2IZQEK2UNGUg9ig-eCuvrHf3tkREL_9ryyOXuxDX4JuKG2aFqEcEmgME7skEWIQK2Lg2k-XiYDGLudLShO6joPpCiaKFi01pSIGL7VRYRvuHj80ixifrZ-RxRylEPsw',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    opacity: AlwaysStoppedAnimation(
                        state == _UploadState.done ? 0.6 : 0.2),
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  // Overlay
                  if (state != _UploadState.done)
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
                      ],
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(Icons.check_circle,
                          color: Colors.green, size: 48),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _GoldButton(
            label: 'CAPTURAR FRENTE',
            icon: Icons.photo_camera_outlined,
            state: state,
            onPressed: onCapture,
          ),
        ],
      ),
    );
  }
}

// ── Insurance/Cab Card Module ─────────────────────────────────────────────────

class _InsuranceModule extends StatelessWidget {
  final _UploadState insuranceState;
  final _UploadState cabCardState;
  final VoidCallback onInsurance;
  final VoidCallback onCabCard;

  const _InsuranceModule({
    required this.insuranceState,
    required this.cabCardState,
    required this.onInsurance,
    required this.onCabCard,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF4AE183),
            iconBg: const Color(0xFF4AE183).withOpacity(0.08),
            title: 'Seguro y Registro',
            subtitle: 'Validación de Unidad Pesada',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _UploadTile(
                  label: 'Subir Seguro',
                  state: insuranceState,
                  onTap: onInsurance,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _UploadTile(
                  label: 'Subir Cab Card',
                  state: cabCardState,
                  onTap: onCabCard,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final _UploadState state;
  final VoidCallback onTap;

  const _UploadTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = state == _UploadState.done;
    final isLoading = state == _UploadState.uploading;

    return GestureDetector(
      onTap: (isDone || isLoading) ? null : onTap,
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
                : _outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: _gold, strokeWidth: 2))
                : Icon(
                    isDone ? Icons.check_circle_outlined : Icons.upload_file_outlined,
                    color: isDone ? Colors.green : _gold,
                    size: 24),
            const SizedBox(height: 8),
            Text(
              isDone ? 'CARGADO' : label.toUpperCase(),
              style: TextStyle(
                color: isDone
                    ? Colors.green.withOpacity(0.8)
                    : Colors.white.withOpacity(0.75),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Biometric Module ──────────────────────────────────────────────────────────

class _BiometricModule extends StatelessWidget {
  final _UploadState state;
  final VoidCallback onScan;

  const _BiometricModule({required this.state, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final isDone = state == _UploadState.done;

    return _GlassCard(
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Circular biometric viewer
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A0E14),
                  border: Border.all(
                    color: isDone ? Colors.green : _gold,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDone ? Colors.green : _gold).withOpacity(0.2),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDjbYTZ3VRjPEtQ0RY46gulgzpmNZQl5Dg9xnuf3lJi_Fdi4kGV8TuzWKiIOjx1hS9AkDuShzDvqRh5It2G5a5QIfPt-Evs5VHX_la699X1G90JDZx5ZZt5jPwhE-RcfmZ7scDy42ZuGiBhk2urUnRmKxjXa0gXfx3zX422emN-Hrrz18xxAOyYB6PTev6gzUGRCg3EwRTlcOl1HOCGYmr6NExx5An2TP01SsSHqRyCkUmtZJvq1VNKrPa9xrdMtWQqKovXsgdwtQ',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1A1A2E),
                          child: const Icon(Icons.person,
                              color: Colors.white30, size: 56),
                        ),
                      ),
                      // Golden overlay tint
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              _gold.withOpacity(0.12),
                            ],
                          ),
                        ),
                      ),
                      if (isDone)
                        Container(
                          color: Colors.black54,
                          child: const Icon(Icons.check_circle,
                              color: Colors.green, size: 48),
                        ),
                    ],
                  ),
                ),
              ),
              // Verified badge
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
                          color: (isDone ? Colors.green : _gold)
                              .withOpacity(0.4),
                          blurRadius: 8),
                    ],
                  ),
                  child: Icon(
                    isDone ? Icons.verified : Icons.fingerprint,
                    size: 16,
                    color: isDone ? Colors.white : const Color(0xFF3C2F00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Validación de Identidad',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Reconocimiento facial de grado industrial',
            style: TextStyle(
                color: Colors.white.withOpacity(0.45), fontSize: 13),
          ),
          const SizedBox(height: 20),
          _GoldButton(
            label: 'INICIAR ESCANEO FACIAL',
            icon: Icons.face_retouching_natural_outlined,
            state: state,
            onPressed: onScan,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Continue button (shown when all docs uploaded) ───────────────────────────

class _ContinueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withOpacity(0.4)),
        color: _gold.withOpacity(0.08),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outlined, color: _gold, size: 28),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verificación Completa',
                    style: TextStyle(
                        color: _gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text('Todos los documentos han sido enviados.',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: _gold, size: 16),
        ],
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────────────────

class _PageFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.white10),
        const SizedBox(height: 16),
        const Text(
          'NEXO ÉLITE GLOBAL © 2026',
          style: TextStyle(
              color: _gold,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              fontSize: 11),
          textAlign: TextAlign.center,
        ),
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
      ],
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? _gold.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isActive
                            ? _gold
                            : Colors.white.withOpacity(0.3),
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label.toUpperCase(),
                        style: TextStyle(
                          color: isActive
                              ? _gold
                              : Colors.white.withOpacity(0.3),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
