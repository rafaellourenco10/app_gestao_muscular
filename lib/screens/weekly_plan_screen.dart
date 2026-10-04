import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';
import 'exercises_screen.dart' show ExerciseCard;
import 'pick_exercises_screen.dart';
import 'player_screen.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  int _day = DateTime.now().weekday - 1; // 0 = segunda

  Future<void> _edit() async {
    final picked = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => PickExercisesScreen(day: weekdays[_day], initial: [for (final i in weeklyPlan[_day]) i.exercise]),
      ),
    );
    if (picked == null) return;
    // mantém séries/reps de quem já estava no treino; novos entram com o padrão
    final old = {for (final i in weeklyPlan[_day]) i.exercise: i};
    setState(() => weeklyPlan[_day] = [for (final e in picked) old[e] ?? PlanItem(e, type: dayType[_day])]);
  }

  void _setType(WorkoutType t) => setState(() {
        dayType[_day] = t;
        for (final i in weeklyPlan[_day]) {
          i.type = t;
        }
      });

  Future<void> _editSets(PlanItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface1,
      showDragHandle: true,
      builder: (_) => _SetsSheet(item),
    );
    setState(() {});
  }

  void _play(int index) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerScreen(title: 'Treino de ${weekdays[_day].toLowerCase()}', items: weeklyPlan[_day], index: index),
        ),
      ).then((_) => setState(() {})); // atualiza o selo de concluído

  @override
  Widget build(BuildContext context) {
    final list = weeklyPlan[_day];
    final today = DateTime.now().weekday - 1;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              SquareIconButton(Icons.arrow_back, onTap: () => Navigator.pop(context)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SEU PLANO', style: caps(lime)),
                  Text('Cronograma semanal', style: grotesk(24, spacing: -0.5)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 7,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _DayPill(
                label: weekdays[i].substring(0, 3).toUpperCase(),
                count: weeklyPlan[i].length,
                selected: i == _day,
                isToday: i == today,
                onTap: () => setState(() => _day = i),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text(weekdays[_day], style: grotesk(22, weight: FontWeight.w600)),
              if (_day == today && doneToday) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: lime, size: 20),
              ],
              const Spacer(),
              if (list.isNotEmpty)
                Text('${list.length} exercícios • ~${planMinutes(list)} min', style: const TextStyle(color: textLow)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SegmentedButton<WorkoutType>(
              segments: const [
                ButtonSegment(value: WorkoutType.funcional, label: Text('Funcional'), icon: Icon(Icons.bolt)),
                ButtonSegment(value: WorkoutType.hipertrofia, label: Text('Hipertrofia'), icon: Icon(Icons.fitness_center)),
              ],
              selected: {dayType[_day]},
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero, // ocupa a largura toda
              onSelectionChanged: (v) => _setType(v.first),
              style: SegmentedButton.styleFrom(
                backgroundColor: surface1,
                selectedBackgroundColor: lime,
                selectedForegroundColor: bg,
                foregroundColor: textMed,
                side: const BorderSide(color: border),
                textStyle: grotesk(15, weight: FontWeight.w600),
              ),
            ),
          ),
          if (list.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  dayType[_day] == WorkoutType.funcional
                      ? 'Toque no exercício para ajustar rodadas e tempo'
                      : 'Toque no exercício para ajustar séries e repetições',
                  style: const TextStyle(color: textLow, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: list.isEmpty
                ? _RestDay(onAdd: _edit)
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: list.length,
                    buildDefaultDragHandles: false,
                    onReorderItem: (from, to) => setState(() => list.insert(to, list.removeAt(from))),
                    itemBuilder: (_, i) => ExerciseCard(
                      list[i].exercise,
                      key: ObjectKey(list[i]),
                      info: list[i].label,
                      infoIcon: list[i].isTime ? Icons.timer_outlined : Icons.repeat,
                      onTap: () => _editSets(list[i]),
                      trailing: Column(children: [
                        IconButton(
                          tooltip: 'Remover',
                          icon: const Icon(Icons.close, color: textLow),
                          onPressed: () => setState(() => list.removeAt(i)),
                        ),
                        ReorderableDragStartListener(
                          index: i,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.drag_handle, color: textLow),
                          ),
                        ),
                      ]),
                    ),
                  ),
          ),
        ]),
      ),
      bottomNavigationBar: list.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.paddingOf(context).bottom),
              child: Row(children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: IconButton(
                    onPressed: _edit,
                    tooltip: 'Editar treino',
                    icon: const Icon(Icons.edit_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: surface2,
                      foregroundColor: textHigh,
                      side: const BorderSide(color: border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    'Iniciar treino',
                    icon: Icons.play_circle_outline,
                    onPressed: () => _play(0),
                  ),
                ),
              ]),
            ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({required this.label, required this.count, required this.selected, required this.isToday, required this.onTap});
  final String label;
  final int count;
  final bool selected, isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 56,
          decoration: BoxDecoration(
            color: selected ? lime : surface1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isToday && !selected ? lime : border),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: grotesk(13, color: selected ? bg : textMed, spacing: 0.5)),
            const SizedBox(height: 6),
            // quantidade de exercícios do dia; traço = descanso
            Text(count == 0 ? '–' : '$count', style: grotesk(18, color: selected ? bg : (count == 0 ? textLow : lime))),
          ]),
        ),
      );
}

