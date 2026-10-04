import 'package:flutter/material.dart';

import '../data.dart';
import '../ui.dart';

/// Lista os treinos prontos; ao aplicar, volta com `true`.
class ReadyPlansScreen extends StatelessWidget {
  const ReadyPlansScreen({super.key});

  Future<void> _apply(BuildContext context, ReadyPlan plan) async {
    final hasPlan = weeklyPlan.any((d) => d.isNotEmpty);
    final ok = !hasPlan ||
        await showDialog<bool>(
              context: context,
              builder: (dialog) => AlertDialog(
                backgroundColor: surface1,
                title: Text('Substituir sua semana?', style: grotesk(20)),
                content: const Text('O cronograma atual será trocado por este treino pronto.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancelar')),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: bg),
                    child: const Text('Substituir'),
                  ),
                ],
              ),
            ) ==
            true;
    if (!ok || !context.mounted) return;
    applyReadyPlan(plan);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Row(children: [
              SquareIconButton(Icons.arrow_back, onTap: () => Navigator.pop(context)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PARA COMEÇAR', style: caps(lime)),
                  Text('Treinos prontos', style: grotesk(24, spacing: -0.5)),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            const Text('Escolha um plano e ajuste depois do seu jeito.', style: TextStyle(color: textLow)),
            const SizedBox(height: 16),
            for (final p in readyPlans)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: surface1, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: grotesk(20)),
                  const SizedBox(height: 6),
                  Text(p.description, style: const TextStyle(color: textLow, height: 1.4)),
                  const SizedBox(height: 14),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final MapEntry(key: d, value: (type, list)) in p.days.entries)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '${weekdays[d].substring(0, 3).toUpperCase()} • ${type.label} • ${list.length}',
                          style: grotesk(12, weight: FontWeight.w600, color: textMed),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton('Usar este treino', icon: Icons.check, onPressed: () => _apply(context, p)),
                  ),
                ]),
              ),
          ]),
        ),
      );
}
