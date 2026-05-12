import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/load_model.dart';
import '../services/load_service.dart';

const _bg        = Color(0xFF16130B);
const _gold      = Color(0xFFF2CA50);
const _goldDark  = Color(0xFFD4AF37);
const _surface   = Color(0xFF231F17);
const _surfaceHi = Color(0xFF2D2A21);
const _green     = Color(0xFF4AE183);
const _outline   = Color(0xFF4D4635);
const _onSurface = Color(0xFFEAE1D4);
const _onSurfaceVar = Color(0xFFD0C5AF);

final _usd = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0);

// ─────────────────────────────────────────────────────────────────────────────

class LoadBoardScreen extends StatefulWidget {
  const LoadBoardScreen({super.key});

  @override
  State<LoadBoardScreen> createState() => _LoadBoardScreenState();
}

class _LoadBoardScreenState extends State<LoadBoardScreen> {
  int _navIndex = 1; // Loads tab active
  int _filterIndex = 0; // 0=Cerca, 1=Mejor Pago, 2=Rutas Cortas

  List<Load> _loads = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loads.isEmpty) _fetchLoads();
  }

  Future<void> _fetchLoads() async {
    final jwt = ModalRoute.of(context)?.settings.arguments as String?;
    final sort = _filterIndex == 1 ? 'rate' : _filterIndex == 2 ? 'distance' : 'rate';
    setState(() => _loading = true);
    final loads = await LoadService(jwt).getAvailableLoads(sort: sort);
    if (mounted) setState(() { _loads = loads; _loading = false; });
  }

  void _onFilter(int idx) {
    setState(() => _filterIndex = idx);
    _fetchLoads();
  }

  void _showDetails(Load load) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LoadDetailSheet(load: load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _gold.withOpacity(0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          Column(children: [
            _TopBar(),
            Expanded(
              child: RefreshIndicator(
                color: _gold,
                backgroundColor: _surface,
                onRefresh: _fetchLoads,
                child: CustomScrollView(
                  slivers: [
                    // Filters
                    SliverToBoxAdapter(
                      child: _FilterBar(
                        selected: _filterIndex,
                        onSelected: _onFilter,
                      ),
                    ),

                    // Load list
                    if (_loading)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                              color: _gold, strokeWidth: 2),
                        ),
                      )
                    else if (_loads.isEmpty)
                      SliverFillRemaining(
                        child: _EmptyState(onRefresh: _fetchLoads),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) {
                              if (i == _loads.length) {
                                return const _PromoCard();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _LoadCard(
                                  load: _loads[i],
                                  onDetails: () => _showDetails(_loads[i]),
                                ),
                              );
                            },
                            childCount: _loads.length + 1,
                          ),
                        ),
                      ),

                    // Bottom padding for nav bar
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
            ),
          ]),

          // Bottom nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNav(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            ),
          ),

          // FAB map button
          Positioned(
            bottom: 80,
            right: 16,
            child: _MapFab(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16130B).withOpacity(0.85),
        border: Border(bottom: BorderSide(color: _outline.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Cargas Disponibles',
            style: TextStyle(
                color: _onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 22),
          ),
          Row(children: [
            // Online badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.12),
                border: Border.all(color: _gold.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: _green.withOpacity(0.6), blurRadius: 8)
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text('EN LÍNEA',
                    style: TextStyle(
                        color: _green,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _outline),
                color: _surfaceHi,
              ),
              child: const Icon(Icons.person_outline,
                  color: _onSurfaceVar, size: 20),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const filters = [
      (Icons.location_on_outlined, 'Cerca de mí'),
      (Icons.attach_money, 'Mejor Pago'),
      (Icons.straighten_outlined, 'Rutas Cortas'),
    ];

    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (icon, label) = filters[i];
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? _gold : _surfaceHi,
                border: Border.all(
                    color: isSelected
                        ? _gold
                        : _outline.withOpacity(0.6)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon,
                    size: 17,
                    color: isSelected
                        ? const Color(0xFF3C2F00)
                        : _onSurfaceVar),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF3C2F00)
                            : _onSurfaceVar,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ── Load card ─────────────────────────────────────────────────────────────────

class _LoadCard extends StatelessWidget {
  final Load load;
  final VoidCallback onDetails;

  const _LoadCard({required this.load, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: const BorderSide(color: _gold, width: 4),
              top: BorderSide(color: _outline.withOpacity(0.2)),
              right: BorderSide(color: _outline.withOpacity(0.2)),
              bottom: BorderSide(color: _outline.withOpacity(0.2)),
            ),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black38,
                  blurRadius: 20,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Row 1: route + rate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(children: [
                      Flexible(
                        child: Text(load.origin,
                            style: const TextStyle(
                                color: _onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 17),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.trending_flat,
                            color: _gold, size: 20),
                      ),
                      Flexible(
                        child: Text(load.destination,
                            style: const TextStyle(
                                color: _onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 17),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _usd.format(load.rate),
                    style: const TextStyle(
                        color: _gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        letterSpacing: -0.5),
                  ),
                ],
              ),

              // Row 2: specs
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: _outline.withOpacity(0.3)),
                    ),
                  ),
                  child: Row(children: [
                    Expanded(
                        child: _SpecCol(
                            Icons.local_shipping_outlined,
                            'Tipo',
                            load.equipmentType)),
                    Expanded(
                        child: _SpecCol(
                            Icons.monitor_weight_outlined,
                            'Peso',
                            load.weightFormatted)),
                    Expanded(
                        child: _SpecCol(
                            Icons.route_outlined,
                            'Distancia',
                            load.distanceFormatted)),
                  ]),
                ),
              ),

              // Row 3: broker + button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (load.brokerName != null)
                    Flexible(
                      child: Text(load.brokerName!,
                          style: TextStyle(
                              color: _onSurfaceVar.withOpacity(0.6),
                              fontSize: 11,
                              letterSpacing: 0.3),
                          overflow: TextOverflow.ellipsis),
                    ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: onDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _gold,
                      side: const BorderSide(color: _gold),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 10),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    child: const Text('Ver Detalles'),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SpecCol extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SpecCol(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 14, color: _onSurfaceVar),
        const SizedBox(width: 4),
        Text(label.toUpperCase(),
            style: TextStyle(
                color: _onSurfaceVar.withOpacity(0.7),
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(color: _onSurface, fontSize: 13)),
    ]);
  }
}

