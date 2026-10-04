import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';
import 'player_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key, required this.categories});
  final List<Category> categories;

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String? _level; // null = Todos

  @override
  Widget build(BuildContext context) {
    final ids = widget.categories.map((c) => c.id).toSet();
    final list = exercises.where((e) => ids.contains(e.categoryId) && (_level == null || e.level == _level)).toList();
    final totalMin = totalMinutes(list);
    final single = widget.categories.length == 1;

    void play(int index) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
              title: widget.categories.map((c) => c.name).join(' + '),
              items: [for (final e in list) PlanItem(e, sets: 1)],
              index: index,
            )));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
          Row(children: [
            SquareIconButton(Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((single ? widget.categories.first.tag : 'Treino combinado').toUpperCase(), style: caps(lime)),
                Text(
                  single ? widget.categories.first.name : widget.categories.map((c) => c.name).join(' + '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: grotesk(26, spacing: -0.5),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
            child: Row(children: [
              const Icon(Icons.timer_outlined, color: lime, size: 20),
              const SizedBox(width: 8),
              Text('${list.length} exercícios', style: grotesk(15, weight: FontWeight.w600)),
              Text('  •  $totalMin min total', style: grotesk(15, weight: FontWeight.w500, color: textLow)),
            ]),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final l in [null, ...levels])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l ?? 'Todos'),
                    selected: _level == l,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _level = l),
                    labelStyle: grotesk(15, weight: FontWeight.w600, color: _level == l ? bg : textMed),
                    backgroundColor: surface1,
                    selectedColor: lime,
                    side: const BorderSide(color: border),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Text('Nenhum exercício neste nível.', textAlign: TextAlign.center, style: TextStyle(color: textLow)),
            ),
          for (var i = 0; i < list.length; i++) ExerciseCard(list[i], onTap: () => play(i)),
        ]),
      ),
      bottomNavigationBar: list.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.paddingOf(context).bottom),
              child: PrimaryButton('Iniciar circuito completo', icon: Icons.play_circle_outline, onPressed: () => play(0)),
            ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  const ExerciseCard(this.exercise, {super.key, required this.onTap, this.trailing, this.highlighted = false, this.info, this.infoIcon = Icons.repeat});
  final Exercise exercise;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool highlighted;
  final String? info; // prescrição ("3 x 12"); padrão = duração do exercício
  final IconData infoIcon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: surface1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: highlighted ? lime : border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 96,
                    height: 80,
                    child: Stack(fit: StackFit.expand, children: [
                      NetImage(exercise.image),
                      const Center(
                        child: CircleAvatar(radius: 16, backgroundColor: Colors.black54, child: Icon(Icons.play_arrow, color: lime)),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Wrap: em telas estreitas a duração desce para a linha de baixo em vez de estourar
                    Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      LevelBadge(exercise.level),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(info == null ? Icons.schedule : infoIcon, size: 14, color: info == null ? textLow : lime),
                        const SizedBox(width: 3),
                        Text(
                          info ?? '${exercise.durationSec} seg',
                          style: info == null
                              ? const TextStyle(color: textLow, fontSize: 13)
                              : grotesk(13, weight: FontWeight.w600, color: lime),
                        ),
                      ]),
                    ]),
                    const SizedBox(height: 6),
                    Text(exercise.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: grotesk(17)),
                    const SizedBox(height: 2),
                    Text(exercise.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: textLow, fontSize: 13)),
                  ]),
                ),
                ?trailing,
              ]),
            ),
          ),
        ),
      );
}

class LevelBadge extends StatelessWidget {
  const LevelBadge(this.level, {super.key});
  final String level;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(8)),
        child: Text(level, style: grotesk(12, weight: FontWeight.w600, color: level == 'Iniciante' ? textMed : lime)),
      );
}
