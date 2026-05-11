import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart';

const _gold = Color(0xFFD4AF37);
const _goldDark = Color(0xFFB8860B);
const _surface = Color(0xFF1A1A1A);
const _bg1 = Color(0xFF001A3D);
const _bg2 = Color(0xFF0A0A0A);
const _inputBg = Color(0xFF050505);
const _outline = Color(0xFF4D4635);
const _errorRed = Color(0xFFFF5252);

const _equipmentOptions = [
  _EquipmentOption('semi_truck', 'Semi-Truck',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC1QY-vCQl95xnkLqq0a4sVP9qw6i6AEQamYH9Y-q8eEbWIIKGDg0nO7aNhU-MUOPqR-kIU6YKsrJB-DmWKtXt93tZV25sFOHglNNafagS9BfciO9DQHgFFyjzDrRlFI2z5KHOJ2KvwVpQhuhe3tqPezRYiz2XzQGQzXQrcx2vhx1H_8m85m4BDVG8_0bB8LNrRiDDsPjz3iGqUbhbCUnuPv_9nHqa8YKmVNCXIV04kE9Q15b2LEN2vJf35EL5Q-cxdcAKnvMqa6A'),
  _EquipmentOption('cargo_van', 'Cargo Van',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAtSFJ_tQ9o18Z8YAJWX_CX1F7345eJJRE0K-WzEWRspLiGQ8z_rfbaCo89hVQO1Q6o3ZeABsQtvxwhivyS2x3mt21302DHqX17dogsI23kDkTQsUfAlPIFZ2RrAEfNf4VV8tBqKfIPvL7FiiLEQLw-pY5rszlRaWdS65R6tFZ4sPK74Js2pWCKr3DFG9YbOD5Oe5MmTdP9DMkzds6yn_wtRs79X3i_paigxhASS-2E3uRcbEoLUfdCN8D3QOfwQMQJ7mhA5XLtAg'),
  _EquipmentOption('box_truck', 'Box Truck',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDu_ZW3HgBxMPtZV9h75Yt3TWKY5C4Crce5ZcjsFl7zq9pfycvjdKBFIAi3lzh9k555YW4Zf10Ok3PNaI5O7aRpRy_03O6l7iavoV69mgKsySCZPYqkmN-cG-5Jje-k-ac-lnKbFqOtaxsysyvjbOU6dXOG7Mf_Y_ofsH-6DSIl7hmGUd-Omw873AqOJIm2Z2mMsABS0zx-svJgyNmQwijxE4zCl44U4Q7gXZf6oYd8zvNmFX3MkbgGSgscM5aPVlqd4XXH94bCmA'),
  _EquipmentOption('flatbed', 'Flatbed',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC23dfCpl1NzrM67BpLuxX-eMu5hGRs_oHc5lIZk9g-faArOBZJWYnLLH2XpnN_Gtjy83ZZ1ITcQMAY9ZeDx72yRaEAESJ73d8QOxQUaP0849F9j7mIeWAANBCd21RqEquTt_Ra1ay9ttTDSwWplH0JvNb96ovurgRJ19vIeAaNbGEIznkUG3YHz-ssh6yM_yJsFr7crw6BqQpCNbvFIKCdGOocZmWTBihIIelM5q1ZfMldSiChle5AcfTiV3BVpg2Y7BBX7E8c3g'),
  _EquipmentOption('step_deck', 'Step Deck',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA8QxTuvkECJPFKFrh6jha9PeJWZ5RNCN5SgEtQUz7OwMDeywWmbANRJWuJNKfCb0d9H8n4vb-x0_M-bRsG6SgJH0RqA0-t_fJMoJIrJrYyJlshebtTwxj09JCdPOrtEsKPTRzpe83xcxRS1KkfqLSRfAmsuvSzDRXxBYCq5Zy1d0rbRBd7KetRuEJlbXaCXud-jgRZkAq2LGEa19zFpK6n_2ESDdCFkGA8bxYBsuy4ES2qVR1uhRrYNlDYbVDNrPGPgGqdY5cg0Q'),
];

class _EquipmentOption {
  final String value;
  final String label;
  final String imageUrl;
  const _EquipmentOption(this.value, this.label, this.imageUrl);
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  String? _selectedEquipment;
  bool _termsAccepted = false;
  bool _loading = false;
  bool _submitted = false;
  String? _emailError;
  String? _generalError;
  String? _debugLink;

  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _generalError = null;
    });

    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      setState(() => _generalError = 'Debes aceptar los Términos y Condiciones.');
      return;
    }

    setState(() => _loading = true);

    final result = await AuthService.register(RegisterRequest(
      nombreCompleto: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefono: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      zipCode: _zipCtrl.text.trim().isEmpty ? null : _zipCtrl.text.trim(),
      equipmentType: _selectedEquipment,
      termsAccepted: true,
    ));

    setState(() => _loading = false);

    if (result.success) {
      setState(() {
        _submitted = true;
        _debugLink = result.debugLink;
      });
    } else {
      final msg = result.message;
      if (msg.toLowerCase().contains('email') ||
          msg.toLowerCase().contains('registrado') ||
          msg.toLowerCase().contains('activo')) {
        setState(() => _emailError = msg);
      } else {
        setState(() => _generalError = msg);
      }
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _loading = true;
      _generalError = null;
    });
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() => _loading = false);
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        setState(() {
          _loading = false;
          _generalError = 'No se pudo obtener el token de Google.';
        });
        return;
      }
      final result = await AuthService.googleLogin(idToken);
      setState(() => _loading = false);
      if (result.success) {
        setState(() => _submitted = true);
      } else {
        setState(() => _generalError = result.message);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _generalError = 'Error con Google Sign-In: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg2,
      body: Stack(
        children: [
          _GradientBackground(),
          if (_submitted) _SuccessView(debugLink: _debugLink) else _FormView(
            formKey: _formKey,
            nameCtrl: _nameCtrl,
            emailCtrl: _emailCtrl,
            phoneCtrl: _phoneCtrl,
            zipCtrl: _zipCtrl,
            selectedEquipment: _selectedEquipment,
            termsAccepted: _termsAccepted,
            loading: _loading,
            emailError: _emailError,
            generalError: _generalError,
            onEquipmentSelected: (v) => setState(() => _selectedEquipment = v),
            onTermsChanged: (v) => setState(() => _termsAccepted = v ?? false),
            onSubmit: _submit,
            onGoogleLogin: _googleLogin,
          ),
        ],
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.7, -1),
          radius: 1.5,
          colors: [_bg1, _bg2],
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl, zipCtrl;
  final String? selectedEquipment;
  final bool termsAccepted;
  final bool loading;
  final String? emailError;
  final String? generalError;
  final ValueChanged<String?> onEquipmentSelected;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleLogin;

  const _FormView({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.zipCtrl,
    required this.selectedEquipment,
    required this.termsAccepted,
    required this.loading,
    required this.emailError,
    required this.generalError,
    required this.onEquipmentSelected,
    required this.onTermsChanged,
    required this.onSubmit,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: _GlassCard(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(),
                        const SizedBox(height: 32),
                        _GoogleButton(onTap: onGoogleLogin, loading: loading),
                        const SizedBox(height: 24),
                        _Divider(),
                        const SizedBox(height: 24),
                        _FieldGrid(
                          nameCtrl: nameCtrl,
                          emailCtrl: emailCtrl,
                          phoneCtrl: phoneCtrl,
                          zipCtrl: zipCtrl,
                          emailError: emailError,
                        ),
                        const SizedBox(height: 24),
                        _EquipmentSelector(
                          selected: selectedEquipment,
                          onSelected: onEquipmentSelected,
                        ),
                        const SizedBox(height: 24),
                        _TermsRow(
                          accepted: termsAccepted,
                          onChanged: onTermsChanged,
                        ),
                        if (generalError != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.error_outline, color: _errorRed, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(generalError!,
                                    style: const TextStyle(
                                        color: _errorRed, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 28),
                        _SubmitButton(loading: loading, onPressed: onSubmit),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Recibirás un enlace mágico por correo para activar tu cuenta.',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _Footer(),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF050505).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: _gold.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_back, color: _gold),
              const SizedBox(width: 16),
              const Text('LOGISTX ELITE',
                  style: TextStyle(
                      color: _gold,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontSize: 16)),
            ],
          ),
          Row(
            children: [
              Text('Support',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2)),
              const SizedBox(width: 16),
              const Icon(Icons.help_outline, color: _gold),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.85),
            border: const Border(
              left: BorderSide(color: _gold, width: 4),
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NEXO ELITE GLOBAL',
            style: TextStyle(
                color: Color(0xFFE9C349),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 5)),
        const SizedBox(height: 8),
        const Text('Registro de Operador',
            style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('Únete a la red logística más exclusiva del mundo.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 15)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool loading;
  const _GoogleButton({required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
              width: 22,
              height: 22,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.login, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Continuar con Google',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('O REGÍSTRATE CON CORREO',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2)),
        ),
        Expanded(
            child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
      ],
    );
  }
}

class _FieldGrid extends StatelessWidget {
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl, zipCtrl;
  final String? emailError;

  const _FieldGrid({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.zipCtrl,
    required this.emailError,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 560;
    final fields = [
      _NexoField(
          label: 'NOMBRE Y APELLIDO',
          ctrl: nameCtrl,
          hint: 'Nombre y Apellido',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo requerido' : null),
      _NexoField(
          label: 'CORREO ELECTRÓNICO',
          ctrl: emailCtrl,
          hint: 'correo@ejemplo.com',
          keyboardType: TextInputType.emailAddress,
          externalError: emailError,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Campo requerido';
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
              return 'Correo inválido';
            }
            return null;
          }),
      _NexoField(
          label: 'TELÉFONO',
          ctrl: phoneCtrl,
          hint: '+1 123 456 7890',
          keyboardType: TextInputType.phone),
      _NexoField(
          label: 'CÓDIGO POSTAL',
          ctrl: zipCtrl,
          hint: 'Ej. 19801',
          suffixIcon: const Icon(Icons.location_on_outlined,
              color: Colors.white24, size: 18)),
    ];

    if (isWide) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: fields[0]),
              const SizedBox(width: 16),
              Expanded(child: fields[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: fields[2]),
              const SizedBox(width: 16),
              Expanded(child: fields[3]),
            ],
          ),
        ],
      );
    }

    return Column(
      children: fields
          .expand((f) => [f, const SizedBox(height: 16)])
          .toList()
        ..removeLast(),
    );
  }
}

