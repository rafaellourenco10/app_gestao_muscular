import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _edit() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface1,
      showDragHandle: true,
      builder: (_) => const _EditSheet(),
    );
    setState(() {});
  }

  Future<void> _addWeight() async {
    final value = await showDialog<double>(context: context, builder: (_) => const _WeightDialog());
    if (value == null) return;
    setState(() => addWeight(value));
  }

  @override
  Widget build(BuildContext context) {
    final b = bmi();
    final streak = currentStreak();

    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Row(children: [
            SquareIconButton(Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(child: Text('Meu perfil', style: grotesk(24, spacing: -0.5))),
            SquareIconButton(Icons.edit_outlined, size: 44, tooltip: 'Editar perfil', onTap: _edit),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            const CircleAvatar(radius: 36, backgroundColor: lime, child: CircleAvatar(radius: 33, backgroundImage: NetworkImage(imgAvatar))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(profile.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: grotesk(24)),
                if (profile.email.isNotEmpty) Text(profile.email, style: const TextStyle(color: textLow)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [_Chip(profile.level), _Chip(profile.goal)]),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            _Stat('${history.length}', 'TREINOS'),
            const SizedBox(width: 10),
            _Stat('🔥 $streak', streak == 1 ? 'DIA SEGUIDO' : 'DIAS SEGUIDOS'),
            const SizedBox(width: 10),
            _Stat(profile.heightCm == null ? '–' : '${profile.heightCm} cm', 'ALTURA'),
          ]),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(child: Text('Progresso de peso', style: grotesk(22, weight: FontWeight.w600))),
            TextButton.icon(
              onPressed: _addWeight,
              icon: const Icon(Icons.add, color: lime),
              label: Text('Registrar', style: grotesk(15, color: lime)),
            ),
          ]),
          const SizedBox(height: 8),
          if (weights.isEmpty)
            _Card(
              child: Column(children: [
                const Icon(Icons.monitor_weight_outlined, size: 48, color: surface3),
                const SizedBox(height: 10),
                Text('Registre seu peso inicial', style: grotesk(18)),
                const SizedBox(height: 4),
                const Text(
                  'Atualize de tempos em tempos para acompanhar sua evolução.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textLow),
                ),
                const SizedBox(height: 16),
                PrimaryButton('Registrar peso', icon: Icons.add, onPressed: _addWeight),
              ]),
            )
          else ...[
            _Card(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${kg(weights.last.kg)} kg', style: grotesk(40, spacing: -1)),
                  const SizedBox(width: 10),
                  if (weights.length > 1) _Delta(weights.last.kg - weights.first.kg),
                ]),
                const SizedBox(height: 4),
                Text(
                  weights.length == 1
                      ? 'Peso inicial registrado. Atualize nas próximas semanas.'
                      : 'Início: ${kg(weights.first.kg)} kg em ${_date(weights.first.date)}',
                  style: const TextStyle(color: textLow),
                ),
                if (weights.length > 1) ...[
                  const SizedBox(height: 20),
                  SizedBox(height: 140, width: double.infinity, child: CustomPaint(painter: _WeightChart(weights))),
                ],
              ]),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: _Card(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('IMC', style: caps(textLow)),
                    const SizedBox(height: 6),
                    Text(b == null ? '–' : b.toStringAsFixed(1).replaceAll('.', ','), style: grotesk(26)),
                    Text(
                      b == null ? 'Informe a altura' : bmiLabel(b),
                      style: TextStyle(color: b == null ? textLow : lime, fontSize: 13),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Card(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('META', style: caps(textLow)),
                    const SizedBox(height: 6),
                    Text(profile.goalKg == null ? '–' : '${kg(profile.goalKg!)} kg', style: grotesk(26)),
                    if (goalProgress() case final p?) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(value: p, minHeight: 6, backgroundColor: surface2, color: lime),
                      ),
                      const SizedBox(height: 4),
                      Text('${(p * 100).round()}% do caminho', style: const TextStyle(color: lime, fontSize: 13)),
                    ] else
                      const Text('Defina no editar', style: TextStyle(color: textLow, fontSize: 13)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            Text('Registros', style: grotesk(18, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Deslize para apagar', style: TextStyle(color: textLow, fontSize: 13)),
            const SizedBox(height: 10),
            for (final (i, w) in weights.indexed.toList().reversed)
              Dismissible(
                key: ObjectKey(w),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => setState(() => weights.remove(w)),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.delete_outline, color: textHigh),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Text(_date(w.date), style: const TextStyle(color: textMed)),
                    if (i == 0) ...[const SizedBox(width: 8), _Chip('Inicial')],
                    const Spacer(),
                    if (i > 0) ...[_Delta(w.kg - weights[i - 1].kg, small: true), const SizedBox(width: 12)],
                    Text('${kg(w.kg)} kg', style: grotesk(17)),
                  ]),
                ),
              ),
          ],
        ]),
      ),
    );
  }
}

String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: child,
      );
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: grotesk(12, weight: FontWeight.w600, color: textMed)),
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value, label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
          child: Column(children: [
            FittedBox(child: Text(value, style: grotesk(22))),
            const SizedBox(height: 4),
            FittedBox(child: Text(label, style: caps(textLow))),
          ]),
        ),
      );
}

