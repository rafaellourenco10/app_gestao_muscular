import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'reminders.dart';

// Tudo num único JSON no aparelho. Os dados são pequenos (semana + histórico + pesos),
// então regravar o pacote inteiro é mais simples do que salvar campo a campo.
// ponytail: só local; com o Supabase isto vira cache offline das tabelas.
const _key = 'diariofit_data';
final _prefs = SharedPreferencesAsync();

/// Há uma sessão aberta (pula a tela de boas-vindas).
bool loggedIn = false;

Future<void> loadData() async {
  final raw = await _prefs.getString(_key);
  if (raw == null) return;
  try {
    decodeData(raw);
  } catch (e) {
    // dado corrompido não pode travar a abertura; começa do zero
    debugPrint('Dados salvos ilegíveis, ignorando: $e');
  }
}

Future<void> saveData() async {
  try {
    await _prefs.setString(_key, encodeData());
  } catch (e) {
    debugPrint('Falha ao salvar dados: $e');
  }
}

String _date(DateTime d) => d.toIso8601String();

String encodeData() => jsonEncode({
      'v': 1,
      'loggedIn': loggedIn,
      'profile': {
        'name': profile.name,
        'email': profile.email,
        'level': profile.level,
        'goal': profile.goal,
        'heightCm': profile.heightCm,
        'goalKg': profile.goalKg,
      },
      'plan': [
        for (final day in weeklyPlan)
          [
            for (final i in day) {'ex': i.exercise.title, 'type': i.type.name, 'sets': i.sets, 'time': i.time, 'reps': i.reps},
          ],
      ],
      'dayType': [for (final t in dayType) t.name],
      'dayRest': dayRest,
      'history': [
        for (final l in history) {'date': _date(l.date), 'title': l.title, 'exercises': l.exercises, 'minutes': l.minutes},
      ],
      'weights': [
        for (final w in weights) {'date': _date(w.date), 'kg': w.kg},
      ],
      'reminder': reminderTime == null ? null : [reminderTime!.hour, reminderTime!.minute],
    });

void decodeData(String raw) {
  final j = jsonDecode(raw) as Map<String, dynamic>;
  deleteAllUserData();
  loggedIn = j['loggedIn'] as bool? ?? false;

  final p = j['profile'] as Map<String, dynamic>;
  profile
    ..name = p['name'] as String
    ..email = p['email'] as String
    ..level = p['level'] as String
    ..goal = p['goal'] as String
    ..heightCm = p['heightCm'] as int?
    ..goalKg = (p['goalKg'] as num?)?.toDouble();

  final byTitle = {for (final e in exercises) e.title: e};
  final plan = j['plan'] as List;
  for (var d = 0; d < 7; d++) {
    dayType[d] = WorkoutType.values.byName((j['dayType'] as List)[d] as String);
    dayRest[d] = (j['dayRest'] as List)[d] as int;
    weeklyPlan[d] = [
      for (final i in (plan[d] as List).cast<Map<String, dynamic>>())
        // exercício removido do catálogo some do cronograma em vez de quebrar
        if (byTitle[i['ex']] case final e?)
          PlanItem(e,
              type: WorkoutType.values.byName(i['type'] as String),
              sets: i['sets'] as int,
              time: i['time'] as int,
              reps: i['reps'] as int),
    ];
  }

  for (final l in (j['history'] as List).cast<Map<String, dynamic>>()) {
    history.add(WorkoutLog(DateTime.parse(l['date'] as String), l['title'] as String, l['exercises'] as int, l['minutes'] as int));
  }
  for (final w in (j['weights'] as List).cast<Map<String, dynamic>>()) {
    weights.add(WeightEntry(DateTime.parse(w['date'] as String), (w['kg'] as num).toDouble()));
  }

  final r = j['reminder'] as List?;
  reminderTime = r == null ? null : TimeOfDay(hour: r[0] as int, minute: r[1] as int);
}

/// Salva sempre que uma tela abre ou fecha: cobre as edições do cronograma e do perfil
/// sem precisar chamar saveData em cada botão.
class SaveOnNavigate extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => saveData();
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => saveData();
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => saveData();
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => saveData();
}
