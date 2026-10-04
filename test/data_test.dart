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

  test('sequência de dias', () {
    final hoje = DateTime(2026, 10, 10, 18);
    DateTime dia(int d) => DateTime(2026, 10, d, 9);
    WorkoutLog log(DateTime d) => WorkoutLog(d, 'x', 1, 1);

    history.clear();
    expect(currentStreak(hoje), 0);

    history.addAll([log(dia(7)), log(dia(8)), log(dia(9))]); // até ontem
    expect(currentStreak(hoje), 3); // hoje ainda não treinou: não zera

    history.add(log(dia(10)));
    history.add(log(dia(10))); // dois treinos no mesmo dia contam como um
    expect(currentStreak(hoje), 4);

    history.removeWhere((l) => l.date.day == 9); // buraco ontem
    expect(currentStreak(hoje), 1);

    expect(currentStreak(DateTime(2026, 10, 12)), 0); // passou um dia inteiro sem treinar
    history.clear();
  });

  test('texto do lembrete', () {
    weeklyPlan[0] = [PlanItem(e, type: hip), PlanItem(e, type: hip)];
    dayType[0] = hip;
    weeklyPlan[1] = [];
    expect(reminderBody(0), 'Hoje: Hipertrofia – 2 exercícios');
    expect(reminderBody(1), isNull); // descanso: sem aviso
  });

  test('progresso de peso, IMC e meta', () {
    weights.clear();
    profile
      ..heightCm = 180
      ..goalKg = 80;
    expect(bmi(), isNull);
    expect(goalProgress(), isNull);

    addWeight(90, DateTime(2026, 1, 1));
    addWeight(85, DateTime(2026, 3, 1));
    addWeight(88, DateTime(2026, 2, 1)); // fora de ordem: é ordenado por data
    expect(weights.first.kg, 90);
    expect(weights.last.kg, 85);
    expect(goalProgress(), 0.5); // perdeu 5 de 10 kg
    expect(bmi()!.toStringAsFixed(1), '26.2'); // 85 / 1,8²
    expect(bmiLabel(bmi()!), 'Sobrepeso');

    profile.goalKg = 95; // meta de ganhar, mas perdeu: progresso 0
    expect(goalProgress(), 0);

    expect(kg(72.5), '72,5');
    expect(kg(80), '80');
    expect(parseDecimal('72,5'), 72.5);
    expect(parseDecimal('abc'), isNull);
    weights.clear();
  });
}
