import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'reminders.dart';
import 'screens/welcome_screen.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initReminders();
  } catch (e) {
    debugPrint('Lembretes indisponíveis: $e'); // o app abre mesmo sem notificações
  }
  runApp(const FuncFitApp());
}

class FuncFitApp extends StatelessWidget {
  const FuncFitApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FuncFit',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        // textos do sistema (seletor de horário, botões de diálogo) em português
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const WelcomeScreen(),
      );
}