class _NexoField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? externalError;
  final FormFieldValidator<String>? validator;

  const _NexoField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.keyboardType,
    this.suffixIcon,
    this.externalError,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = externalError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFFE9C349),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _inputBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: hasError ? _errorRed : _outline, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: hasError ? _errorRed : _outline, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: hasError ? _errorRed : _goldDark, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _errorRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _errorRed, width: 1.5),
            ),
            errorStyle: const TextStyle(color: _errorRed, fontSize: 10),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: _errorRed, size: 12),
                const SizedBox(width: 4),
                Text(externalError!,
                    style: const TextStyle(color: _errorRed, fontSize: 10)),
              ],
            ),
          ),
      ],
    );
  }
}

class _EquipmentSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _EquipmentSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TIPO DE UNIDAD',
            style: TextStyle(
                color: Color(0xFFE9C349),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5)),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final itemW = (constraints.maxWidth - 4 * 8) / 5;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _equipmentOptions.map((opt) {
              final isSelected = selected == opt.value;
              return GestureDetector(
                onTap: () => onSelected(opt.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: itemW.clamp(60.0, 130.0),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1B13),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? _gold
                          : Colors.white.withOpacity(0.05),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          opt.imageUrl,
                          height: 56,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          opacity: AlwaysStoppedAnimation(isSelected ? 1 : 0.45),
                          errorBuilder: (_, __, ___) => Container(
                            height: 56,
                            color: Colors.white10,
                            child: const Icon(Icons.local_shipping,
                                color: Colors.white24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(opt.label,
                          style: TextStyle(
                              color: isSelected
                                  ? _gold
                                  : Colors.white.withOpacity(0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool?> onChanged;

  const _TermsRow({required this.accepted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: accepted,
            onChanged: onChanged,
            activeColor: _gold,
            checkColor: Colors.black,
            side: const BorderSide(color: _outline),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                    color: Colors.white.withOpacity(0.55), fontSize: 12),
                children: [
                  const TextSpan(text: 'Acepto los '),
                  TextSpan(
                    text: 'Términos y Condiciones',
                    style: const TextStyle(
                        color: _goldDark,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' y la '),
                  TextSpan(
                    text: 'Política de Privacidad',
                    style: const TextStyle(
                        color: _goldDark,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' de Nexo Elite Global.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _SubmitButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_gold, _goldDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
                color: _gold.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: const StadiumBorder(),
          ),
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('SOLICITAR ACCESO',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 3)),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String? debugLink;
  const _SuccessView({this.debugLink});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _gold, width: 2),
                  ),
                  child: const Icon(Icons.mark_email_read_outlined,
                      color: _gold, size: 36),
                ),
                const SizedBox(height: 24),
                const Text('¡Registro Exitoso!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text(
                  'Revisa tu correo electrónico.\nHaz clic en el enlace para activar tu cuenta.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                if (debugLink != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _gold.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ENLACE DE ACTIVACIÓN (SMTP no configurado):',
                            style: TextStyle(
                                color: _gold, fontSize: 9, letterSpacing: 1)),
                        const SizedBox(height: 6),
                        SelectableText(debugLink!,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LOGISTX GLOBAL',
                  style: TextStyle(
                      color: _gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3)),
              const SizedBox(height: 4),
              Text('© 2026 LOGISTX GLOBAL. PRECISION LOGISTICS.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 9,
                      letterSpacing: 1)),
            ],
          ),
          Wrap(
            spacing: 24,
            children: ['Privacy Policy', 'Terms', 'Compliance', 'Support']
                .map((t) => Text(t,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 9,
                        letterSpacing: 1.5)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
