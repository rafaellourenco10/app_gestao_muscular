import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'data.dart';

final _plugin = FlutterLocalNotificationsPlugin();

// ponytail: horário só em memória; as notificações já agendadas sobrevivem ao fechar o app,
// mas o app esquece o horário. Persistir junto com o cronograma no Supabase.
TimeOfDay? reminderTime;

bool get remindersSupported =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

Future<void> initReminders() async {
  if (!remindersSupported) return;
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
  await _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // a permissão é pedida só quando a pessoa ativa o lembrete
      iOS: DarwinInitializationSettings(requestAlertPermission: false, requestSoundPermission: false, requestBadgePermission: false),
    ),
  );
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
