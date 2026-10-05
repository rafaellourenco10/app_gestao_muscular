import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'reminders.dart';
import 'screens/categories_screen.dart';
import 'screens/welcome_screen.dart';
import 'storage.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadData();
  // segundo plano é o último momento garantido antes do sistema matar o app
  AppLifecycleListener(onHide: saveData);
  try {
    await initReminders();
  } catch (e) {
    debugPrint('Lembretes indisponíveis: $e'); // o app abre mesmo sem notificações
  }
  runApp(const DiarioFitApp());
}

class DiarioFitApp extends StatelessWidget {
  const DiarioFitApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Diário Fit',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        // textos do sistema (seletor de horário, botões de diálogo) em português
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        navigatorObservers: [SaveOnNavigate()],
        home: loggedIn ? const CategoriesScreen() : const WelcomeScreen(),
      );
}
