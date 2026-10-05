import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tokens do design system "Kinetic Volt" (telas app/kinetic_volt/DESIGN.md)
const bg = Color(0xFF0F0F12);
const surface1 = Color(0xFF18181E);
const surface2 = Color(0xFF22222A);
const surface3 = Color(0xFF343440);
const lime = Color(0xFFC6F432);
const textHigh = Colors.white;
const textMed = Color(0xFFE2E2EA);
const textLow = Color(0xFF9E9EA8);
const border = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

final limeGlow = [BoxShadow(color: lime.withValues(alpha: 0.28), blurRadius: 24)];

TextStyle grotesk(double size, {FontWeight weight = FontWeight.w700, Color color = textHigh, double spacing = 0}) =>
    GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);

TextStyle caps(Color color) => grotesk(11, color: color, spacing: 1);

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: bg,
    colorScheme: base.colorScheme.copyWith(primary: lime, onPrimary: bg, surface: bg),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: textMed, displayColor: textHigh),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface1,
      hintStyle: const TextStyle(color: textLow),
      prefixIconColor: textLow,
      suffixIconColor: textLow,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: lime)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent)),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, required this.onPressed, this.icon = Icons.arrow_forward});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: onPressed == null ? null : limeGlow),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: bg,
            disabledBackgroundColor: surface2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: grotesk(18, weight: FontWeight.w600),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 22)],
          ]),
        ),
      );
}

class Logo extends StatelessWidget {
  const Logo({super.key, this.showMark = true});
  final bool showMark; // false = só o nome (a tela inicial usa o botão de menu no lugar)

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        if (showMark) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
            child: const Icon(Icons.bolt, color: lime, size: 22),
          ),
          const SizedBox(width: 10),
        ],
        Text.rich(TextSpan(style: grotesk(22), children: const [
          TextSpan(text: 'Diário '),
          TextSpan(text: 'Fit', style: TextStyle(color: lime)),
        ])),
      ]);
}

/// Pílula com bolinha verde: "PASSO 1 DE 2", "TREINO FUNCIONAL INTELIGENTE"...
class DotPill extends StatelessWidget {
  const DotPill(this.text, {super.key, this.color = lime});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(radius: 4, backgroundColor: lime),
          const SizedBox(width: 8),
          Flexible(child: Text(text.toUpperCase(), style: caps(color))),
        ]),
      );
}

class SquareIconButton extends StatelessWidget {
  const SquareIconButton(this.icon, {super.key, required this.onTap, this.tooltip, this.size = 52});
  final IconData icon;
  final VoidCallback? onTap; // null = desativado
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          fixedSize: Size.square(size),
          backgroundColor: surface2,
          disabledBackgroundColor: surface1,
          foregroundColor: textHigh,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text, style: grotesk(15, weight: FontWeight.w600)),
      );
}

class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        obscureText: _hidden,
        style: const TextStyle(color: textHigh),
        validator: (v) => (v ?? '').length < 8 ? 'Mínimo 8 caracteres' : null,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            tooltip: _hidden ? 'Mostrar senha' : 'Ocultar senha',
            icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            onPressed: () => setState(() => _hidden = !_hidden),
          ),
        ),
      );
}

String? validateEmail(String? v) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '') ? null : 'E-mail inválido';

/// Imagem de rede com fundo neutro enquanto carrega ou se falhar.
class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key});
  final String url;

  @override
  Widget build(BuildContext context) => Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: surface2),
        frameBuilder: (_, child, frame, sync) => frame == null && !sync ? const ColoredBox(color: surface2) : child,
      );
}
