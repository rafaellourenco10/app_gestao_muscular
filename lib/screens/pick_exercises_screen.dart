import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';
import 'exercises_screen.dart' show ExerciseCard;

/// Lista todos os exercícios agrupados por grupo muscular.
/// Devolve (via Navigator.pop) a lista escolhida, na ordem em que foi marcada.
class PickExercisesScreen extends StatefulWidget {
  const PickExercisesScreen({super.key, required this.day, required this.initial});
  final String day;
  final List<Exercise> initial;

  @override
  State<PickExercisesScreen> createState() => _PickExercisesScreenState();
}

class _PickExercisesScreenState extends State<PickExercisesScreen> {
  late final _picked = [...widget.initial];
  String _query = '';
  String? _equipment; // null = todos

  bool _matches(Exercise e) =>
      (_equipment == null || e.equipment == _equipment) && (_query.isEmpty || fold('${e.title} ${e.subtitle}').contains(fold(_query)));

  void _toggle(Exercise e) => setState(() => _picked.contains(e) ? _picked.remove(e) : _picked.add(e));

  @override
  Widget build(BuildContext context) {
    final groups = [
      for (final c in categories) (c, exercises.where((e) => e.categoryId == c.id && _matches(e)).toList()),
    ].where((g) => g.$2.isNotEmpty);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    SquareIconButton(Icons.close, onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MONTAR TREINO • ${widget.day.toUpperCase()}', style: caps(lime)),
                          Text('Escolha os exercícios', style: grotesk(24, spacing: -0.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.trim()),
                  style: const TextStyle(color: textHigh),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Buscar exercício',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    for (final eq in [null, ...equipments])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(eq ?? 'Todos'),
                          selected: _equipment == eq,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _equipment = eq),
                          labelStyle: grotesk(14, weight: FontWeight.w600, color: _equipment == eq ? bg : textMed),
                          backgroundColor: surface1,
                          selectedColor: lime,
                          side: const BorderSide(color: border),
                          shape: const StadiumBorder(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (groups.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Text(
                    'Nenhum exercício encontrado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textLow),
                  ),
                ),
              ),
            for (final (c, list) in groups) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.name, style: grotesk(20, weight: FontWeight.w600)),
                      Text(c.tag.toUpperCase(), style: caps(textLow)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.list(
                  children: [
                    for (final e in list)
                      ExerciseCard(
                        e,
                        highlighted: _picked.contains(e),
                        onTap: () => _toggle(e),
                        trailing: Checkbox(
                          value: _picked.contains(e),
                          onChanged: (_) => _toggle(e),
                          activeColor: lime,
                          checkColor: bg,
                          side: const BorderSide(color: surface3, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(
          color: surface1,
          border: Border(top: BorderSide(color: border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_picked.length} EXERCÍCIO${_picked.length == 1 ? '' : 'S'} • ${totalMinutes(_picked)} MIN',
              style: caps(_picked.isEmpty ? textLow : textMed),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                'Salvar treino de ${widget.day.toLowerCase()}',
                icon: Icons.check,
                onPressed: () => Navigator.pop(context, _picked),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