/// Variação de peso: "−3,2 kg" / "+1 kg". Cor neutra: perder ou ganhar depende do objetivo.
class _Delta extends StatelessWidget {
  const _Delta(this.value, {this.small = false});
  final double value;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final text = value == 0 ? '0 kg' : '${value > 0 ? '+' : '−'}${kg(value.abs())} kg';
    return Padding(
      padding: EdgeInsets.only(bottom: small ? 0 : 8),
      child: Text(text, style: grotesk(small ? 13 : 16, weight: FontWeight.w600, color: value == 0 ? textLow : lime)),
    );
  }
}

/// Gráfico de linha simples da evolução do peso.
class _WeightChart extends CustomPainter {
  _WeightChart(this.data);
  final List<WeightEntry> data;

  @override
  void paint(Canvas canvas, Size size) {
    final values = data.map((w) => w.kg);
    final lo = values.reduce((a, b) => a < b ? a : b) - 1, hi = values.reduce((a, b) => a > b ? a : b) + 1;
    Offset at(int i) => Offset(
          size.width * i / (data.length - 1),
          size.height * (1 - (data[i].kg - lo) / (hi - lo)),
        );

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < data.length; i++) {
      line.lineTo(at(i).dx, at(i).dy);
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lime.withValues(alpha: 0.25), lime.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = lime
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(at(i), 4, Paint()..color = bg);
      canvas.drawCircle(
        at(i),
        4,
        Paint()
          ..color = lime
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_WeightChart old) => true;
}

/// Digitar o peso (aceita vírgula).
class _WeightDialog extends StatefulWidget {
  const _WeightDialog();

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  final _form = GlobalKey<FormState>();
  final _ctrl = TextEditingController(text: weights.isEmpty ? '' : kg(weights.last.kg));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState!.validate()) Navigator.pop(context, parseDecimal(_ctrl.text));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: surface1,
        title: Text(weights.isEmpty ? 'Peso inicial' : 'Peso de hoje', style: grotesk(20)),
        content: Form(
          key: _form,
          child: TextFormField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: grotesk(24),
            decoration: const InputDecoration(suffixText: 'kg', hintText: '72,5'),
            validator: (v) {
              final n = parseDecimal(v ?? '');
              return n == null || n < 30 || n > 300 ? 'Informe um peso entre 30 e 300 kg' : null;
            },
            onFieldSubmitted: (_) => _save(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: bg),
            child: const Text('Salvar'),
          ),
        ],
      );
}

/// Edição de nome, nível, objetivo, altura e peso meta.
class _EditSheet extends StatefulWidget {
  const _EditSheet();

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: profile.name);
  late final _height = TextEditingController(text: profile.heightCm?.toString() ?? '');
  late final _goalKg = TextEditingController(text: profile.goalKg == null ? '' : kg(profile.goalKg!));
  late String _level = profile.level, _goal = profile.goal;

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _goalKg.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    profile
      ..name = _name.text.trim()
      ..level = _level
      ..goal = _goal
      ..heightCm = int.tryParse(_height.text.trim())
      ..goalKg = parseDecimal(_goalKg.text);
    Navigator.pop(context);
  }

  Widget _choices(List<String> options, String value, ValueChanged<String> onPick) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final o in options)
            ChoiceChip(
              label: Text(o),
              selected: value == o,
              showCheckmark: false,
              onSelected: (_) => setState(() => onPick(o)),
              labelStyle: grotesk(14, weight: FontWeight.w600, color: value == o ? bg : textMed),
              backgroundColor: surface2,
              selectedColor: lime,
              side: const BorderSide(color: border),
              shape: const StadiumBorder(),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) => Padding(
        // sobe junto com o teclado
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Editar perfil', style: grotesk(22)),
                const FieldLabel('Nome'),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: textHigh),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Informe seu nome' : null,
                ),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const FieldLabel('Altura'),
                      TextFormField(
                        controller: _height,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: textHigh),
                        decoration: const InputDecoration(suffixText: 'cm', hintText: '175'),
                        validator: (v) {
                          if ((v ?? '').isEmpty) return null; // opcional
                          final n = int.tryParse(v!);
                          return n == null || n < 100 || n > 250 ? 'Entre 100 e 250' : null;
                        },
                      ),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const FieldLabel('Peso meta'),
                      TextFormField(
                        controller: _goalKg,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        style: const TextStyle(color: textHigh),
                        decoration: const InputDecoration(suffixText: 'kg', hintText: '70'),
                        validator: (v) {
                          if ((v ?? '').isEmpty) return null; // opcional
                          final n = parseDecimal(v!);
                          return n == null || n < 30 || n > 300 ? 'Entre 30 e 300' : null;
                        },
                      ),
                    ]),
                  ),
                ]),
                const FieldLabel('Nível'),
                _choices(levels, _level, (v) => _level = v),
                const FieldLabel('Objetivo'),
                _choices(goals, _goal, (v) => _goal = v),
                const SizedBox(height: 24),
                PrimaryButton('Salvar', icon: Icons.check, onPressed: _save),
              ]),
            ),
          ),
        ),
      );
}