// ── Load detail bottom sheet ───────────────────────────────────────────────────

class _LoadDetailSheet extends StatelessWidget {
  final Load load;
  const _LoadDetailSheet({required this.load});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _outline.withOpacity(0.4)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Route header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_outlined,
                    color: _gold, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${load.origin}  →  ${load.destination}',
                      style: const TextStyle(
                          color: _onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(load.brokerName ?? 'Broker no especificado',
                      style: TextStyle(
                          color: _onSurfaceVar.withOpacity(0.6),
                          fontSize: 12)),
                ]),
              ),
            ]),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFF4D4635), height: 1),
            const SizedBox(height: 20),

            // Details grid
            _DetailRow(Icons.attach_money, 'Pago Bruto',
                _usd.format(load.rate)),
            if (load.tollCosts > 0)
              _DetailRow(Icons.toll_outlined, 'Peajes estimados',
                  _usd.format(load.tollCosts)),
            if (load.fuelEstimate > 0)
              _DetailRow(Icons.local_gas_station_outlined, 'Combustible estimado',
                  _usd.format(load.fuelEstimate)),
            if (load.tollCosts > 0 || load.fuelEstimate > 0)
              _DetailRow(Icons.account_balance_wallet_outlined, 'Pago Neto',
                  _usd.format(load.netRate),
                  valueColor: _green),
            _DetailRow(Icons.local_shipping_outlined, 'Equipo requerido',
                load.equipmentType),
            _DetailRow(Icons.monitor_weight_outlined, 'Peso',
                load.weightFormatted),
            _DetailRow(Icons.route_outlined, 'Distancia',
                load.distanceFormatted),
            if (load.pickupWindow != null)
              _DetailRow(Icons.schedule_outlined, 'Pickup',
                  _fmtTime(load.pickupWindow!)),

            const SizedBox(height: 20),

            // Accept button
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFB800), _gold, _goldDark]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: _gold.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Carga "${load.origin} → ${load.destination}" aceptada. '
                          'Coordinador de carga te contactará pronto.'),
                      backgroundColor: Colors.green.shade700,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_circle_outline,
                    color: Color(0xFF3C2F00), size: 20),
                label: const Text('ACEPTAR CARGA',
                    style: TextStyle(
                        color: Color(0xFF3C2F00),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        fontSize: 13)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  String _fmtTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  const _DetailRow(this.icon, this.label, this.value,
      {this.valueColor = _onSurface});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Icon(icon, size: 18, color: _onSurfaceVar.withOpacity(0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  color: _onSurfaceVar.withOpacity(0.7), fontSize: 13)),
        ),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ]),
    );
  }
}

// ── Promo card ────────────────────────────────────────────────────────────────

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outline.withOpacity(0.2)),
      ),
      child: Stack(children: [
        Positioned(
          right: -20,
          bottom: -20,
          child: Icon(Icons.verified_user,
              size: 130,
              color: _gold.withOpacity(0.07)),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Seguro Premium Élite',
              style: TextStyle(
                  color: _gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Protección total para operadores\nde alta gama en cada ruta.',
            style: TextStyle(
                color: _onSurfaceVar.withOpacity(0.7), fontSize: 13),
          ),
        ]),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.local_shipping_outlined,
            size: 64, color: _gold.withOpacity(0.3)),
        const SizedBox(height: 16),
        const Text('No hay cargas disponibles',
            style: TextStyle(color: _onSurface, fontSize: 18)),
        const SizedBox(height: 8),
        Text('Intenta cambiar el filtro o actualizar',
            style: TextStyle(
                color: _onSurfaceVar.withOpacity(0.5), fontSize: 13)),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh, color: _gold),
          label: const Text('Actualizar',
              style: TextStyle(color: _gold, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _gold),
              shape: const StadiumBorder()),
        ),
      ]),
    );
  }
}

// ── Map FAB ───────────────────────────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vista de mapa — disponible en Fase 4'),
          duration: Duration(seconds: 2),
        ),
      ),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _gold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: _gold.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: const Icon(Icons.map, color: Color(0xFF3C2F00), size: 28),
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.dashboard_outlined, 'Dashboard'),
    (Icons.local_shipping_outlined, 'Loads'),
    (Icons.chat_bubble_outline, 'Messages'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF231F17).withOpacity(0.9),
        border: Border(top: BorderSide(color: _outline.withOpacity(0.1))),
        boxShadow: const [
          BoxShadow(
              color: Colors.black45, blurRadius: 24, offset: Offset(0, -4)),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final (icon, label) = _items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _gold.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Icon(icon,
                          color: isActive
                              ? _gold
                              : _onSurfaceVar.withOpacity(0.5),
                          size: 22),
                      const SizedBox(height: 2),
                      Text(label.toUpperCase(),
                          style: TextStyle(
                              color: isActive
                                  ? _gold
                                  : _onSurfaceVar.withOpacity(0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8)),
                    ]),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
