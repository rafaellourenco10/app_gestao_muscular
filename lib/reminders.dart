import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'data.dart';
import 'ui.dart';

final _plugin = FlutterLocalNotificationsPlugin();

// ponytail: horário só em memória; as notificações já agendadas sobrevivem ao fechar o app,
// mas o app esquece o horário. Persistir junto com o cronograma no Supabase.
TimeOfDay? reminderTime;

/// Plugin iniciado. Se o initReminders falhou, as notificações do treino viram no-op.
bool _ready = false;

bool get remindersSupported =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

Future<void> initReminders() async {
  if (!remindersSupported) return;
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
  await _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'), // silhueta branca: a barra de status ignora cores
      // a permissão é pedida só quando a pessoa ativa o lembrete
      iOS: DarwinInitializationSettings(requestAlertPermission: false, requestSoundPermission: false, requestBadgePermission: false),
    ),
  );
  _ready = true;
}

Future<bool> requestReminderPermission() async {
  final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  if (android != null) return await android.requestNotificationsPermission() ?? false;
  final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
  return await ios?.requestPermissions(alert: true, sound: true) ?? false;
}

/// Agenda um aviso semanal para cada dia que tem treino no cronograma (id = dia).
/// Chamar de novo sempre que o cronograma ou o horário mudar.
Future<void> scheduleReminders() async {
  if (!remindersSupported) return;
  for (var d = 0; d < 7; d++) {
    await _plugin.cancel(id: d);
  }
  final t = reminderTime;
  if (t == null) return;

  final now = tz.TZDateTime.now(tz.local);
  for (var d = 0; d < 7; d++) {
    final body = reminderBody(d);
    if (body == null) continue;
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, t.hour, t.minute);
    while (when.weekday != d + 1 || when.isBefore(now)) {
      when = tz.TZDateTime(tz.local, when.year, when.month, when.day + 1, t.hour, t.minute);
    }
    await _plugin.zonedSchedule(
      id: d,
      scheduledDate: when,
      title: 'Hora de treinar 💪',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('lembrete', 'Lembrete de treino', channelDescription: 'Aviso do treino do dia'),
        iOS: DarwinNotificationDetails(),
      ),
      // inexato: dispensa a permissão de alarme exato (pode atrasar alguns minutos)
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}

/// Fluxo da tela: escolher horário, mudar ou desativar o lembrete.
Future<void> configureReminder(BuildContext context) async {
  void toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  if (!remindersSupported) return toast('Lembretes só funcionam no celular.');

  if (reminderTime != null) {
    final off = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: surface1,
        title: Text('Lembrete às ${reminderTime!.format(context)}', style: grotesk(20)),
        content: const Text('Você recebe um aviso nos dias que têm treino no cronograma.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Desativar')),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, false),
            style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: bg),
            child: const Text('Mudar horário'),
          ),
        ],
      ),
    );
    if (off == null || !context.mounted) return;
    if (off) {
      reminderTime = null;
      await scheduleReminders();
      if (context.mounted) toast('Lembrete desativado.');
      return;
    }
  }

  final picked = await showTimePicker(
    context: context,
    initialTime: reminderTime ?? const TimeOfDay(hour: 7, minute: 0),
    helpText: 'Horário do lembrete',
  );
  if (picked == null || !context.mounted) return;
  if (!await requestReminderPermission()) {
    if (context.mounted) toast('Permita as notificações do Diário Fit nas configurações do celular.');
    return;
  }
  reminderTime = picked;
  await scheduleReminders();
  if (context.mounted) toast('Lembrete às ${picked.format(context)} nos dias com treino.');
}

// --- Treino em andamento com o app em segundo plano ---

const _progressId = 100, _alertId = 101;

/// Notificação fixa com o cronômetro do treino. Só Android: o próprio sistema anima
/// a contagem regressiva até [endsAt], mesmo sem o app rodar.
Future<void> showWorkoutProgress(String title, String body, {DateTime? endsAt}) async {
  if (!_ready || defaultTargetPlatform != TargetPlatform.android) return;
  await _plugin.show(
    id: _progressId,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        'treino',
        'Treino em andamento',
        channelDescription: 'Cronômetro do treino enquanto o app está em segundo plano',
        importance: Importance.low,
        priority: Priority.low,
        category: AndroidNotificationCategory.workout,
        ongoing: true,
        autoCancel: false,
        silent: true,
        showWhen: endsAt != null,
        when: endsAt?.millisecondsSinceEpoch,
        usesChronometer: endsAt != null,
        chronometerCountDown: true,
      ),
    ),
  );
}

/// Aviso com som (fim do descanso, próxima rodada...). Com [at], agenda para aquele
/// momento: só no iOS, que congela o app em segundo plano. No Android o próprio app
/// continua contando e chama sem [at] na hora certa.
Future<void> alertWorkout(String title, String body, {DateTime? at}) async {
  if (!_ready) return;
  final ios = defaultTargetPlatform == TargetPlatform.iOS;
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'treino_alerta',
      'Avisos do treino',
      channelDescription: 'Fim do descanso, próxima rodada e treino completo',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.workout,
    ),
    iOS: DarwinNotificationDetails(),
  );
  if (at == null) {
    await _plugin.show(id: _alertId, title: title, body: body, notificationDetails: details);
  } else if (ios) {
    await _plugin.zonedSchedule(
      id: _alertId,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      title: title,
      body: body,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // ignorado no iOS
    );
  }
}

Future<void> clearWorkoutNotifications() async {
  if (!_ready) return;
  await _plugin.cancel(id: _progressId);
  await _plugin.cancel(id: _alertId);
}
