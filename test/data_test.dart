import 'package:flutter_test/flutter_test.dart';
import 'package:funcfit/data.dart';

void main() {
  final e = exercises.first; // 45s
  const hip = WorkoutType.hipertrofia;

  test('rótulo da prescrição', () {
    expect(PlanItem(e).label, '3 x 45s'); // funcional
    expect(PlanItem(e, type: hip, sets: 4, reps: 12).label, '4 x 12');
    expect(PlanItem(e, sets: 1).label, '45 seg');
    expect(PlanItem(e, type: hip, sets: 1, reps: 10).label, '10 reps');
  });

  test('trocar o tipo preserva tempo e repetições', () {
    final item = PlanItem(e, time: 50, reps: 8);
    item.type = hip;
    expect(item.label, '3 x 8');
    item.type = WorkoutType.funcional;
    expect(item.label, '3 x 50s');
  });

  test('minutos estimados', () {
    expect(PlanItem(e).seconds, 135); // 3 x 45s
    expect(PlanItem(e, type: hip, reps: 10).seconds, 90); // 3 x 10 reps x 3s
    expect(planMinutes([PlanItem(e), PlanItem(e)]), 5); // 270s -> 4,5 -> 5
  });

  test('cópia do dia é independente do original', () {
    final original = PlanItem(e, sets: 4);
    final copy = original.copy()..sets = 2;
    expect(original.sets, 4);
    expect(copy.label, '2 x 45s');
  });

  test('busca ignora acentos e maiúsculas', () {
    expect(fold('Flexão de Braço'), 'flexao de braco');
    expect(fold('Rotação torácica').contains(fold('TORACICA')), isTrue);
  });

  test('treinos prontos usam exercícios que existem', () {
    for (final p in readyPlans) {
      applyReadyPlan(p); // firstWhere lança erro se algum título estiver errado
      for (final MapEntry(key: d, value: (type, titles)) in p.days.entries) {
        expect(weeklyPlan[d].map((i) => i.exercise.title), titles);
        expect(dayType[d], type);
      }
      final restDays = [for (var d = 0; d < 7; d++) if (!p.days.containsKey(d)) d];
      expect(restDays.every((d) => weeklyPlan[d].isEmpty), isTrue);
    }
  });
}
