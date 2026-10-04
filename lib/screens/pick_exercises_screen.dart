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

  void _toggle(Exercise e) => setState(() => _picked.contains(e) ? _picked.remove(e) : _picked.add(e));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(children: [
                  SquareIconButton(Icons.close, onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('MONTAR TREINO • ${widget.day.toUpperCase()}', style: caps(lime)),
                      Text('Escolha os exercícios', style: grotesk(24, spacing: -0.5)),
                    ]),
                  ),
                ]),
              ),
            ),
            for (final c in categories) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(c.name, style: grotesk(20, weight: FontWeight.w600)),
                    Text(c.tag.toUpperCase(), style: caps(textLow)),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.list(children: [
                  for (final e in exercises.where((e) => e.categoryId == c.id))
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
                ]),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ]),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.paddingOf(context).bottom),
          decoration: const BoxDecoration(color: surface1, border: Border(top: BorderSide(color: border))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              '${_picked.length} EXERCÍCIO${_picked.length == 1 ? '' : 'S'} • ${totalMinutes(_picked)} MIN',
              style: caps(_picked.isEmpty ? textLow : textMed),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton('Salvar treino de ${widget.day.toLowerCase()}', icon: Icons.check, onPressed: () => Navigator.pop(context, _picked)),
            ),
          ]),
        ),
      );
}
