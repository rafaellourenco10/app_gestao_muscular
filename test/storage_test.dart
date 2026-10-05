import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_fit/data.dart';
import 'package:diario_fit/reminders.dart';
import 'package:diario_fit/storage.dart';

void main() {
  test('salvar e carregar devolve os mesmos dados', () {
    applyReadyPlan(readyPlans[1]);
    weeklyPlan[1].first
      ..sets = 4
      ..reps = 8;
    dayRest[1] = 90;
    history.add(WorkoutLog(DateTime(2026, 10, 5, 7, 30), 'Terça', 3, 25));
    addWeight(80.5, DateTime(2026, 10, 1));
    profile
      ..name = 'Ana'
      ..email = 'ana@x.com'
      ..heightCm = 170
      ..goalKg = 75;
    loggedIn = true;
    reminderTime = const TimeOfDay(hour: 7, minute: 15);

    final saved = encodeData();
    deleteAllUserData();
    loggedIn = false;
    reminderTime = null;
    decodeData(saved);

    expect(loggedIn, isTrue);
    expect(profile.name, 'Ana');
    expect(profile.goalKg, 75);
    expect(dayType[1], WorkoutType.hipertrofia);
    expect(dayRest[1], 90);
    expect(weeklyPlan[1].first.label, '4 x 8');
    expect(weeklyPlan[1].length, readyPlans[1].days[1]!.$2.length);
    expect(weeklyPlan[0], isEmpty);
    expect(history.single.title, 'Terça');
    expect(history.single.date, DateTime(2026, 10, 5, 7, 30));
    expect(weights.single.kg, 80.5);
    expect(reminderTime, const TimeOfDay(hour: 7, minute: 15));
    expect(encodeData(), saved);
  });

  test('exercício que saiu do catálogo some do cronograma sem quebrar', () {
    deleteAllUserData();
    final saved = encodeData().replaceFirst('"plan":[[]', '"plan":[[{"ex":"Não existe","type":"funcional","sets":3,"time":40,"reps":12}]');
    expect(saved, contains('Não existe'));
    decodeData(saved);
    expect(weeklyPlan[0], isEmpty);
  });
}