class _RestDay extends StatelessWidget {
  const _RestDay({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.self_improvement, size: 56, color: surface3),
            const SizedBox(height: 12),
            Text('Dia de descanso', style: grotesk(20, weight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Nenhum exercício para este dia ainda.', style: TextStyle(color: textLow)),
            const SizedBox(height: 24),
            PrimaryButton('Montar treino', icon: Icons.add, onPressed: onAdd),
          ]),
        ),
      );
}

/// Ajuste da prescrição: rodadas x tempo (funcional) ou séries x repetições (hipertrofia).
class _SetsSheet extends StatefulWidget {
  const _SetsSheet(this.item);
  final PlanItem item;

  @override
  State<_SetsSheet> createState() => _SetsSheetState();
}

class _SetsSheetState extends State<_SetsSheet> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(item.exercise.title, style: grotesk(22)),
          const SizedBox(height: 4),
          Text('${item.type.label.toUpperCase()} • ${item.label}', style: grotesk(15, color: lime, spacing: 0.5)),
          const SizedBox(height: 16),
          _Stepper(
            label: item.type.setsLabel,
            value: '${item.sets}',
            onMinus: item.sets > 1 ? () => setState(() => item.sets--) : null,
            onPlus: item.sets < 10 ? () => setState(() => item.sets++) : null,
          ),
          if (item.isTime)
            _Stepper(
              label: item.type.amountLabel,
              value: '${item.time}s',
              // tempo anda de 5 em 5 segundos
              onMinus: item.time > 5 ? () => setState(() => item.time -= 5) : null,
              onPlus: item.time < 300 ? () => setState(() => item.time += 5) : null,
            )
          else
            _Stepper(
              label: item.type.amountLabel,
              value: '${item.reps}',
              onMinus: item.reps > 1 ? () => setState(() => item.reps--) : null,
              onPlus: item.reps < 100 ? () => setState(() => item.reps++) : null,
            ),
          const SizedBox(height: 20),
          PrimaryButton('Pronto', icon: Icons.check, onPressed: () => Navigator.pop(context)),
        ]),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.label, required this.value, required this.onMinus, required this.onPlus});
  final String label, value;
  final VoidCallback? onMinus, onPlus;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback? onTap, String tip) => IconButton.filled(
          onPressed: onTap,
          tooltip: tip,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: surface2,
            foregroundColor: textHigh,
            disabledBackgroundColor: surface2.withValues(alpha: 0.4),
            fixedSize: const Size(48, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(child: Text(label, style: grotesk(16, weight: FontWeight.w600))),
        btn(Icons.remove, onMinus, 'Diminuir'),
        SizedBox(width: 64, child: Text(value, textAlign: TextAlign.center, style: grotesk(22))),
        btn(Icons.add, onPlus, 'Aumentar'),
      ]),
    );
  }
}
