import 'dart:ui';
import 'package:flutter/material.dart';

const _bg = Color(0xFF0A0E14);
const _gold = Color(0xFFD4AF37);
const _goldBright = Color(0xFFFFB800);
const _goldDark = Color(0xFFB8860B);
const _surface = Color(0xFF1A1A1A);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _gold.withOpacity(0.06),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          Column(
            children: [
              _TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CertifiedBanner(),
                          const SizedBox(height: 28),
                          _WelcomeCard(),
                          const SizedBox(height: 20),
                          _StatsRow(),
                          const SizedBox(height: 20),
                          _QuickActions(),
                          const SizedBox(height: 20),
                          _ActivityFeed(),
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

          // Bottom nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNav(),
          ),
        ],
      ),
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.dashboard_outlined, color: _gold, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('CENTRO DE MANDO',
                style: TextStyle(
                    color: _goldBright,
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
          Stack(children: [
            Icon(Icons.notifications_outlined,
                color: Colors.white.withOpacity(0.4), size: 24),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: _goldBright, shape: BoxShape.circle),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Certified banner ──────────────────────────────────────────────────────────

class _CertifiedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _gold.withOpacity(0.12),
                _goldDark.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _gold.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: _gold.withOpacity(0.08),
                  blurRadius: 32,
                  spreadRadius: 2),
            ],
          ),
          child: Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withOpacity(0.15),
                border: Border.all(color: _gold, width: 2),
              ),
              child: const Icon(Icons.verified, color: _gold, size: 28),
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BIENVENIDO AL CENTRO DE MANDO NEXO',
                      style: TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'CUENTA CERTIFICADA — Operador Élite Activo',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 0.5),
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Welcome card ──────────────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold.withOpacity(0.08)),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.wb_sunny_outlined,
                      color: _gold.withOpacity(0.7), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'HOY — ${_today()}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700),
                  ),
                ]),
                const SizedBox(height: 10),
                const Text('Listo para operar',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'Su perfil está activo y certificado. '
                  'Las cargas disponibles se muestran abajo.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
              ]),
        ),
      ),
    );
  }

  String _today() {
    final now = DateTime.now();
    const months = [
      'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: _StatCard(
              icon: Icons.local_shipping_outlined,
              value: '0',
              label: 'Cargas\nActivas')),
      const SizedBox(width: 12),
      Expanded(
          child: _StatCard(
              icon: Icons.attach_money,
              value: '\$0',
              label: 'Ganancias\nSemanales')),
      const SizedBox(width: 12),
      Expanded(
          child: _StatCard(
              icon: Icons.star_outline,
              value: '5.0',
              label: 'Rating\nOperador')),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withOpacity(0.08)),
      ),
      child: Column(children: [
        Icon(icon, color: _gold, size: 22),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: _gold, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withOpacity(0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ACCIONES RÁPIDAS',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Row(children: [
          _ActionBtn(
              icon: Icons.search,
              label: 'Buscar\nCargas',
              onTap: () {
                final jwt = ModalRoute.of(context)?.settings.arguments as String?;
                Navigator.of(context).pushReplacementNamed('/loads', arguments: jwt);
              }),
          const SizedBox(width: 10),
          _ActionBtn(
              icon: Icons.route_outlined,
              label: 'Ver\nRutas',
              onTap: () {}),
          const SizedBox(width: 10),
          _ActionBtn(
              icon: Icons.support_agent_outlined,
              label: 'Soporte\nÉlite',
              onTap: () {}),
          const SizedBox(width: 10),
          _ActionBtn(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Mi\nCuenta',
              onTap: () {}),
        ]),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _gold.withOpacity(0.15)),
          ),
          child: Column(children: [
            Icon(icon, color: _gold, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

// ── Activity feed ─────────────────────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withOpacity(0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ACTIVIDAD RECIENTE',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _FeedItem(
          icon: Icons.verified_user_outlined,
          iconColor: Colors.green,
          title: 'Cuenta certificada exitosamente',
          subtitle: 'Bienvenido a NEXO ÉLITE GLOBAL',
          time: 'Hoy',
        ),
        const Divider(color: Colors.white10, height: 24),
        Center(
          child: Text(
            'Las cargas disponibles aparecerán aquí\ncuando sean asignadas por el sistema.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }
}

class _FeedItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  const _FeedItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ])),
      Text(time,
          style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
              letterSpacing: 0.5)),
    ]);
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
    ]);
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
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
          children: [
            _NavBtn(Icons.local_shipping_outlined, 'Fleet', false),
            _NavBtn(Icons.receipt_long_outlined, 'Loads', false),
            _NavBtn(Icons.explore_outlined, 'Routes', false),
            _NavBtn(Icons.person, 'Account', true),
          ],
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavBtn(this.icon, this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              color: active ? _gold : Colors.white.withOpacity(0.3),
              size: 22),
          const SizedBox(height: 3),
          Text(label.toUpperCase(),
              style: TextStyle(
                  color: active ? _gold : Colors.white.withOpacity(0.3),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
        ]),
      ),
    );
  }
}
