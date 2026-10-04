import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'ui.dart';

void main() => runApp(const FuncFitApp());

class FuncFitApp extends StatelessWidget {
  const FuncFitApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FuncFit',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const WelcomeScreen(),
      );
}
