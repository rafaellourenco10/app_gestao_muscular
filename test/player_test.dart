import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_fit/data.dart';
import 'package:diario_fit/screens/player_screen.dart';

void main() {
  late DateTime now;
  setUp(() {
    now = DateTime(2026, 10, 5, 8);
    playerClock = () => now;
  });

  Future<void> open(WidgetTester tester, List<PlanItem> items, {int rest = 5}) async {
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    await tester.pumpWidget(MaterialApp(home: PlayerScreen(title: 'Teste', items: items, index: 0, restSec: rest)));
  }

  testWidgets('volta do segundo plano recupera as fases que passaram', (tester) async {
    final squat = exercises.firstWhere((e) => e.title == 'Isometria na parede');
    final plank = exercises.firstWhere((e) => e.title == 'Prancha frontal');
    await open(tester, [PlanItem(squat, sets: 2, time: 10), PlanItem(plank, sets: 2, time: 10)]);

    await tester.tap(find.text('Iniciar'));
    await tester.pump();
    // rodada 10s, descanso 5s, rodada 10s, descanso 5s -> 2º exercício começa em 30s
    now = now.add(const Duration(seconds: 32));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Exercício 2 / 2'), findsOneWidget);
    expect(find.text('RODADA 1 DE 2'), findsOneWidget);
    expect(find.text('0:08'), findsOneWidget);

    // 30 + 10 + 5 + 10 = 55s: treino acabou
    now = now.add(const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Mandou bem!'), findsOneWidget);
  });

  testWidgets('trocar exercício vale só para o treino', (tester) async {
    final first = exercises.firstWhere((e) => e.title == 'Agachamento com salto');
    final plan = [PlanItem(first, sets: 4, time: 30)];
    await open(tester, plan);

    await tester.tap(find.text('Trocar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Isometria na parede'));
    await tester.pumpAndSettle();

    expect(find.text('Isometria na parede'), findsOneWidget);
    expect(find.text('4 x 30s'), findsOneWidget); // prescrição mantida
    expect(plan.single.exercise, first); // cronograma intacto
  });
}
