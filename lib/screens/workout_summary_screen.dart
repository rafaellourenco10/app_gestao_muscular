import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';
import 'history_screen.dart';

/// Tela de parabéns ao concluir: tempo real, exercícios, séries e sequência.
class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({
    super.key,
    required this.title,
    required this.duration,
    required this.exercises,
    required this.setsDone,
    required this.type,
  });
  final String title;
  final Duration duration;
  final int exercises, setsDone;
  final WorkoutType type;

  @override
  Widget build(BuildContext context) {
    final streak = currentStreak(); // o treino de hoje já está no histórico
    final m = duration.inMinutes, s = duration.inSeconds % 60;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Spacer(),
            Center(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: lime, shape: BoxShape.circle, boxShadow: limeGlow),
                child: const Icon(Icons.check_rounded, size: 56, color: bg),
              ),
            ),
            const SizedBox(height: 24),
            Text('Treino concluído!', textAlign: TextAlign.center, style: grotesk(34, spacing: -0.8)),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: textLow, fontSize: 16)),
            const SizedBox(height: 32),
            Row(children: [
              _Stat(Icons.timer_outlined, '$m:${s.toString().padLeft(2, '0')}', 'TEMPO TOTAL'),
              const SizedBox(width: 10),
              _Stat(Icons.fitness_center, '$exercises', 'EXERCÍCIOS'),
              const SizedBox(width: 10),
              _Stat(Icons.repeat, '$setsDone', type.setsLabel.toUpperCase()),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surface1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: lime.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Text('🔥', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$streak ${streak == 1 ? 'dia seguido' : 'dias seguidos'}', style: grotesk(20, color: lime)),
                    const SizedBox(height: 2),
                    Text(
                      streak == 1 ? 'Sequência iniciada. Volte amanhã para manter!' : 'Continue assim, não quebre a sequência!',
                      style: const TextStyle(color: textLow),
                    ),
                  ]),
                ),
              ]),
            ),
            const Spacer(),
            PrimaryButton('Concluir', icon: Icons.check, onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
              child: Text('Ver histórico', style: grotesk(16, color: lime)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value, this.label);
  final IconData icon;
  final String value, label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
          child: Column(children: [
            Icon(icon, color: lime, size: 22),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(value, style: grotesk(26).copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
            ),
            const SizedBox(height: 4),
            FittedBox(child: Text(label, style: caps(textLow))),
          ]),
        ),
      );
}
